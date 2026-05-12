# Complex Incident Report: Deployment + NSG Regression + CPU Saturation

Status: Simulated/Sanitized Sample  
Scope: Portfolio repository. No live tenant data or customer data is included.

## 1) Incident Summary

- **Incident ID:** `INC-2026-05-18-002`
- **Severity:** `Sev1`
- **Environment:** `prod`
- **Service:** `customer-api`
- **Start (first user impact):** `2026-05-18 13:07 UTC`
- **Stabilized:** `2026-05-18 14:02 UTC`
- **Closed:** `2026-05-18 14:29 UTC`
- **Total impact window:** 55 minutes major degradation + 27 minutes recovery watch

This incident was multi-factor:

1. deployment changed request behavior and increased CPU load
2. NSG misconfiguration partially blocked traffic from one trusted ingress range
3. CPU saturation amplified timeouts and masked the network fault

No single signal told the full story in the first 15-20 minutes.

---

## 2) Impact

- ~42% of client requests failed (timeouts/5xx) during peak window.
- One support region had near-complete failure due to blocked source range.
- Other regions had intermittent failures due to high CPU and queueing delays.
- Internal support escalations increased sharply (ticket spike in first 20 minutes).

Business impact:

- delayed transaction processing
- SLA risk for API response availability
- elevated on-call and incident bridge load

---

## 3) Detection and Why It Was Delayed

### Alert sequence

1. `alert-vm-high-cpu-anomaly` (`Sev2`) fired first at `13:09`.
2. `alert-service-availability-endpoint` (`Sev1`) fired at `13:13`.
3. `alert-network-path-failure` query alert fired at `13:19` (after enough failed checks accumulated).

### Why delayed detection happened

- early team focus was on CPU saturation because that alert fired first
- endpoint failures were asymmetric by source range, which looked like random client instability
- VM heartbeat stayed healthy, reducing urgency for network-path diagnosis

### Detection delay summary

- **Initial impact seen:** `13:07`
- **First alert fired:** `13:09` (CPU symptom, not initiating fault)
- **Combined-fault hypothesis formed:** `13:20`
- **Detection gap to correct fault model:** `13 minutes`

Why this matters:

- the team had telemetry quickly, but not the right interpretation path
- high-signal but misleading symptom alerts can delay correct mitigation when fault domains overlap

---

## 4) Minute-by-Minute Timeline

> UTC on 2026-05-18.

- **13:01** - Deployment `REL-2026.05.18.1` completed (new API caching path + config update).
- **13:04** - NSG change applied in same window (`CHG-4891`) to tighten ingress CIDRs.
- **13:07** - First customer timeouts reported from support region EU-2.
- **13:09** - High CPU anomaly alert fires (`cpu >2x baseline`, 15m window).
- **13:10** - On-call assumes deployment regression only; app team engaged first.
- **13:12** - API error rate climbs above 25%.
- **13:13** - Service availability `Sev1` alert fires.
- **13:14** - Incident bridge started; incident commander assigned.
- **13:16** - Initial rollback considered, but paused due to mixed success from some client ranges.
- **13:18** - CPU mitigation attempt: app worker count reduced; no meaningful impact.
- **13:19** - Network-path query alert indicates deny decisions for one trusted source CIDR.
- **13:20** - First explicit hypothesis of combined fault (app + network).
- **13:23** - Effective NSG check confirms missing CIDR in HTTPS allow rule.
- **13:24** - Decision: execute dual mitigation:
  - hotfix NSG rule
  - rollback deployment to previous release
- **13:28** - NSG hotfix PR opened (`hotfix/nsg-cidr-restore`).
- **13:31** - NSG fix approved and applied.
- **13:34** - Previously failing region begins recovering.
- **13:36** - Deployment rollback initiated (`REL-2026.05.17.7`).
- **13:43** - CPU begins trending down; queue depth normalizing.
- **13:49** - Error rate below 5%.
- **13:54** - All synthetic probes healthy across regions.
- **14:02** - Service declared stabilized.
- **14:29** - Incident closed after watch window and no regression.

