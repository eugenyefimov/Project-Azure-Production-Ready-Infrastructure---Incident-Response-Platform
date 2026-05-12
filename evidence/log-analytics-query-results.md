# Log Analytics Query Results (Sanitized Samples)

Status: Simulated/Sanitized Sample  
Scope: Portfolio repository. No live tenant data or customer data is included.

These are representative outputs and KQL snippets used during investigations. They are intentionally small and focused on what an on-call engineer would actually run.

## Query A: Failed Logins by Account and Source (Last 60 Minutes)

**KQL**

```kusto
SecurityEvent
| where TimeGenerated > ago(60m)
| where EventID in (4625, 529) // failed logons
| summarize FailedAttempts = count()
          by bin(TimeGenerated, 15m),
             Account = tostring(TargetUserName),
             SourceIP = tostring(IpAddress),
             Host = Computer
| sort by FailedAttempts desc
```

**Sample Output**

| Time Window (UTC)     | Account            | Source IP     | Host                                   | FailedAttempts |
|-----------------------|--------------------|---------------|----------------------------------------|----------------|
| 2026-04-30 08:00-09:00| svc-automation     | 192.0.2.11    | vm-mgmt-sim-01                          | 3              |
| 2026-04-30 08:00-09:00| op-admin-user      | 198.51.100.77 | vm-mgmt-sim-01                          | 14             |
| 2026-04-30 08:00-09:00| op-admin-user      | 198.51.100.79 | vm-mgmt-sim-01                          | 9              |
| 2026-04-30 08:00-09:00| helpdesk-user      | 203.0.113.24  | vm-mgmt-sim-01                          | 2              |

Operator note:
- `svc-backup-agent` failures were expected after password rotation drift; corrected by secret sync.
- Public IP attempts escalated to security triage due to burst behavior.

## Query B: VM Health Trends (Heartbeat Gaps, Last 24 Hours)

**KQL**

```kusto
Heartbeat
| where TimeGenerated > ago(24h)
| summarize LastHeartbeatUTC = max(TimeGenerated)
          by Computer
| extend MinutesSinceHeartbeat = datetime_diff("minute", now(), LastHeartbeatUTC)
| extend HealthState = case(
    MinutesSinceHeartbeat <= 5, "Healthy",
    MinutesSinceHeartbeat <= 15, "Warning",
    "Critical"
  )
| order by MinutesSinceHeartbeat asc
```

**Sample Output**

| Host                                   | LastHeartbeatUTC      | MinutesSinceHeartbeat | HealthState |
|----------------------------------------|------------------------|-----------------------|-------------|
| vm-app-sim-01                           | 2026-04-30 00:46:58    | 1                     | Healthy     |
| vm-mgmt-sim-01                          | 2026-04-30 00:46:31    | 1                     | Healthy     |
| vm-app-sim-02                           | 2026-04-30 00:40:11    | 7                     | Warning     |

Operator note:
- Staging app VM heartbeat delay correlated with patch cycle; no user impact.

## Query C: Resource Anomaly Candidates (CPU Deviation >= 2x Baseline)

**KQL**

```kusto
let Lookback = 24h;
Perf
| where TimeGenerated > ago(Lookback)
| where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
| summarize
    CurrentCPU = avg(CounterValue),
    BaselineCPU = percentile(CounterValue, 50)
    by bin(TimeGenerated, 5m), Computer
| extend DeviationRatio = CurrentCPU / BaselineCPU
| where DeviationRatio >= 2.0
| order by DeviationRatio desc
```

**Sample Output**

| TimeGeneratedUTC      | Host                                   | CurrentCPU | BaselineCPU | DeviationRatio |
|-----------------------|----------------------------------------|------------|-------------|----------------|
| 2026-04-29 14:10:00   | vm-app-sim-01                           | 83.4       | 33.7        | 2.47           |
| 2026-04-29 14:25:00   | vm-app-sim-01                           | 79.1       | 34.8        | 2.27           |
| 2026-04-29 14:40:00   | vm-app-sim-01                           | 68.2       | 35.1        | 1.94           |

Operator note:
- Final row dropped below alert threshold but remained elevated; investigation kept open for 30 more minutes.

## Query D: NSG Changes Around Incident Window

**KQL**

```kusto
AzureActivity
| where TimeGenerated between (datetime(2026-04-30T00:00:00Z) .. datetime(2026-04-30T01:00:00Z))
| where OperationNameValue has "networkSecurityGroups"
| project TimeGenerated,
          OperationName = OperationNameValue,
          ResourceGroup,
          Resource,
          Status = ActivityStatusValue,
          Caller
| order by TimeGenerated asc
```

Use this during network incidents to confirm NSG rule updates around outage start.

## Query E: Backup Job Failures (Recovery Services Vault)

**KQL**

```kusto
AzureDiagnostics
| where Category == "AzureBackupReport"
| where TimeGenerated > ago(24h)
| where OperationName == "Backup"
| summarize FailedJobs = countif(Status_s != "Completed"),
          SuccessfulJobs = countif(Status_s == "Completed")
          by bin(TimeGenerated, 1h), BackupItemUniqueId_s, BackupItemFriendlyName_s
| where FailedJobs > 0
| order by TimeGenerated desc
```

Use this around backup validation windows to identify failing protected items and correlate with `vm-recovery.md` / `backup-verification.md`.
