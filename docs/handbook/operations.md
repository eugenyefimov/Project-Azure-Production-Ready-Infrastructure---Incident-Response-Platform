# Operations

## Delivery and Change Control

- CI/CD runs per environment with dedicated workflows:
  - `.github/workflows/terraform-dev.yml`
  - `.github/workflows/terraform-staging.yml`
  - `.github/workflows/terraform-prod.yml`
- Standard flow:
  - `fmt` -> `validate` -> optional security scan -> `plan` -> plan approval -> `apply`
- Production protections:
  - no automatic apply on push
  - manual dispatch + explicit production confirmation
  - protected GitHub environment approvals

Detailed pipeline reference:

- `docs/terraform-github-actions.md`

## Monitoring and Telemetry Operations

Operational monitoring goals:

- detect customer-impacting incidents in under 5 minutes
- maintain on-call acknowledgment within 5 minutes for high severity alerts
- reduce alert noise through continuous tuning

Primary evidence sources:

- Azure Monitor alert history
- Log Analytics query results
- workbook trend views
- incident channel timestamps

Evidence artifacts:

- `monitoring.md`
- `evidence/azure-monitor-alert-payload.json`
- `evidence/log-analytics-query-results.md`
- `telemetry-trends.md`

Traceability requirement:

- every high-severity incident must keep linkable artifacts from alert -> logs -> fix execution -> corrective follow-up
- required references are recorded in:
  - `docs/handbook/incidents.md`
  - `incident-postmortem.md`
  - `incident-complex.md`
  - `corrective-actions.md`

## Recovery and Continuity

- VM backup protection via Recovery Services Vault
- regular restore verification to validate recoverability
- recovery evidence captured in incident/change records

Recovery runbooks:

- `vm-recovery.md`
- `backup-verification.md`

## Metrics and Trend Review

Operational KPI tracking:

- incident frequency (weekly/monthly)
- MTTD / MTTA / MTTR ranges and percentiles
- alert noise ratio

Trend interpretation and limitations:

- `operations-metrics.md`
- `telemetry-trends.md`
- `slo-error-budget.md`
- `slo-month-analysis.md`
- `next-steps.md`
- `ops-timeline.md`
- `ownership-matrix.md`

Metrics must remain traceable to incident artifacts:

- MTTD/MTTA/MTTR claims should map to concrete alert and incident timestamps
- noise-ratio and false-positive claims should map to alert-history exports
- SLO impact statements should map to incident IDs and recovery windows

## Operational Cadence

- weekly: alert quality and incident triage review
- monthly: reliability trend and control effectiveness review
- quarterly: governance and recovery control audit