---

## 5) Incorrect Initial Assumptions

1. **Assumption:** this is only a deployment regression (CPU-driven)  
   **Reality:** deployment was only one contributing factor.

2. **Assumption:** if heartbeat is healthy, network is likely fine  
   **Reality:** traffic was partially blocked by NSG source-range omission.

3. **Assumption:** global service failure should be uniform  
   **Reality:** asymmetric impact by source region suggested path-specific policy issue.

Operational consequence:

- around 10-12 minutes were lost before network-effective-rule checks were prioritized.

---

## 5.1) What We Ignored

- asymmetric client failures in first 8 minutes (should have triggered earlier network-path hypothesis)
- duplicate warning events around NSG writes because CPU alert dominated bridge discussion
- queue-depth trend worsening after first mitigation attempt (indicating CPU-only mitigation was insufficient)

## 5.2) What We Misinterpreted

- elevated CPU as root cause instead of co-factor
- mixed regional success as random client variance instead of policy-scope issue
- early partial improvements as evidence that rollback could be deferred

## 5.3) What We Thought vs What Actually Happened

- **Thought:** deployment rollback alone should restore service  
  **Actually happened:** NSG ingress omission had to be fixed first for affected range.

- **Thought:** one bridge owner can sequence hypotheses serially  
  **Actually happened:** parallel diagnosis (network + app) was required.

- **Thought:** first alert indicates primary fault  
  **Actually happened:** first alert pointed to an amplifier, not the initiating control failure.

---

## 6) Evidence (Alerts, Logs, Commands)

## Alert payload snippets (sanitized)

```json
{
  "alertRule": "alert-vm-high-cpu-anomaly",
  "severity": "Sev2",
  "firedDateTime": "2026-05-18T13:09:22Z",
  "resourceName": "az-ir-platform-p-westeurope-vm-app-01",
  "metric": "Percentage CPU",
  "deviationRatio": 2.31
}
```

```json
{
  "alertRule": "alert-service-availability-endpoint",
  "severity": "Sev1",
  "firedDateTime": "2026-05-18T13:13:08Z",
  "resourceName": "az-ir-platform-p-westeurope-vm-app-01",
  "failedRegions": ["eu-2", "eu-3"]
}
```

```json
{
  "alertRule": "alert-network-path-failure",
  "severity": "Sev2",
  "firedDateTime": "2026-05-18T13:19:41Z",
  "details": "Denied inbound TCP/443 for source 198.51.100.0/24 by NSG application rule set"
}
```

## Log snippets used during triage

Application logs:

```text
2026-05-18T13:08:41Z api[7421]: cache miss ratio spike: 78%
2026-05-18T13:09:03Z api[7421]: upstream timeout count exceeded threshold (window=60s)
2026-05-18T13:11:29Z api[7421]: request queue depth=412 (normal <120)
2026-05-18T13:44:02Z api[7421]: queue depth returned to 97
```

Nginx/access edge logs:

```text
2026-05-18T13:12:17Z 203.0.113.24 - "GET /health" 200 0.031
2026-05-18T13:12:18Z 198.51.100.19 - "GET /health" 499 30.001
2026-05-18T13:33:50Z 198.51.100.19 - "GET /health" 200 0.044
```

System/network logs:

```text
2026-05-18T13:10:55Z kernel: TCP: Possible SYN flooding on port 443. Sending cookies.
2026-05-18T13:20:01Z netdiag: inbound deny detected for source 198.51.100.0/24 on 443
```

## Commands executed

```powershell
# verify effective nsg during incident
az network nic list-effective-nsg `
  --resource-group az-ir-platform-p-westeurope-rg-network `
  --name az-ir-platform-p-westeurope-nic-app-01 -o table

# check activity log in change window
az monitor activity-log list `
  --resource-group az-ir-platform-p-westeurope-rg-network `
  --offset 2h `
  --query "[?contains(operationName.value, 'networkSecurityGroups') || contains(operationName.value, 'virtualMachines/write')].[eventTimestamp,operationName.value,status.value,caller]" -o table

