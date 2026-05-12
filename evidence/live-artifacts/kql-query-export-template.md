# KQL Query Export Template

Status: Simulated/Sanitized Sample

Incident ID: `INC-YYYY-MM-DD-XXX`  
Environment: `dev|staging|prod`  
Query purpose: signal or differentiator

## Query

```kusto
Heartbeat
| where TimeGenerated > ago(30m)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
```

## Result excerpt (sanitized)

| TimeGenerated | Computer | LastHeartbeat |
| --- | --- | --- |
| 2026-05-08T10:20:00Z | prod-vm-app-01 | 2026-05-08T10:19:57Z |

## Interpretation

- what this proves
- what this does not prove
- follow-up query linked
