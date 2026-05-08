# Incident Evidence Template (Production-Style)

This template defines a repeatable evidence framework for incidents in this repository.

Purpose:
- Make incidents reconstructable from artifacts (alert -> logs -> change -> mitigation -> validation).
- Reduce “story-only” incident writeups.
- Give support engineers something concrete to verify during audit/review.

## Incident ID, severity, and scope

Fill these fields first. Keep naming consistent across the repo.

### Required fields

- **Incident ID**: `INC-YYYY-MM-DD-XXX`
- **Environment**: `dev` | `staging` | `prod`
- **Service / Workload**:
  - `customer-api` (Linux VM + Nginx baseline)
  - `management` (Windows management VM)
  - `platform-control-plane` (network/governance incidents)
- **Severity**: `Sev1` | `Sev2` | `Sev3` | `Sev4`
  - `Sev1`: full outage or major customer-facing degradation
  - `Sev2`: significant partial impact or major performance degradation
  - `Sev3`: limited impact, noisy warnings, or single-customer issues
  - `Sev4`: informational / planned maintenance
- **Business impact (assessment)**:
  - what broke (availability / performance / security signal)
  - who was affected (external customers vs internal ops)
  - duration estimate (minutes, with uncertainty if applicable)
  - any measurable risk (SLA risk, error-rate, auth lockouts, etc.)

### Escalation timestamps (required)

Use ISO-8601 UTC timestamps and record when ownership changes.

- **Incident declared**: `YYYY-MM-DDTHH:MM:SSZ`
- **First high-confidence alert** (MTTD anchor): `YYYY-MM-DDTHH:MM:SSZ`
- **On-call acknowledgement** (MTTA anchor): `YYYY-MM-DDTHH:MM:SSZ`
- **Escalated to incident commander** (if applicable): `YYYY-MM-DDTHH:MM:SSZ` or `N/A`
- **Escalated to duty manager** (if applicable): `YYYY-MM-DDTHH:MM:SSZ` or `N/A`
- **Service considered stable again** (MTTR anchor): `YYYY-MM-DDTHH:MM:SSZ`

## Metrics (required)

This repo uses operational time-to-response metrics to keep writeups comparable.

Definitions:
- **MTTD**: `alert_trigger_time - incident_start_time`  
  (incident_start_time is your earliest observable impact signal)
- **MTTA**: `oncall_ack_time - alert_trigger_time`
- **MTTR**: `service_stable_time - oncall_ack_time`

Record:
- **MTTD**: `X minutes`
- **MTTA**: `Y minutes`
- **MTTR**: `Z minutes`

## File-level contract (required set)

Every incident evidence package should be created under `evidence/incidents/<incident-id>/`.
Create these files (the names are fixed for reviewers):

- `alert-payload.md`
- `timeline.md`
- `kql-analysis.md`
- `mitigation-actions.md`
- `root-cause-analysis.md`
- `recovery-validation.md`
- `lessons-learned.md`
- `prevention-actions.md`

### 1) alert-payload.md
What to include:
- Alert rule name and severity.
- Alert IDs (if available in artifacts).
- Fired time, affected resource name, and any runbook routing hints.
- If the alert is synthetic/service-level, include the probe identity.

Include a code block with the alert payload schema excerpt or a simplified JSON view.

### 2) timeline.md
What to include:
- Minute-by-minute or step-by-step narrative.
- The ownership transitions with timestamps:
  - on-call -> incident commander
  - incident commander -> duty manager (if used)
  - mitigation actions start/end
  - validation checks start/end

Keep entries short and operationally specific.

### 3) kql-analysis.md
What to include:
- KQL used for triage (copy/paste snippets).
- Queries should be scoped by:
  - environment (if present)
  - time window around incident start
  - the primary fault domain (network/compute/app/dependency)
- Expected outputs:
  - identify “what failed first”
  - identify “what remained healthy”

Include at least 2 queries:
- one “signal” query (symptom)
- one “differentiator” query (rules out a common false hypothesis)

### 4) mitigation-actions.md
What to include:
- What action was taken, by whom (role is enough), and why.
- Whether the action was:
  - rollback
  - capacity mitigation
  - network/security correction
  - service restart/config fix
- Include CLI/command snippets only when they materially help audit.

### 5) root-cause-analysis.md
What to include:
- A single root cause statement (1–2 sentences).
- Contributing factors (bullets).
- Why safeguards failed or were insufficient.
- Include the specific change or config event correlation when known.

### 6) recovery-validation.md
What to include:
- The validation checklist and closure criteria.
- Evidence links:
  - Log Analytics query outputs
  - Azure Activity Log references (if applicable)
  - any post-mitigation alert silence / stable checks
- Use a “pass/fail” style checklist with timestamps.

### 7) lessons-learned.md
What to include:
- What worked operationally (detection/triage/communication).
- What slowed down recovery (decision delays, missing evidence, noisy alerts).
- What must change in how the team handles this class of issue.

### 8) prevention-actions.md
What to include:
- Concrete prevention items tied to owners and target dates.
- Prefer improvements that are:
  - automation
  - alert tuning + dedup rules
  - runbook updates
  - governance policy tightening
- Each prevention item must reference either:
  - a repo file to update, or
  - a Terraform module change, or
  - a CI/CD workflow change.

## Evidence quality rules (non-negotiable)

- Every “we observed X” statement should be supported by:
  - a query result snippet, or
  - an alert history row, or
  - an activity log event, or
  - a command output excerpt.
- If evidence is simulated/sanitized, label it explicitly (do not present it as live tenant telemetry).
- Avoid “we think” unless accompanied by a differentiator query result.

