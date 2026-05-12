# Restore Incident Timeline Template

Status: Simulated/Sanitized Sample

Drill ID: `DRILL-YYYY-MM-MONTHLY-XX`  
Environment: `staging` (recommended isolated recovery scope)  
Severity used for incident handling: `Sev2` unless customer-facing outage criteria require `Sev1`

| Time (UTC) | Step | Outcome | Evidence Link |
| --- | --- | --- | --- |
| 2026-05-27T09:00:12Z | Restore started | In progress | backup job export |
| 2026-05-27T09:54:42Z | Restore completed | Success | backup job export |
| 2026-05-27T09:58:00Z | Service health check | Pass | validation checklist |
| 2026-05-27T10:06:00Z | Telemetry watch window complete | Pass | monitoring query export |

Notes:
- include one failed validation step if it occurred; do not remove failed-first evidence
- preserve timing sequence after sanitization
