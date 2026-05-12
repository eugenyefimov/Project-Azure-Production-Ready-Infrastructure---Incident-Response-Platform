# Incident Alert Timeline Template

Status: Simulated/Sanitized Sample

Incident ID: `INC-YYYY-MM-DD-XXX`  
Environment: `dev|staging|prod`  
Severity: `Sev1|Sev2|Sev3|Sev4`

## Timeline

| Time (UTC) | Alert ID | Event | Owner role | Note |
| --- | --- | --- | --- | --- |
| 2026-05-08T10:18:45Z | ALRT-CPU-001 | Alert fired | Azure Monitor | High CPU threshold exceeded |
| 2026-05-08T10:19:10Z | ALRT-CPU-001 | Alert acknowledged | On-call engineer | Incident created |
| 2026-05-08T10:57:30Z | ALRT-CPU-001 | Alert resolved | Incident commander | Recovery stable window passed |

## Reviewer Notes

- Keep all timestamps in UTC.
- Keep original sequence even after sanitization.
- Link each alert row to incident evidence and runbook actions.
