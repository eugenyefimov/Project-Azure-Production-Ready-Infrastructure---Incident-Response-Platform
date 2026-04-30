# Platform Handbook

This handbook is the primary operational documentation set for the platform.

## Sections

- `docs/handbook/architecture.md`
- `docs/handbook/operations.md`
- `docs/handbook/governance.md`
- `docs/handbook/incidents.md`

## Usage

- Start with `architecture.md` for platform scope and boundaries.
- Use `operations.md` for day-to-day delivery, monitoring, and recovery operations.
- Use `docs/handbook/governance.md` for enforced policy controls and compliance behavior.
- Use `incidents.md` for incident workflow, response artifacts, and post-incident actions.

## Supporting Artifacts

- Evidence package: `evidence/`
- Runbooks: `runbooks/`
- CI/CD workflow details: `docs/terraform-github-actions.md`

## Traceability Map

Use this chain for operational traceability:

- incident record: `incident-postmortem.md` or `incident-complex.md`
- detection signal: `evidence/azure-monitor-alert-payload.json`
- investigation data: `evidence/log-analytics-query-results.md`
- mitigation/fix execution: `change-lifecycle.md` and `evidence/terraform-apply-sanitized.txt`
- follow-up ownership: `corrective-actions.md`
- reliability impact: `operations-metrics.md` and `slo-month-analysis.md`
