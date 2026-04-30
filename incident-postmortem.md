# Incident Postmortem: Production Service Outage Caused by NSG Rule Priority

## 1) Incident Summary

- **Incident ID:** `INC-2026-04-30-001`
- **Environment:** `prod`
- **Service:** `customer-api` on `az-ir-platform-p-westeurope-vm-app-01`
- **Severity:** `SEV-1`
- **Incident commander:** Platform on-call lead
- **Start (customer impact):** `2026-04-30 00:15 UTC`
- **Mitigation complete:** `2026-04-30 00:37 UTC`
- **Close time:** `2026-04-30 00:49 UTC`
- **Total customer impact:** 22 minutes hard outage + 12 minutes degraded recovery

At 00:15 UTC, inbound HTTPS traffic to the production app path was blocked after an NSG change was applied. VM health remained green, which delayed first diagnosis and initially led the team to suspect application failure.

---

## 2) Timeline (Minute-by-Minute, Operational Detail)

> All times UTC, 2026-04-30.

- **00:11** - PR `infra/network-rules-245` merged to `main` after standard review.
- **00:12** - `Terraform Prod` workflow starts (`run_id: 10428977431`).
- **00:14** - Apply job reports success for NSG update and container group creation.
- **00:15** - Support desk receives first customer report: API timeouts from two external clients.
- **00:16** - Synthetic probe #1 fails (west-europe monitor).
- **00:17** - Synthetic probe #2 fails; internal dashboard shows endpoint red.
- **00:18** - Azure Monitor `Sev1` service-availability alert fired.
- **00:19** - On-call acknowledges in Teams channel and opens bridge call.
- **00:20** - First assumption: app process crash (because recent container rollout happened in same apply).
- **00:21** - App owner checks deployment history, reports no app release and no config rollout in same window.
- **00:22** - `curl` from jump host to `https://<redacted-endpoint>` times out.
- **00:23** - VM heartbeat still healthy; CPU 28-35%; no reboot in Activity Log.
- **00:24** - Wrong assumption #2: DNS resolution issue; DNS checks return healthy.
- **00:25** - NSG effective rules check started.
- **00:26** - Team sees deny rule (`priority 300`) evaluated before allow HTTPS (`priority 400`).
- **00:27** - Incident commander declares network-layer incident and escalates to platform lead + duty manager.
- **00:28** - Decision point: rollback NSG rule order immediately (no wait for next scheduled change window).
- **00:29** - Emergency PR `hotfix/nsg-priority-override` opened.
- **00:30** - Secondary reviewer approves hotfix (4-eye control maintained under incident mode).
- **00:31** - Hotfix merged; prod workflow triggered manually with approval override.
- **00:33** - Apply completes; NSG order corrected.
- **00:34** - First synthetic probe recovery (1/3 regions healthy).
- **00:35** - External curl returns `HTTP/1.1 200` from approved source range.
- **00:36** - Error rate drops from 94% to 18%.
- **00:37** - All probes healthy; customer traffic normalizing.
- **00:40** - Alert auto-resolved after sustained healthy window.
- **00:49** - Incident closed after 12-minute watch period with no regression.

---

## 3) Detection (Alert + Signal Path)

Primary detection was from service-level alerting, not VM host monitoring.

- **Alert rule:** `alert-service-availability-endpoint`
- **Fired:** `2026-04-30T00:18:26.129Z`
- **Severity:** `Sev1`
- **Condition:** Availability average `< 1` over `PT5M`

### Alert payload excerpt

```json
{
  "alertRule": "alert-service-availability-endpoint",
  "severity": "Sev1",
  "monitorCondition": "Fired",
  "firedDateTime": "2026-04-30T00:18:26.129Z",
  "resourceGroupName": "az-ir-platform-p-westeurope-rg-network",
  "resourceName": "az-ir-platform-p-westeurope-vm-app-01",
  "customProperties": {
    "environment": "prod",
    "service": "customer-api",
    "oncallRotation": "platform-primary",
    "runbook": "runbooks/vm-not-reachable.md"
  }
}
```

---

## 4) Impact (What Users Experienced)

- External customers experienced request timeouts and occasional gateway errors.
- API clients entered retry loops, causing temporary load amplification.
- Internal support team saw ticket spike and manual status checks from account managers.

Business impact (estimated):

