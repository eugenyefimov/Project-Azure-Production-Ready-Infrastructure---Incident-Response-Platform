# Azure Infrastructure & Incident Response Platform

## How to Navigate This Project

Follow this path when reviewing the platform as an operational system:

1. **Architecture and operating model**
   - `docs/handbook/README.md`
   - `docs/handbook/architecture.md`
   - `docs/handbook/operations.md`
2. **Live incident flow (end-to-end traceability)**
   - `docs/handbook/incidents.md`
   - `incident-postmortem.md`
   - `incident-complex.md`
   - `corrective-actions.md`
3. **Signal and evidence chain**
   - `monitoring.md`
   - `evidence/README.md`
   - `evidence/log-analytics-query-results.md`
4. **Reliability outcomes**
   - `operations-metrics.md`
   - `slo-error-budget.md`
   - `slo-month-analysis.md`
   - `telemetry-trends.md`

Fast interview walkthrough:

- Start at `incident-postmortem.md` and follow links from alert -> logs -> fix -> follow-up.
- Cross-check with `evidence/README.md` for artifacts.
- Confirm outcomes in `operations-metrics.md` and SLO docs.

## Handbook Navigation

Primary documentation is consolidated under:

- `docs/handbook/README.md`
- `docs/handbook/architecture.md`
- `docs/handbook/operations.md`
- `docs/handbook/governance.md`
- `docs/handbook/incidents.md`

## Supporting References

- CI/CD implementation: `docs/terraform-github-actions.md`
- Incident and execution evidence: `evidence/README.md`
- Operational runbooks: `runbooks/`
- Module-specific technical notes: `modules/*/README.md`
