# Incidents

## Incident Operating Model

Standard response flow:

1. detect (alert or customer signal)
2. acknowledge and assign owner
3. triage by fault domain (network, compute, app, dependency)
4. mitigate and recover through controlled change path
5. validate recovery and run watch window
6. record post-incident actions and owners

## Severity and Escalation

- `Sev1`: full outage or major customer-facing degradation
- `Sev2`: significant partial impact or major performance degradation
- `Sev3`: limited impact, noisy warnings, or single-customer issues
- `Sev4`: informational events (including planned maintenance)

- escalation to incident commander when:
  - customer impact is ongoing, and
  - first-line triage cannot isolate issue quickly, or
  - production control-plane/network changes are implicated

Status labels used in incident evidence:

- **Implemented**: control path exists in Terraform/workflow/runbook code
- **Partial**: control exists but rollout/activation is optional or incomplete
- **Simulated/Sanitized**: artifact is redacted or sample-shaped for public sharing
- **Planned**: documented improvement not yet implemented

## Primary Incident References

- Postmortem record: `incident-postmortem.md`
- Complex multi-factor incident: `incident-complex.md`
- Change execution example: `change-lifecycle.md`
- Corrective action tracking: `corrective-actions.md`
- Evidence package: `evidence/`
- Runbooks: `runbooks/`

## Traceability Chains

### Chain A: `INC-2026-04-30-001` (NSG precedence outage)

- incident: `incident-postmortem.md`
- alert: `evidence/azure-monitor-alert-payload.json`
- logs and query evidence: `evidence/log-analytics-query-results.md`
- primary runbook path: `runbooks/vm-not-reachable.md` and `runbooks/network-issue.md`
- fix/change execution: `change-lifecycle.md` and `evidence/terraform-apply-sanitized.txt`
- follow-up and ownership: `corrective-actions.md` (`CA-011`, `CA-012`, `CA-013`)
- metric impact: `operations-metrics.md`, `slo-month-analysis.md`

### Chain B: `INC-2026-05-18-002` (multi-factor incident)

- incident: `incident-complex.md`
- alerts: CPU/service/network sequence documented in `incident-complex.md`
- logs and query evidence: `evidence/log-analytics-query-results.md`
- runbook path: `runbooks/high-cpu.md`, `runbooks/network-issue.md`, `runbooks/nginx-down.md`
- fix/change execution: `change-lifecycle.md`
- follow-up and ownership: `corrective-actions.md` (`CA-CX-001` to `CA-CX-004` noted in incident record)
- metric impact: `operations-metrics.md`, `telemetry-trends.md`, `slo-month-analysis.md`

## Runbook Set

- `runbooks/vm-not-reachable.md`
- `runbooks/ssh-failure.md`
- `runbooks/rdp-failure.md`
- `runbooks/nginx-down.md`
- `runbooks/high-cpu.md`
- `runbooks/network-issue.md`
- `runbooks/dns-issue.md`

## Required Incident Evidence

For high-severity events, keep:

- alert payload and timestamps
- investigation queries/results
- command trail used during triage
- mitigation/apply logs
- validation checks and closure criteria

Available examples:

- `evidence/terraform-plan-sanitized.txt`
- `evidence/terraform-apply-sanitized.txt`
- `evidence/azure-monitor-alert-payload.json`
- `evidence/log-analytics-query-results.md`
- `evidence/incident-alert-message.txt`

## Post-Incident Follow-Up

Every major incident should produce:

- root cause statement with contributing factors
- owner-assigned preventive tasks with deadlines
- runbook or monitor updates for detected gaps
- trend impact update in operations metrics review
- explicit artifact links from incident -> alert -> logs -> fix -> follow-up
