# Execution Evidence

This folder contains sanitized operational artifacts that document how the platform is executed and operated.

The goal is to preserve evidence quality suitable for incident review and audit discussions:

- outputs are truncated to relevant sections
- sensitive values are masked
- warnings/noise are preserved where useful
- data is representative, not "perfect demo output"

## Artifacts

## 1) Terraform Plan Output

- File: `terraform-plan-sanitized.txt`
- Proves:
  - infrastructure changes are reviewed before apply
  - plan includes concrete resource deltas and risk visibility
  - production-impacting changes are auditable
- Operations usage:
  - used in PR reviews and plan-approval gates
  - used by on-call/platform engineer to validate blast radius before change window

## 2) Terraform Apply Output

- File: `terraform-apply-sanitized.txt`
- Proves:
  - deployment was executed through CI/CD and completed successfully
  - resource creation/update timings are observable
  - post-apply outputs are captured for handover/troubleshooting
- Operations usage:
  - used for change records and rollback context
  - used during incident triage to correlate infra changes with outage windows

## 3) Azure Monitor Alert Payload

- File: `azure-monitor-alert-payload.json`
- Proves:
  - real alert schema and payload fields are understood
  - incident responders receive actionable metadata (resource, severity, condition)
- Operations usage:
  - drives incident routing (on-call, severity policy)
  - used by automation/webhooks or SOC tooling enrichment

## 4) Log Analytics Query Results

- File: `log-analytics-query-results.md`
- Proves:
  - KQL output interpretation skills beyond writing query syntax
  - ability to move from telemetry to incident decisions
- Operations usage:
  - used in active investigations (failed logins, heartbeat gaps, anomaly candidates)
  - supports incident timeline reconstruction and evidence capture

## 5) Incident Alert Message

- File: `incident-alert-message.txt`
- Proves:
  - incident communication quality and operational clarity
  - ability to summarize impact, owner, and immediate actions quickly
- Operations usage:
  - posted to Teams/Slack incident channel for coordinated response
  - anchors first 10-15 minutes of incident command flow

## 6) Longitudinal Live Artifact Pack

- Folder: `live-artifacts/`
- Proves:
  - operational behavior over time, not a single curated incident
  - realistic variation (noise, retries, false positives, clustered changes)
- Operations usage:
  - monthly reliability review
  - change-risk correlation and postmortem support

## 7) Realistic End-to-End Incident Walkthrough

- Folder: `incidents/realistic-end-to-end-scenario/`
- Proves:
  - end-to-end support workflow for a realistic VM CPU incident
  - explicit separation of real control implementation vs sanitized/simulated evidence
  - closure validation and prevention actions in support-oriented language
- Operations usage:
  - interview walkthrough: alert -> triage -> mitigation -> validation -> follow-up
  - reviewer validation of claim-to-code consistency

## Evidence Review Guidance

Use these artifacts in a sequence that matches real operations:

1. **Change intent and risk** -> show `terraform-plan-sanitized.txt`
2. **Change execution proof** -> show `terraform-apply-sanitized.txt`
3. **Detection signal** -> show `azure-monitor-alert-payload.json`
4. **Investigation evidence** -> show `log-analytics-query-results.md`
5. **Response coordination** -> show `incident-alert-message.txt`

## Incident Linkage

Use evidence with explicit incident linkage instead of standalone screenshots.

- `incident-postmortem.md` consumes:
  - `azure-monitor-alert-payload.json`
  - `log-analytics-query-results.md`
  - `terraform-apply-sanitized.txt`
  - `incident-alert-message.txt`
- `incident-complex.md` consumes:
  - alert timeline and payload excerpts
  - query and log snippets aligned to mitigation steps
  - change execution references in `change-lifecycle.md`

Related operational references:

- runbooks: `runbooks/`
- metrics: `operations-metrics.md`
- SLO impact: `slo-month-analysis.md`
- follow-up ownership: `corrective-actions.md`

Talking points that work well:

- what signal triggered response
- what change happened before impact
- what data confirmed root cause
- how rollback/fix was executed safely
- what control was added to prevent recurrence