# verify cpu pressure and recover trend
az monitor metrics list `
  --resource <vm-id> `
  --metric "Percentage CPU" `
  --interval PT1M
```

---

## 7) Root Cause (Multiple)

### Primary causes

1. **NSG rule omission**
   - trusted ingress CIDR `198.51.100.0/24` removed unintentionally from HTTPS allow rule.

2. **Deployment-side performance regression**
   - new caching behavior increased misses and compute pressure, causing high CPU and timeouts.

### Contributing causes

- both changes occurred in same window, complicating attribution
- first alert biased triage toward compute-only diagnosis
- insufficient pre-change composite validation (network + perf together)

---

## 8) Recovery Steps

1. Declared combined-fault incident after conflicting telemetry (13:20).
2. Restored missing NSG trusted CIDR in prod application NSG.
3. Rolled back application deployment to prior stable release.
4. Monitored CPU, queue depth, and endpoint success by region.
5. Kept watch window before close due to dual-change rollback risk.

### Recovery validation checkpoints

- [x] endpoint success rate recovered above `99%` in affected region
- [x] error rate stayed below `5%` for 20+ minutes
- [x] CPU returned to expected baseline band
- [x] no repeated NSG deny events for trusted CIDRs in log window
- [x] no new `Sev1` alerts in post-mitigation watch period

---

## 9) What Reduced Recurrence Risk

- Added change policy: avoid coupling high-risk network and performance-affecting deployment changes in one window.
- Added pre-prod validation checklist:
  - effective NSG path test for all approved source ranges
  - load baseline comparison before and after release
- Added incident runbook branch for asymmetric failures:
  - if one client region fails and another passes, prioritize policy/routing checks early.

---

## 10) Follow-Up Actions

- **CA-CX-001** (Owner: Platform Engineering, `done`, 2026-05-22)  
  Add combined change-risk flag in ticket template for concurrent network + app changes.

- **CA-CX-002** (Owner: Monitoring/SRE, `in_progress`, target 2026-05-30)  
  Add correlation panel in workbook: deployment timestamp + NSG changes + alert burst overlay.

- **CA-CX-003** (Owner: App Team, `done`, 2026-05-21)  
  Fix cache strategy regression and add load-test guardrail in pipeline.

- **CA-CX-004** (Owner: Change Management, `open`, target 2026-06-05)  
  Require explicit approval for dual high-risk change bundles in prod.

---

## 11) Lessons Learned

- Multi-factor incidents rarely present as clean, single-root-cause events.
- First alert is not always the primary cause.
- Asymmetric failures are strong indicators of policy/path issues.
- Recovery is faster when teams accept parallel hypotheses early, not sequential blame loops.

This incident is used as a reference for "messy incident handling" because it forced concurrent diagnosis across application, infrastructure policy, and performance domains.

---

## 12) Traceability Links (Incident Chain)

- incident record: `incident-complex.md` (`INC-2026-05-18-002`)
- detection signals:
  - CPU/service/network alert sequence documented in section 3 and section 6
  - alert evidence reference: `evidence/azure-monitor-alert-payload.json` (schema/source format)
- investigation evidence:
  - section 6 log snippets
  - `evidence/log-analytics-query-results.md`
- runbook references:
  - `runbooks/high-cpu.md`
  - `runbooks/network-issue.md`
  - `runbooks/nginx-down.md`
- mitigation/fix path:
  - NSG hotfix + rollback sequence in section 8
  - change governance reference: `change-lifecycle.md`
- follow-up ownership:
  - `corrective-actions.md` (mapped actions for incident classes and recurring controls)
- reliability impact references:
  - `operations-metrics.md`
  - `telemetry-trends.md`
  - `slo-month-analysis.md`
