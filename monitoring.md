# Monitoring Operations (Imperfect by Design)

This document records how monitoring behaves in real operations, including false alerts, noisy signals, and partial failures.

## Operational Targets

- detect customer-impacting availability events in under 5 minutes
- acknowledge `Sev1/Sev2` alerts in under 5 minutes
- keep noise ratio low enough to protect on-call response quality without hiding weak signals

## Why Synthetic Checks Matter

Infrastructure-level health does not guarantee service-level health:

- A VM can be "up" (`VmAvailabilityMetric` healthy) while Nginx is down, blocked, or returning errors.
- Host metrics can stay normal while users still see outages caused by TLS, DNS, NSG changes, or app process failures.

Synthetic checks close this gap by validating the customer-facing HTTP path directly at regular intervals.

## Alert Catalogue (Current Baseline)

### VM / Host Level

- `alert-vm-availability` (`Sev1`):
  - Scope: application + management VMs.
  - Signal: `VmAvailabilityMetric` below healthy state.
  - Purpose: catch VM-level outages or hard failures.
  - Runbooks: `runbooks/vm-not-reachable.md`, `runbooks/network-issue.md`.

- `alert-vm-high-cpu` (`Sev2`):
  - Scope: application + management VMs.
  - Signal: `Percentage CPU` above configurable threshold for 5 minutes.
  - Purpose: detect resource saturation and hot paths.
  - Runbooks: `runbooks/high-cpu.md`, `runbooks/nginx-down.md` (when CPU under-load is symptom).

- `alert-vm-low-disk-space` (`Sev2`):
  - Scope: application + management VMs.
  - Signal: `OS Disk Used Percentage` > 90% for 15 minutes.
  - Purpose: early warning before disk-full outages and backup / logging failures.
  - Runbooks: `runbooks/vm-not-reachable.md`, `runbooks/nginx-down.md`.

### Service / Path Level (Synthetic)

- `alert-service-availability-endpoint` (`Sev1`):
  - Scope: customer-facing HTTPS endpoint on app VM.
  - Signal: Application Insights web test fails in at least 2 probe locations in the 15-minute window.
  - Purpose: detect "service down" even when host metrics look normal (NSG/DNS/etc.).
  - Runbooks: `runbooks/vm-not-reachable.md`, `runbooks/network-issue.md`, `runbooks/nginx-down.md`.

- `alert-service-synthetic-latency-high` (`Sev2`):
  - Scope: same synthetic endpoint.
  - Signal: average synthetic latency across the last 15 minutes exceeds threshold (default `2000ms`).
  - Purpose: detect brownouts before hard downtime.
  - Runbooks: `runbooks/high-cpu.md`, `runbooks/nginx-down.md`.

Synthetic checks are configured against a single high-value Nginx endpoint and intentionally remain small in scale to fit this platform.

## False Alerts We See

Common patterns:

- heartbeat gaps without customer impact
- one probe region failing while others remain healthy
- approved security tests triggering auth anomaly rules when test tags are missing

Handling model:

- classify as false positive with reason
- tune threshold/rule or add suppression guardrail
- retain sensitivity for high-impact paths (avoid over-tuning)

## Noisy Signals We See

- duplicate alerts for same outage window
- transient diagnostic ingestion failures
- warning bursts around change windows

Control actions:

- deduplicate to one incident ID
- downgrade low-value repeated rules
- monthly noise ratio review (`non-actionable / total alerts`)

## Partial Failures We See

- region/source-specific failures
- degraded latency with intermittent successes
- service-path failure while VM heartbeat remains healthy

Operational rule:

- partial user impact counts toward reliability budget
- triage must compare by region/source/path, not only global health

## What We Ignored (And Regretted)

- delayed response to asymmetric failure signals because aggregate dashboard looked acceptable
- repeated low-priority warnings that later mapped to recurring dependency failures
- change-window warning clusters dismissed before correlation checks

## What We Misinterpreted

- high CPU treated as root cause when it was an amplifier
- healthy heartbeat treated as healthy service
- successful apply treated as runtime safety confirmation

## What We Thought vs What Actually Happened

- **Thought:** first alert identifies main problem  
  **Actually:** first alert often identifies the fastest symptom, not root cause.

- **Thought:** partial recovery means incident is effectively over  
  **Actually:** partial recovery can regress without watch-window validation.

- **Thought:** documenting controls is enough  
  **Actually:** only enforced controls changed repeat failure patterns.

- **Thought:** fewer alerts always means better monitoring  
  **Actually:** over-tuning can hide weak but important early signals.

## Monitoring Hygiene Actions

- maintain alert-quality backlog with owners and due dates
- review false positives weekly
- require explicit owner/runbook mapping for high-severity alerts
- correlate alert timelines with Activity Log and apply history
- record ignored/misinterpreted signals in postmortems

## Operational Dashboards (Typical Views)

Dashboards are centered around:

- VM health:
  - heartbeat/availability tiles per environment,
  - CPU / memory / disk charts per host,
  - alert counts by severity and class.
- Service availability:
  - synthetic endpoint status over time,
  - error-rate and latency summaries where available.
- Change correlation:
  - Activity Log change timeline around incident windows,
  - Terraform apply history overlay.

These views are built from Log Analytics workbooks and Azure Monitor metrics; they are intentionally small and focused on what on-call engineers actually use at 02:00.

## Evidence References

- `evidence/live-artifacts/azure-monitor-alert-history.csv`
- `evidence/live-artifacts/log-analytics-query-exports.md`
- `evidence/live-artifacts/synthetic-monitoring-evidence-example.md`
- `telemetry-trends.md`
- `incident-postmortem.md`
- `incident-complex.md`
