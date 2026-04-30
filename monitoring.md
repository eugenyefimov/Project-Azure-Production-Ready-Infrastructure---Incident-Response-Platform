# Monitoring Operations (Imperfect by Design)

This document records how monitoring behaves in real operations, including false alerts, noisy signals, and partial failures.

## Operational Targets

- detect customer-impacting availability events in under 5 minutes
- acknowledge `Sev1/Sev2` alerts in under 5 minutes
- keep noise ratio low enough to protect on-call response quality without hiding weak signals

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

## Evidence References

- `evidence/live-artifacts/azure-monitor-alert-history.csv`
- `evidence/live-artifacts/log-analytics-query-exports.md`
- `telemetry-trends.md`
- `incident-postmortem.md`
- `incident-complex.md`