- 22 minutes full interruption of primary API path
- delayed transaction processing and customer-facing SLA breach risk
- on-call escalation beyond normal engineering roster

---

## 5) Investigation Evidence (Logs + Queries Used)

### Query output used during triage

```text
TimeGeneratedUTC      Computer                                  MinutesSinceHeartbeat  HealthState
2026-04-30 00:23:11   az-ir-platform-p-westeurope-vm-app-01    1                      Healthy
2026-04-30 00:23:08   az-ir-platform-p-westeurope-vm-mgmt-01   1                      Healthy
```

```text
TimeGeneratedUTC      Resource                                  ResultType  ResultDescription
2026-04-30 00:14:07   .../networkSecurityGroups/...application  Succeeded   Update network security rules
2026-04-30 00:14:10   .../containerGroups/...aci-app            Succeeded   Create container group
```

### App host logs sampled

```text
2026-04-30T00:20:44Z nginx[2142]: worker process is running
2026-04-30T00:20:44Z nginx[2142]: active connections: 0
2026-04-30T00:22:02Z kernel: TCP: Possible SYN flooding on port 443. Sending cookies.
2026-04-30T00:22:03Z nginx[2142]: no upstream errors detected
```

Interpretation:

- service process was up
- host was healthy
- no app-level crash signature
- connectivity path likely blocked before app layer

---

## 6) Commands Executed During Incident

> Sanitized command list from bridge notes and shell history.

```powershell
# Validate endpoint from management jump host
curl -I https://<redacted-endpoint>

# Check VM power/runtime state
az vm get-instance-view `
  --resource-group az-ir-platform-p-westeurope-rg-network `
  --name az-ir-platform-p-westeurope-vm-app-01 `
  --query "instanceView.statuses[].displayStatus" -o tsv

# Validate effective NSG rules
az network nic list-effective-nsg `
  --resource-group az-ir-platform-p-westeurope-rg-network `
  --name az-ir-platform-p-westeurope-nic-app-01 -o table

# Check recent network security group operations
az monitor activity-log list `
  --resource-group az-ir-platform-p-westeurope-rg-network `
  --offset 1h `
  --query "[?contains(operationName.value, 'Microsoft.Network/networkSecurityGroups')].[eventTimestamp,operationName.value,status.value]" -o table

# Validate service locally on VM (from jump SSH)
sudo systemctl status nginx --no-pager
sudo ss -tulpen | grep ':443'
```

---

## 7) Wrong Assumptions During Debugging

1. **Assumption:** app process crash due to recent change  
   **Reality:** no app release occurred; service process remained healthy.

2. **Assumption:** DNS/endpoint issue  
   **Reality:** DNS resolution was correct; traffic was blocked by NSG priority order.

3. **Assumption:** container rollout caused network instability  
   **Reality:** container creation was unrelated to denied HTTPS path.

What this changed:

- triage checklist was updated to force early network-effective-rule validation before deeper app debugging when host health is green but service is down.

---

## 7.1) What We Ignored

- repeated indication that failures were source-specific (not uniform), which hinted at policy/path issue earlier
- early kernel/network hints in logs because app health suspicion dominated first triage loop
- change-window coupling risk (NSG + container operation) during first 10 minutes

## 7.2) What We Misinterpreted

- "VM healthy" as proxy for "service healthy"
- first customer timeout cluster as application behavior instead of ingress policy effect
- successful apply status as proof that runtime connectivity was valid

## 7.3) What We Thought vs What Actually Happened

- **Thought:** app rollout caused outage  
  **Actually happened:** NSG rule precedence blocked HTTPS ingress.

- **Thought:** DNS issue due to timeout pattern  
  **Actually happened:** DNS was healthy; deny rule executed before allow rule.

- **Thought:** service recovered as soon as first probe turned green  
  **Actually happened:** full recovery required all regions + watch-window confirmation.

---

## 8) Escalation Decision Point

At **00:27 UTC**, incident commander escalated from standard on-call handling to incident-management mode because:

- customer impact was confirmed and ongoing
- first-line triage had already consumed 8+ minutes
- probable network-control regression required privileged platform intervention

Escalation actions:

- incident commander assigned
- duty manager notified
- emergency change path enabled with mandatory second reviewer

---

## 9) Root Cause

Primary root cause:

- NSG deny rule with **higher precedence** than required HTTPS allow rule.

Technical detail:

