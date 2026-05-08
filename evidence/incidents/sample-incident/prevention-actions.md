# Prevention Actions (Sample)

Prevention items must be concrete and tied to repo changes (runbook, monitoring, or CI/CD guardrails).

## Near-term (1-2 weeks)

### 1) Improve CPU triage instructions with process-level evidence
- Owner: SRE on-call rotation
- Update: `runbooks/high-cpu.md`
- Target date: `2026-05-22`
- Why: Reduce time-to-top-consumer when the first mitigation step is insufficient.

### 2) Add a second differentiator query to rule out host saturation vs service regression
- Owner: Platform / Monitoring owner
- Update: documentation in `evidence/log-analytics-query-results.md`
- Target date: `2026-05-22`
- Why: Make “CPU is falling but service still down” scenarios easier to classify quickly.

### 3) Add alert tuning backlog tracking (avoid threshold sprawl)
- Owner: Monitoring owner
- Update: `alert-tuning.md` plus link new alert runbook mapping
- Target date: `2026-05-30`

## Medium-term (1-2 months)

### 4) Add pre-change load validation into the change workflow
- Owner: Platform Engineering
- Update: `change-lifecycle.md` and/or incident evidence template usage
- Target date: `2026-06-20`
- Why: Prevent known load bursts from crossing thresholds during planned changes.

