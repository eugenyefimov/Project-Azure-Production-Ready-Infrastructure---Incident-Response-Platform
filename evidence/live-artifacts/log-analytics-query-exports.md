# Log Analytics Query Exports (Sanitized)

Status: Simulated/Sanitized Sample  
Scope: Portfolio repository. No live tenant data or customer data is included.

Representative query result exports from multiple dates and incident classes.

What this artifact proves:

- operators used timestamped query outputs during real triage windows
- noisy telemetry and partial failures were separated from user-impacting faults
- incident decisions were tied to evidence, not assumptions

How generated (real-world equivalent):

- run saved KQL queries in Log Analytics with incident time filters
- export table output with UTC time and scope filters visible
- attach short operator interpretation notes from bridge timeline

How to present in interview:

- walk alert time first, then query output, then fault-domain decision
- include one wrong hypothesis and show the query that disproved it
- call out one noisy signal that was intentionally deprioritized
- call out missing bins / ingestion holes explicitly (do not hide them)

## Export A - Failed Login Burst (2026-03-12 15:18-15:28 UTC)

Query:

```kusto
SecurityEvent
| where EventID == 4625
| where TimeGenerated between (datetime(2026-03-12T15:18:00Z) .. datetime(2026-03-12T15:28:00Z))
| summarize FailedAttempts=count() by Account, IpAddress, Computer
| order by FailedAttempts desc
```

Result table:

```text
Account,IpAddress,Computer,FailedAttempts
op-admin-user,198.51.100.77,vm-mgmt-sim-01,14
op-admin-user,198.51.100.79,vm-mgmt-sim-01,9
svc-automation,192.0.2.11,vm-mgmt-sim-01,3
```

Operator note:
one internal service account failure was unrelated and closed as config drift.
small gap: events between `15:24` and `15:25` were not ingested on first query run.

## Export B - Heartbeat Continuity (2026-04-30 incident window)

Query:

```kusto
Heartbeat
| where TimeGenerated between (datetime(2026-04-30T00:15:00Z) .. datetime(2026-04-30T00:40:00Z))
| summarize LastHeartbeat=max(TimeGenerated), BeatCount=count() by Computer
| order by Computer asc
```

Result table:

```text
Computer,LastHeartbeatUTC,BeatCount
vm-app-sim-01,2026-04-30 00:39:56,24
vm-mgmt-sim-01,2026-04-30 00:39:44,25
```

Operator note:
host heartbeat remained healthy during endpoint outage, confirming network-path fault domain.
one beat around `00:31` was missing then appeared on re-query 6 minutes later.

## Export C - CPU Anomaly Candidates (2026-04-29 13:55-14:45 UTC)

Query:

```kusto
let baseline =
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
| summarize BaselineCPU=avg(CounterValue) by Computer, HourOfDay=datetime_part("hour", TimeGenerated), DayBucket=bin(TimeGenerated, 1d)
| summarize BaselineCPU=avg(BaselineCPU) by Computer, HourOfDay;
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
| where TimeGenerated between (datetime(2026-04-29T13:55:00Z) .. datetime(2026-04-29T14:45:00Z))
| extend HourOfDay=datetime_part("hour", TimeGenerated)
| summarize CurrentCPU=avg(CounterValue) by Computer, HourOfDay, bin(TimeGenerated, 15m)
| join kind=leftouter baseline on Computer, HourOfDay
| extend DeviationRatio = iif(BaselineCPU > 0, CurrentCPU / BaselineCPU, real(null))
| project TimeGenerated, Computer, CurrentCPU, BaselineCPU, DeviationRatio
| order by TimeGenerated asc
```

Result table:

```text
TimeGeneratedUTC,Computer,CurrentCPU,BaselineCPU,DeviationRatio
2026-04-29 14:00:00,vm-app-sim-01,81.7,34.5,2.37
2026-04-29 14:15:00,vm-app-sim-01,78.4,35.1,2.23
2026-04-29 14:30:00,vm-app-sim-01,63.2,35.0,1.81
2026-04-29 14:45:00,vm-app-sim-01,,34.8,
```

Operator note:
anomaly resolved without outage after query plan rollback.

## Export D - Diagnostic Errors (Noisy but low-impact window)

Query:

```kusto
AzureDiagnostics
| where TimeGenerated between (datetime(2026-04-24T15:50:00Z) .. datetime(2026-04-24T16:30:00Z))
| where Level has "Error" or ResultType has "Failed"
| project TimeGenerated, Resource, OperationName, ResultType, ResultDescription
| order by TimeGenerated desc
```

Result table:

```text
TimeGeneratedUTC,Resource,OperationName,ResultType,ResultDescription
2026-04-24 16:27:41,agw-prod-edge,ApplicationGatewayAccessLog,Failed,Backend response timeout (retry)
2026-04-24 16:22:09,az-ir-platform-p-westeurope-law,DataCollectorUpload,Failed,transient ingestion throttle
2026-04-24 16:11:55,alert-auth-failed-login-burst,ScheduledQueryRuleEvaluation,Failed,query execution exceeded timeout once
2026-04-24 16:11:58,alert-auth-failed-login-burst,ScheduledQueryRuleEvaluation,Failed,retry eval duplicated message id
```

Operator note:
classified as noisy window; no customer impact recorded.

## Export E - Partial Regional Failure Correlation (2026-05-18 13:06-13:40 UTC)

Query:

```kusto
AppRequests
| where TimeGenerated between (datetime(2026-05-18T13:06:00Z) .. datetime(2026-05-18T13:40:00Z))
| summarize RequestCount=count(), FailureCount=countif(ResultCode >= 500 or Success == false), P95LatencyMs=percentile(DurationMs, 95) by ClientRegion, bin(TimeGenerated, 5m)
| extend FailureRate = todouble(FailureCount) / todouble(RequestCount)
| order by TimeGenerated asc, ClientRegion asc
```

Result table:

```text
TimeGeneratedUTC,ClientRegion,RequestCount,FailureCount,FailureRate,P95LatencyMs
2026-05-18 13:10:00,eu-2,1284,692,0.539,2912
2026-05-18 13:10:00,eu-1,1407,114,0.081,944
2026-05-18 13:20:00,eu-2,1191,648,0.544,3057
2026-05-18 13:20:00,eu-1,1376,143,0.104,1022
2026-05-18 13:35:00,eu-2,1333,88,0.066,772
2026-05-18 13:35:00,eu-1,1422,59,0.041,611
2026-05-18 13:30:00,eu-2,NA,NA,NA,NA
```

Operator note:
asymmetry across regions confirmed policy/path issue plus compute pressure, not global platform outage.
`13:30` bin came back as NA in first export due to workspace ingestion delay.