- deny inbound rule: `priority 300`
- allow HTTPS rule: `priority 400`
- lower priority number executes first in NSG evaluation

Contributing factors:

- review focused on rule content, not effective rule order
- no pre-apply connectivity gate for critical prod ports
- change template did not require before/after effective-flow evidence

---

## 10) Resolution and Recovery Validation

### Resolution steps

1. Open emergency PR to restore expected NSG priority.
2. Apply via protected CI/CD path (no portal hotfix).
3. Confirm NSG effective rules show allow-443 before deny rule path for approved source range.

### Recovery validation checklist

- [x] synthetic probes healthy across all configured regions
- [x] external endpoint from approved CIDR returns `HTTP 200`
- [x] app logs show normal request throughput
- [x] error rate drops below alert threshold and remains stable
- [x] no new correlated alerts (CPU, VM availability, auth anomalies) for 10+ minutes

---

## 11) What Went Wrong

- Change review did not explicitly validate effective NSG rule precedence.
- Initial triage spent too long at app layer despite healthy host signals.
- No automated gate to verify critical ingress reachability after network changes.

## 12) What Went Well

- Detection was fast through service-level alerting.
- Team preserved change governance even under pressure (review + CI/CD path).
- Escalation was timely once customer impact and probable network fault were clear.
- Recovery validation was deliberate, not "alert cleared = done."

---

## 13) Follow-Up Tasks (Owned and Time-Bound)

### Immediate (0-7 days)

- **Owner:** Platform Team  
  Add CI pre-apply network reachability check for prod critical ports (`443`).
- **Owner:** SRE / Monitoring  
  Add alert on high-risk NSG modifications from Activity Log.
- **Owner:** Incident Manager  
  Update triage runbook with "host healthy + service down" decision branch.

### Near-term (1-4 weeks)

- **Owner:** Security Engineering  
  Enforce approved NSG rule patterns via Azure Policy initiative.
- **Owner:** Platform Team  
  Add change template section: before/after effective-flow validation evidence.
- **Owner:** Operations Manager  
  Run incident simulation drill for network-layer outage path.

### Medium-term (1-2 months)

- **Owner:** Platform + QA  
  Add staged canary checks after every prod network change.
- **Owner:** DevOps  
  Implement automatic rollback trigger on sustained SLO breach post-change.

---

## 14) Metrics Snapshot From This Incident

- **MTTD:** 3 minutes (first customer signal to alert fire)
- **MTTA:** 1 minute (alert fire to acknowledgment)
- **MTTR:** 19 minutes (acknowledgment to full recovery)
- **Total customer impact window:** 34 minutes including degraded recovery/watch period

---

## 15) Evidence Walkthrough for Incident Review

In order, with short narration for each:

1. **Terraform plan artifact** (`evidence/terraform-plan-sanitized.txt`)  
   Show the NSG rule change and explain why precedence mattered.

2. **Azure Monitor alert payload** (`evidence/azure-monitor-alert-payload.json`)  
   Show `firedDateTime`, severity, target resource, and runbook routing fields.

3. **Log Analytics result snippet** (`evidence/log-analytics-query-results.md`)  
   Show host heartbeat healthy while service unavailable to justify network-focused triage.

4. **Incident channel message** (`evidence/incident-alert-message.txt`)  
   Show how escalation, ownership, and update cadence were handled in real time.

5. **Apply artifact** (`evidence/terraform-apply-sanitized.txt`)  
   Show controlled recovery through CI/CD and validation outputs.

What I say explicitly:

- "This is where we were wrong first."
- "This is the decision point where we escalated."
- "This is the evidence that confirmed root cause."
- "This is what we changed so this class of outage is less likely to recur."

---

## 16) Traceability Links (Alert -> Logs -> Fix -> Follow-Up)

- incident record: `incident-postmortem.md` (`INC-2026-04-30-001`)
- detection signal: `evidence/azure-monitor-alert-payload.json`
- investigation evidence: `evidence/log-analytics-query-results.md`
- mitigation and controlled fix path:
  - `change-lifecycle.md`
  - `evidence/terraform-apply-sanitized.txt`
- response communication evidence: `evidence/incident-alert-message.txt`
- follow-up ownership and closure tracking: `corrective-actions.md` (`CA-011`, `CA-012`, `CA-013`)
- trend and reliability impact:
  - `operations-metrics.md`
  - `slo-month-analysis.md`
