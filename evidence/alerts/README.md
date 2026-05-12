# Alerts Evidence Guidance

Purpose: store alert evidence that can be validated by technical reviewers.

## Expected artifacts

- `azure-monitor-alert-export-template.csv` (template)
- `incident-alert-timeline-template.md` (template)
- real sanitized alert exports (when available)

## Status labeling rule

Every file must start with one of:
- `Status: Real Sanitized Export`
- `Status: Simulated/Sanitized Sample`

## Sanitization checklist

- remove tenant/subscription/resource IDs if sensitive
- mask email addresses and phone targets in action groups
- redact internal hostnames if they reveal customer/internal naming
- keep timestamps, severity, alert rule names, and state transitions
