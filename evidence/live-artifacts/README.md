# Live Artifact Pack (Simulated Tenant Exports)

This folder contains realistic, sanitized artifacts formatted to look like exports from an active Azure tenant over multiple weeks.

The dataset intentionally includes:

- non-identical event patterns over time
- false alerts and noisy windows
- delayed acknowledgments
- retry behavior and partial failures

## Artifact Index

## 1) Azure Monitor Alert History

- File: `azure-monitor-alert-history.csv`
- Proves:
  - alerting is active over time (not one isolated event)
  - severity distribution and acknowledgment latency are measurable
  - noise and duplicates are visible and managed
- How generated (real-world equivalent):
  - Azure Monitor Alerts export or API pull
  - enriched with incident IDs and acknowledgment source
- Interview usage:
  - show trend quality, not just one “good” alert
  - explain false positive handling and rule tuning
  - point out duplicate firings and delayed acknowledgments to show realistic on-call pressure

## 2) Log Analytics Query Exports

- File: `log-analytics-query-exports.md`
- Proves:
  - operators use KQL outputs during incidents
  - telemetry interpretation is grounded in timestamped evidence
- How generated (real-world equivalent):
  - run saved KQL queries in Log Analytics
  - export result tables for incident windows
- Interview usage:
  - walk from alert -> query -> fault-domain decision

## 3) Policy Compliance Evidence

- File: `policy-compliance-evidence.md`
- Proves:
  - policy enforcement is active and compliance posture changes over time
  - remediation and exemptions are traceable
- How generated (real-world equivalent):
  - Azure Policy compliance view export + assignment details
- Interview usage:
  - show denied resources, remediation cadence, and residual risk

## 4) Activity Log Timeline

- File: `activity-log-entries.csv`
- Proves:
  - infrastructure and policy changes are auditable with timestamps
  - incident windows can be correlated to control-plane changes
- How generated (real-world equivalent):
  - Azure Activity Log export filtered by resource group and operation category
- Interview usage:
  - correlate suspected change to incident onset and rollback
  - show one failed control-plane write followed by successful retry

## 5) Terraform Apply History

- File: `terraform-apply-history.csv`
- Proves:
  - multiple applies over time, not one-off deployment
  - operational outcomes include retries and partial failures
- How generated (real-world equivalent):
  - CI/CD workflow run exports + apply job logs
- Interview usage:
  - show change reliability trend and change-failure patterns
  - explain why failed apply attempts are expected and how guardrails prevented unsafe drift

## Time Span and Realism Profile

- timeline coverage: `2026-02` to `2026-05`
- includes:
  - false positives (agent heartbeat gap, external probe instability, red-team noise)
  - noisy duplicates during single incidents
  - partial failures (region/source-specific impact)
  - apply retries after transient provider/state issues
  - non-monotonic compliance trend (improvement with occasional regressions)

## Traceability by Incident

- `INC-2026-04-30-001`:
  - alerts: `azure-monitor-alert-history.csv` (ALRT-90230)
  - activity changes: `activity-log-entries.csv` (`CHG-4820`, rollback entry)
  - apply history: `terraform-apply-history.csv` (`run_id 10470290125`, `10470294488`)
  - query evidence: `log-analytics-query-exports.md` (heartbeat continuity section)
- `INC-2026-05-18-002`:
  - alerts: `azure-monitor-alert-history.csv` (ALRT-90311..ALRT-90313)
  - activity changes: `activity-log-entries.csv` (`CHG-4891`, incident hotfix entries)
  - apply history: `terraform-apply-history.csv` (`run_id 10486732044`, `10486736788`)
  - query evidence: `log-analytics-query-exports.md` (partial regional failure correlation)

## Suggested Presentation Sequence

1. `terraform-apply-history.csv` (change baseline)
2. `activity-log-entries.csv` (what changed in Azure)
3. `azure-monitor-alert-history.csv` (what fired and when)
4. `log-analytics-query-exports.md` (how fault was validated)
5. `policy-compliance-evidence.md` (how guardrails behaved)

## Important Note

These artifacts are simulated but intentionally shaped to mirror realistic tenant behavior and data quality issues.  
When live tenant exports are available, replace file contents with real captures while keeping the same structure.
