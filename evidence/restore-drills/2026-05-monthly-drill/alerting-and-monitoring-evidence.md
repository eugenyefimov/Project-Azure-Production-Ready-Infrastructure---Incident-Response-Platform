# Alerting and Monitoring Evidence (Post-Restore)

Goal:
- verify monitoring is operating after restore
- avoid “false closure” where service checks pass but telemetry does not

## Monitoring verification steps

### 1) Log Analytics ingestion
- Confirm Heartbeat events for the restored VM appear in Log Analytics
- Confirm no persistent heartbeat gaps during the watch window

### 2) Metric ingestion
- Confirm `Percentage CPU` and availability signals resume

### 3) Alert noise / recurrence
- Check that there are no immediate repeated alert storms attributable to restore until closure watch window ends

## Example KQL snippets (optional)

If you have Heartbeat/Perf data in the workspace:

### Heartbeat continuity
```kusto
Heartbeat
| where TimeGenerated > ago(2h)
| where Computer == "<restored-vm-name>"
| summarize LastHeartbeat=max(TimeGenerated), BeatCount=count() by Computer
```

### CPU trend
```kusto
Perf
| where TimeGenerated > ago(1h)
| where Computer == "<restored-vm-name>"
| where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
| summarize AvgCPU=avg(CounterValue) by bin(TimeGenerated, 5m)
| order by TimeGenerated asc
```

## Evidence placeholders
- Include exported query results or screenshot placeholders:
  - `screenshots/heartbeat-query.png`
  - `screenshots/cpu-chart.png`

