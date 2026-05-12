# Restore Drill Evidence Guidance

This folder stores restore drill artifacts for support/recovery credibility.

## Expected artifacts

- monthly drill folders (for example `2026-05-monthly-drill/`)
- `backup-restore-job-export-template.csv`
- `restore-incident-timeline-template.md`

## Status labels

- **Real Sanitized Export**
- **Simulated/Sanitized Sample**
- **Planned**

## What reviewers expect

- restore start/end timestamps
- measured RTO and restore point age (RPO reference)
- validation checks (service + telemetry)
- failure notes and corrective action

## Sanitization boundaries

- redact subscription/resource IDs and operator identities
- keep job IDs, timings, and result states
