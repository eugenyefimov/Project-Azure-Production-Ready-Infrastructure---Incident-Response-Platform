# Immutable Incident Evidence Index

This index links incident evidence by immutable IDs so each case can be traced end-to-end:

`alert -> logs -> change -> fix -> follow-up`

Use this file as the first stop for audit, incident review, and interview validation.

## Incident 1: `INC-2026-03-06-001` (NSG precedence outage)

- **Alert IDs:**
  - `ALRT-90018` (primary)
  - `ALRT-90019` (duplicate)
  - source: `evidence/live-artifacts/azure-monitor-alert-history.csv`
- **Azure Activity Log correlation IDs:**
  - `2e56c0d4-1a99-4eb6-a565-2d56586f8705` (change introduced)
  - `69f51ef9-c972-4f95-9362-1e7a01af5ab8` (hotfix rollback apply)
  - source: `evidence/live-artifacts/activity-log-entries.csv`
- **Log Analytics query references:**
  - `evidence/log-analytics-query-results.md` (heartbeat healthy + path failure context)
  - `evidence/live-artifacts/log-analytics-query-exports.md` -> `Export B` (heartbeat continuity pattern)
- **CI/CD run IDs:**
  - `10408977122` (pre-outage change)
  - `10408977431` (incident rollback apply)
  - source: `evidence/live-artifacts/terraform-apply-history.csv`
- **Change/PR reference:**
  - change ticket: `CHG-4733`
  - incident change lifecycle reference: `change-lifecycle.md`
- **Corrective action IDs:**
  - `CA-001`, `CA-002`, `CA-003`, `CA-004`
  - source: `corrective-actions.md`

Chain:

- `ALRT-90018` -> Log Analytics + effective NSG evidence -> `CHG-4733` rollback (`run_id: 10408977431`) -> follow-up `CA-001..CA-004`

---

## Incident 2: `INC-2026-04-30-001` (NSG regression repeat)

- **Alert IDs:**
  - `ALRT-90230` (primary)
  - source: `evidence/live-artifacts/azure-monitor-alert-history.csv`
- **Azure Activity Log correlation IDs:**
  - `7d2d12de-8a2e-4d39-a4c9-bf99b8432f90` (regression introduced)
  - `73768477-c913-424b-af7d-f0af9321ff1f` (rollback fix)
  - source: `evidence/live-artifacts/activity-log-entries.csv`
- **Log Analytics query references:**
  - `incident-postmortem.md` section `Investigation Evidence (Logs + Queries Used)`
  - `evidence/log-analytics-query-results.md`
  - `evidence/live-artifacts/log-analytics-query-exports.md` -> `Export B`
- **CI/CD run IDs:**
  - `10470290125` (faulty NSG change path)
  - `10470294488` (incident rollback apply)
  - source: `evidence/live-artifacts/terraform-apply-history.csv`
- **Change/PR reference:**
  - PR `infra/network-rules-245` (introducing change)
  - PR `hotfix/nsg-priority-override` (incident hotfix)
  - change ticket `CHG-4820`
  - sources: `incident-postmortem.md`, `evidence/live-artifacts/activity-log-entries.csv`
- **Corrective action IDs:**
  - `CA-011`, `CA-012`, `CA-013`
  - source: `corrective-actions.md`

Chain:

- `ALRT-90230` -> heartbeat/query evidence + NSG effective rule check -> rollback (`correlation_id: 73768477-...`, `run_id: 10470294488`) -> follow-up `CA-011..CA-013`

---

## Incident 3: `INC-2026-05-18-002` (deployment + NSG + CPU multi-factor)

- **Alert IDs:**
  - `ALRT-90311` (CPU symptom)
  - `ALRT-90312` (availability impact)
  - `ALRT-90313` (network-path signal)
  - `ALRT-90314` (duplicate network-path fire)
  - source: `evidence/live-artifacts/azure-monitor-alert-history.csv`
- **Azure Activity Log correlation IDs:**
  - `e15653c1-478d-4340-b2d3-979fd336bbc6` (fault-inducing NSG write)
  - `c703c664-a4a2-4402-acb2-a6274f2f7548` (NSG hotfix; duplicate success event recorded)
  - `e1a9042b-34d3-49d1-a8cd-08927176b8ce` (rollback image write)
  - source: `evidence/live-artifacts/activity-log-entries.csv`
- **Log Analytics query references:**
  - `incident-complex.md` section `Evidence (Alerts, Logs, Commands)`
  - `evidence/incidents/raw-incident-01/03-log-analytics-raw-results.txt`
  - `evidence/live-artifacts/log-analytics-query-exports.md` -> `Export E`
- **CI/CD run IDs:**
  - `10486732044` (pre-incident release apply)
  - `10486736788` (dual mitigation apply)
  - `10486736910` (duplicate manual dispatch canceled)
  - source: `evidence/live-artifacts/terraform-apply-history.csv`
- **Change/PR reference:**
  - change ticket `CHG-4891` (introducing change)
  - PR `hotfix/nsg-cidr-restore` (incident hotfix)
  - rollback release ref `REL-2026.05.17.7`
  - sources: `incident-complex.md`, `promotion-lifecycle.md`
- **Corrective action IDs:**
  - `CA-CX-001`, `CA-CX-002`, `CA-CX-003`, `CA-CX-004`
  - source: `incident-complex.md`

Chain:

- `ALRT-90311/90312` -> pivot via `ALRT-90313` + deny-hit logs -> dual mitigation (`run_id: 10486736788`) -> follow-up `CA-CX-001..004`

---

## How Correlation IDs Are Used In Real Systems

Correlation IDs are the join key across otherwise separate telemetry systems.

- **Activity Log correlation ID** ties one control-plane operation to retries/replays and downstream effects.
- **Alert IDs** tie detection events to incident timelines and paging behavior.
- **CI/CD run IDs** tie infra mutation to exact commit, actor, and approval path.
- **Incident IDs** tie technical evidence to response ownership and corrective closure.

In practice, responders do not trust timestamps alone (clock skew, delayed ingestion, duplicate emissions).  
They use IDs to join evidence confidently even when logs are messy.

---

## Example Investigation Path (Using This Index)

Example: investigate `INC-2026-05-18-002`.

1. Start from alert IDs `ALRT-90311..90314` in `evidence/live-artifacts/azure-monitor-alert-history.csv`.
2. Pivot to activity entries by change ticket/correlation IDs:
   - `e15653c1-...` (introducing write)
   - `c703c664-...` (hotfix write)
3. Validate fault signal in `evidence/incidents/raw-incident-01/03-log-analytics-raw-results.txt` and `Export E`.
4. Confirm remediation run in `evidence/live-artifacts/terraform-apply-history.csv` (`10486736788`), and canceled duplicate dispatch `10486736910`.
5. Confirm closure controls in `incident-complex.md` and follow-up IDs `CA-CX-001..004`.

Result:

- this path proves the incident is not narrative-only; it is reconstructable from immutable IDs across alerting, Azure control-plane events, query evidence, and CI/CD execution.
