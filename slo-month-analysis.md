# SLO Monthly Analysis (Example Walkthrough)

## Reporting Period

- **Month:** April 2026
- **Service:** `customer-api` (`prod`)
- **Primary SLO:** `99.5%` monthly availability
- **Total minutes in month (30 days):** `43,200`
- **Allowed error budget:** `216 minutes`

## 1) Availability and Budget Summary

- **Measured availability:** `99.56%`
- **Total user-impacting downtime/degradation counted:** `189 minutes`
- **Budget consumed:** `87.5%` (`189 / 216`)
- **Budget remaining:** `27 minutes`

Interpretation:

- SLO was technically met.
- Reliability margin was very low by month end.
- Change risk tolerance was reduced in final week due to near-breach trajectory.

---

## 2) Incidents Affecting Availability

| Incident ID | Date (UTC) | Duration Counted (min) | Class | Primary Trigger | Notes |
| --- | --- | ---: | --- | --- | --- |
| INC-2026-04-05-002 | 2026-04-05 | 18 | Availability (partial) | heartbeat + service probe mismatch | short-lived degradation, partly false-signal overlap |
| INC-2026-04-09-005 | 2026-04-09 | 27 | Dependency / Cert | service availability alert | certificate chain issue at edge |
| INC-2026-04-14-006 | 2026-04-14 | 24 | Performance | CPU anomaly + high latency | ETL/backup overlap amplified load |
| INC-2026-04-19-007 | 2026-04-19 | 41 | Dependency / DNS | service availability alert | upstream DNS timeout cascade |
| INC-2026-04-30-001 | 2026-04-30 | 79 | Network policy | service availability + network path alert | NSG precedence regression |

Total counted: **189 minutes**

---

## 3) Error Budget Consumption Timeline

## Week 1 (Apr 1-7)

- cumulative burn: **18 min** (`8.3%`)
- posture: healthy
- action: continue planned change schedule

## Week 2 (Apr 8-14)

- additional burn: **51 min**
- cumulative burn: **69 min** (`31.9%`)
- posture: manageable but rising
- action: flagged performance and dependency controls for tuning

## Week 3 (Apr 15-21)

- additional burn: **41 min**
- cumulative burn: **110 min** (`50.9%`)
- posture: warning threshold crossed before month end
- action: increased change review strictness and required explicit risk notes

## Week 4 (Apr 22-30)

- additional burn: **79 min**
- cumulative burn: **189 min** (`87.5%`)
- posture: near-breach
- action: non-essential production changes slowed/frozen pending stabilization checks

---

## 4) Near-Breach Scenario and Decision

Near-breach point:

- date: `2026-04-30`
- cumulative burn reached `87.5%`
- remaining budget (`27 min`) was insufficient for normal end-of-month risk

Decision made:

- defer non-critical production changes for remaining cycle window
- keep break/fix and approved risk-reduction changes only
- require incident commander involvement for any Sev1/Sev2-triggering change path

Why:

- preserving remaining budget reduced chance of crossing `100%` and missing SLO
- high-risk network and dependency changes had shown repeated impact patterns this month

---

## 5) Alert Triggers and Incident Signals Used

Primary alert families involved:

- `alert-service-availability-endpoint` (`Sev1`)
- `alert-vm-high-cpu-anomaly` (`Sev2`)
- `alert-network-path-failure` (`Sev2`)

Representative trigger snippet (sanitized):

```text
2026-04-30T00:18:26Z rule=alert-service-availability-endpoint severity=Sev1 state=Fired
target=az-ir-platform-p-westeurope-vm-app-01 failed_regions=eu-2,eu-3
```

```text
2026-04-29T14:08:20Z rule=alert-vm-high-cpu-anomaly severity=Sev2 state=Fired
resource=az-ir-platform-p-westeurope-vm-app-01 deviation_ratio=2.31
```

---

## 6) Incident Log Correlation (Monthly)

Correlation findings from logs and change data:

- service-impact incidents clustered near configuration and network policy changes
- one major outage had mixed-fault characteristics (policy + load behavior)
- false positive alerts existed but did not account for the majority of budget burn

Representative incident-log evidence:

```text
2026-04-30T00:14:07Z ActivityLog: NSG write succeeded (CHG-4820)
2026-04-30T00:18:26Z Alert: service availability fired (Sev1)
2026-04-30T00:33:09Z ActivityLog: NSG rollback write succeeded (INC-2026-04-30-001)
```

---

## 7) Follow-Up Actions from Monthly Review

| Action ID | Action | Owner | Status | Target Date | Linked Domain |
| --- | --- | --- | --- | --- | --- |
| SLO-A01 | Enforce pre-apply connectivity validation on all prod network changes | Platform Engineering | done | 2026-05-05 | config / network |
| SLO-A02 | Add high-risk NSG write alert with direct escalation routing | Monitoring/SRE | in_progress | 2026-05-30 | monitoring |
| SLO-A03 | Add DNS synthetic checks for critical dependencies | Platform Network Engineer | in_progress | 2026-06-12 | monitoring / dependency |
| SLO-A04 | Add monthly error-budget review gate before approving non-essential prod changes | Platform Lead | done | 2026-05-03 | governance / process |
| SLO-A05 | Reduce alert noise on low-value rules and track noise ratio trend | Monitoring/SRE | in_progress | 2026-06-21 | monitoring |

---

## 8) How SLO Affected Engineering Decisions

SLO changed behavior in concrete ways:

1. **Change pacing**
   - When burn passed 50% mid-month, change review tightened.
   - Near 90%, non-essential changes were deferred.

2. **Prioritization**
   - Reliability controls were prioritized over feature or infrastructure expansion work.
   - Engineering capacity shifted to recurrence reduction.

3. **Escalation discipline**
   - High-severity events triggered earlier incident-command involvement.
   - Response quality improved because ownership and decision points were explicit.

4. **Control investment**
   - Monitoring, policy enforcement, and pre-change validation received direct investment because they showed measurable budget impact.

SLO in practice:

- it is not just a reporting metric
- it is a decision framework for risk, pacing, and engineering focus

---

## 9) Month-End Conclusion

- SLO target was met, but with low safety margin.
- A single additional medium outage could have caused a breach.
- The key operational takeaway was to treat reliability budget as a finite resource and actively govern change risk as budget burns.
