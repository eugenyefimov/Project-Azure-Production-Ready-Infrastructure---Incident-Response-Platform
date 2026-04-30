# Ownership and Accountability Matrix

This matrix defines who owns critical platform domains and how accountability is tracked for improvement work.

## 1) System Ownership Matrix

## Monitoring

- **Owner:** Monitoring/SRE Lead
- **Responsibility:**
  - alert quality and severity mapping
  - dashboard/workbook maintenance
  - incident signal coverage and tuning
  - monthly telemetry trend review
- **Review cadence:** weekly alert review + monthly reliability review

## Network

- **Owner:** Platform Network Engineer
- **Responsibility:**
  - NSG/route policy changes and validation
  - connectivity guardrails and smoke checks
  - network incident triage and postmortem actions
  - change risk assessment for ingress/egress updates
- **Review cadence:** per change window + monthly control audit

## CI/CD

- **Owner:** DevOps Platform Engineer
- **Responsibility:**
  - Terraform workflow health and approval gates
  - artifact integrity and apply reliability
  - credential/OIDC pipeline security posture
  - pipeline failure trend and remediation
- **Review cadence:** weekly pipeline health review + monthly control verification

## Governance

- **Owner:** Cloud Security Engineer
- **Responsibility:**
  - policy definition and assignment lifecycle
  - compliance monitoring and exception governance
  - policy regression prevention in new changes
  - monthly compliance reporting
- **Review cadence:** weekly exception review + monthly policy compliance report

---

## 2) Improvement Accountability Tracker

Status values:

- `open`
- `in_progress`
- `done`
- `blocked`

## Active Improvements

| Improvement ID | Improvement | Owner | Deadline | Status | Evidence Link |
| --- | --- | --- | --- | --- | --- |
| IMP-001 | Automate monthly SLO/error-budget report generation | Monitoring/SRE Lead | 2026-06-07 | in_progress | `slo-error-budget.md` |
| IMP-002 | Add high-risk NSG Activity Log alert with severity routing | Monitoring/SRE Lead | 2026-05-30 | in_progress | `corrective-actions.md` |
| IMP-003 | Enforce pre-apply connectivity checks for prod critical ports | Platform Network Engineer | 2026-05-24 | done | `change-lifecycle.md` |
| IMP-004 | Add policy exemption register with owner + expiry tracking | Cloud Security Engineer | 2026-06-14 | open | `docs/handbook/governance.md` |
| IMP-005 | Add alert noise ratio auto-report and stale-rule cleanup list | Monitoring/SRE Lead | 2026-06-21 | open | `telemetry-trends.md` |
| IMP-006 | Add CI check for policy definition JSON and assignment validation | DevOps Platform Engineer | 2026-06-05 | in_progress | `docs/terraform-github-actions.md` |
| IMP-007 | Add incident evidence checklist enforcement at closure | Incident Manager | 2026-05-28 | done | `docs/handbook/incidents.md` |
| IMP-008 | Add monthly corrective action closure review | Platform Lead | 2026-05-31 | in_progress | `corrective-actions.md` |
| IMP-009 | Add DNS synthetic checks for critical FQDNs in prod | Platform Network Engineer | 2026-06-12 | in_progress | `incident-complex.md` |
| IMP-010 | Add deployment+network combined change risk flag in ticket template | Change Manager | 2026-05-26 | done | `change-lifecycle.md` |

## Recently Completed Improvements

| Improvement ID | Improvement | Owner | Completion Date | Evidence Link | Outcome |
| --- | --- | --- | --- | --- | --- |
| IMP-C01 | Governance policies moved from documentation to enforced Terraform assignments | Cloud Security Engineer | 2026-04-30 | `docs/handbook/governance.md` | Preventive controls now block non-compliant changes at apply time |
| IMP-C02 | Runbook update for asymmetric failure triage path | Platform Operations Engineer | 2026-05-21 | `incident-complex.md` | Faster fault-domain isolation for mixed symptom incidents |
| IMP-C03 | Production apply protections tightened with explicit approval phrase | DevOps Platform Engineer | 2026-04-30 | `docs/terraform-github-actions.md` | Reduced accidental production mutation risk |

---

## 3) Ownership Escalation Rules

- If owner does not update status by deadline, escalate to domain lead within 2 business days.
- If improvement remains `blocked` for more than 10 business days, escalate to platform manager with unblock plan.
- High-severity incident corrective actions (`Sev1`) must have owner and deadline within 48 hours of incident closure.

---

## 4) Why Ownership Prevents Operational Failures

Without explicit ownership:

- recurring issues stay "known" but unfixed
- alert quality decays because no one is accountable for tuning
- policy exceptions become permanent and unaudited
- postmortem actions stall and incident classes repeat

With explicit ownership and cadence:

- every domain has a named accountable engineer
- improvements are time-bound and reviewable
- evidence links make completion verifiable
- incident learnings convert into durable controls

Ownership is the mechanism that turns incident findings into long-term reliability improvement.
