# KQL Triage Query Pack (Operations-Focused)

This pack is designed for **small Azure VM-based platforms** (like this repo), not giant multi-tenant systems.
Each scenario has:
- investigation goal
- a realistic KQL query
- how to interpret results
- escalation criteria
- basic mitigation guidance
- common false positives

> Replace placeholder workspace/table names with those used in your environment (`Heartbeat`, `Perf`, `AzureActivity`, `AzureDiagnostics`, `SecurityEvent`, etc.).

---

## 1. VM Unavailable

### Goal
Quickly confirm whether a VM is actually down vs only unreachable from a particular path.

### KQL
```kusto
let lookback = 30m;
Heartbeat
| where TimeGenerated > ago(lookback)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| extend MinutesSinceHeartbeat = datetime_diff("minute", now(), LastHeartbeat)
| order by MinutesSinceHeartbeat desc
```

### Interpretation
- `MinutesSinceHeartbeat <= 5`: VM is likely up (from agent’s perspective).
- `MinutesSinceHeartbeat > 15`: VM may be down / unreachable to Log Analytics.

### Escalation criteria
- Escalate when:
  - `MinutesSinceHeartbeat > 15` **and**
  - customers or synthetic checks show impact.

### Mitigation guidance
- If heartbeat is stale but NSG/route look normal:
  - check VM power state (`az vm get-instance-view`)
  - use serial console / boot diagnostics if console access is needed.

### Common false positives
- Agent upgrade or short-lived ingestion gaps.
- Workspace/agent misconfiguration without real VM outage.

---

## 2. CPU Spike Investigation

### Goal
Identify whether a CPU spike is transient or sustained, and which VMs are affected.

### KQL
```kusto
let lookback = 60m;
Perf
| where TimeGenerated > ago(lookback)
| where ObjectName == "Processor"
      and CounterName == "% Processor Time"
      and InstanceName == "_Total"
| summarize AvgCPU = avg(CounterValue),
            MaxCPU = max(CounterValue)
          by bin(TimeGenerated, 5m), Computer
| order by TimeGenerated asc
```

### Interpretation
- Look for:
  - sustained `AvgCPU` above your alert threshold (e.g., 75–80%+)
  - whether spike aligns with reported incident window.

### Escalation criteria
- Escalate to **Sev2** when:
  - CPU is sustained above threshold for multiple 5-minute bins **and**
  - service latency/degradation is confirmed.

### Mitigation guidance
- On VM:
  - `top` / `ps` (Linux) or `Get-Process` (Windows) to find top CPU consumers.
  - decide between:
    - service restart,
    - temporary scale-up,
    - kill runaway process under change control.

### Common false positives
- Short warming spikes post-deploy.
- Scheduled batch jobs that complete quickly (but still worth verifying they’re expected).

---

## 3. Disk Pressure Investigation

### Goal
Detect VMs close to running out of OS disk space.

### KQL
> Requires Perf counters or log collection that includes disk usage metrics.

```kusto
let lookback = 60m;
Perf
| where TimeGenerated > ago(lookback)
| where ObjectName == "LogicalDisk"
      and CounterName == "% Free Space"
      and InstanceName in ("C:", "/")
| summarize MinFree = min(CounterValue) by Computer
| extend DiskUsedPct = 100 - MinFree
| where DiskUsedPct >= 85
| order by DiskUsedPct desc
```

### Interpretation
- `DiskUsedPct >= 90`: critical for OS disks.
- Use as cross-check for any low-disk alert.

### Escalation criteria
- Escalate when:
  - OS disk usage is > 90% and trending worse, **or**
  - app already shows failures tied to disk writes/logging.

### Mitigation guidance
- Short term:
  - clean up logs/tmp,
  - rotate/truncate oversized logs under change control.
- Longer term:
  - resize disk,
  - move noisy logs to dedicated storage.

### Common false positives
- Debug/temporary workloads filling disk intentionally (e.g., stress tests) – should still be acknowledged but may not be customer-impacting.

---

## 4. NSG Rule Change Correlation

### Goal
Find NSG changes near an incident window to confirm or rule out network policy as a root cause.

### KQL
```kusto
let startTime = datetime(2026-05-08T10:00:00Z);
let endTime   = datetime(2026-05-08T11:00:00Z);
AzureActivity
| where TimeGenerated between (startTime .. endTime)
| where OperationNameValue has "networkSecurityGroups"
| project TimeGenerated,
          OperationName = OperationNameValue,
          ResourceGroup,
          Resource,
          Status = ActivityStatusValue,
          Caller,
          CorrelationId
| order by TimeGenerated asc
```

### Interpretation
- Any `Succeeded` NSG write close to outage onset is a strong candidate.
- Use `CorrelationId` for deeper trace if needed.

### Escalation criteria
- Escalate to incident commander when:
  - NSG changes align with outage timeframe, **and**
  - synthetic/service checks support ingress/egress failures.

### Mitigation guidance
- Compare effective NSG rules before and after change.
- Consider rollback via Terraform apply using prior known-good plan/commit.

### Common false positives
- NSG updates that change tags or descriptions without affecting rules.

---

## 5. Azure Activity Log Investigation (General)

### Goal
Summarize control-plane changes in a resource group around a suspected incident.

### KQL
```kusto
let startTime = ago(2h);
let endTime   = now();
AzureActivity
| where TimeGenerated between (startTime .. endTime)
| where ResourceGroup has "az-ir-platform"
| project TimeGenerated,
          OperationName = OperationNameValue,
          Resource,
          Status = ActivityStatusValue,
          Caller,
          CorrelationId
| order by TimeGenerated desc
```

### Interpretation
- Look for change operations (`write`, `delete`) just before impact start.
- Use `CorrelationId` to group retries / related operations.

### Escalation criteria
- Escalate when:
  - high-risk operations (NSGs, routes, DNS changes) appear near outage onset.

### Mitigation guidance
- Use CI/CD history + Activity Log to determine which change to rollback.

### Common false positives
- Scheduled compliance or monitoring changes unrelated to the impacted path.

---

## 6. Backup Failure Investigation

### Goal
Check if backup jobs (VM backups) are failing and which items are affected.

> Assumes Backup diagnostics or AzureDiagnostics for Backup are sent to Log Analytics.

### KQL
```kusto
let lookback = 24h;
AzureDiagnostics
| where TimeGenerated > ago(lookback)
| where Category == "AzureBackupReport"
| where OperationName == "Backup"
| summarize
    FailedJobs     = countif(Status_s != "Completed"),
    SuccessfulJobs = countif(Status_s == "Completed")
  by BackupItem = tostring(BackupItemFriendlyName_s)
| order by FailedJobs desc
```

### Interpretation
- Any `FailedJobs > 0` needs investigation.
- Compare ratio of failed vs successful jobs for that item.

### Escalation criteria
- Escalate when:
  - production VMs have repeated failed backup jobs
  - or when no successful backups exist within expected RPO window.

### Mitigation guidance
- Check Recovery Services Vault alerts and job error details.
- Validate connectivity/permissions to backup storage and VM Extension status.

### Common false positives
- Transient, single-run failures that auto-recover on the next run (still worth noting but may not require Sev2 treatment).

---

## 7. Failed Deployment / Apply Investigation

### Goal
Relate deployment (Terraform apply, ARM template, or extension deployment) failures to control-plane operations.

### KQL
```kusto
let lookback = 2h;
AzureActivity
| where TimeGenerated > ago(lookback)
| where OperationNameValue has_any ("deployments/write", "write", "Microsoft.Resources/deployments")
| project TimeGenerated,
          OperationName = OperationNameValue,
          ResourceGroup,
          Resource,
          Status = ActivityStatusValue,
          Caller,
          CorrelationId
| order by TimeGenerated desc
```

### Interpretation
- `Status != "Succeeded"` near the time of infrastructure changes indicates deployment issues.

### Escalation criteria
- Escalate when:
  - failed deployment is related to critical resources (NSG, VM, DNS) during change window.

### Mitigation guidance
- For Terraform-driven changes:
  - inspect CI/CD logs for failed apply
  - consider safe re-apply with same plan if failure is transient
  - avoid parallel manual fixes in the portal unless well-documented.

### Common false positives
- Failed test deployments in non-critical RGs not tied to the impacted environment.

---

## 8. Service Degradation Investigation (Endpoint)

### Goal
Distinguish actual service degradation from probe noise and correlate with host metrics.

> Here we use a simple synthetic availability metric pattern; adapt metric names to your setup.

### KQL
```kusto
let lookback = 1h;
// Example for a custom availability metric or web test metric
AzureMetrics
| where TimeGenerated > ago(lookback)
| where Resource == "az-ir-platform-p-<region>-vm-app-01"
| where MetricName == "Availability"
| summarize AvgAvailability = avg(Val) by bin(TimeGenerated, 5m)
| order by TimeGenerated asc
```

### Interpretation
- Look for sustained drops in `AvgAvailability` around reported issue time.
- Correlate with CPU/disk and NSG changes if available.

### Escalation criteria
- Escalate when:
  - availability metric drops consistently (not single point) **and**
  - user reports or other signals confirm customer impact.

### Mitigation guidance
- Follow “Nginx down” and “network-issue” runbooks:
  - confirm host health
  - confirm NSG/route path
  - confirm service health.

### Common false positives
- Single-region probe failures (network/regional) where other probes and user reports remain healthy.

---

## 9. Authentication / RBAC Investigation

### Goal
Investigate patterns of failed logins or RBAC issues on management VMs.

> Assumes Windows `SecurityEvent` data is available; adapt to Linux auth logs if needed.

### KQL
```kusto
let lookback = 60m;
SecurityEvent
| where TimeGenerated > ago(lookback)
| where EventID in (4625, 529) // failed logons
| summarize FailedAttempts = count()
          by bin(TimeGenerated, 15m),
             Account   = tostring(TargetUserName),
             SourceIP  = tostring(IpAddress),
             Host      = Computer
| order by FailedAttempts desc
```

### Interpretation
- High volume of failed attempts from unusual `SourceIP` or accounts indicates possible brute-force or misconfigured scripts.

### Escalation criteria
- Escalate to security/incident command when:
  - high-rate password spray from unfamiliar internet addresses
  - repeated failures on privileged accounts.

### Mitigation guidance
- Block offending IPs or ranges (NSG, firewall) if appropriate.
- Rotate credentials or enforce MFA where applicable.
- Validate that backup/automation accounts are using correct secrets.

### Common false positives
- Penetration tests without appropriate tags.
- Misconfigured internal automation with outdated passwords.

---

## 10. Alert Noise Analysis

### Goal
Identify rules that generate frequent non-actionable alerts and quantify noise ratio.

### KQL
> Assumes exported Azure alert history is captured into a table or imported CSV (similar to `azure-monitor-alert-history.csv`).

```kusto
let lookback = 30d;
AlertHistory
| where TimeGenerated > ago(lookback)
| summarize
    TotalAlerts       = count(),
    ActionableAlerts  = countif(Classification == "actionable"),
    FalsePositives    = countif(Classification == "false_positive"),
    Duplicates        = countif(Classification == "duplicate")
  by AlertRule = tostring(AlertRuleName)
| extend NoiseRatio = todouble(FalsePositives + Duplicates) / todouble(TotalAlerts)
| order by NoiseRatio desc, TotalAlerts desc
```

*(If using CSV imports instead of a native `AlertHistory` table, adjust the table name and column names accordingly.)*

### Interpretation
- High `NoiseRatio` with high `TotalAlerts` = prime candidates for tuning.

### Escalation criteria
- Not a Sev1/Sev2 incident trigger, but:
  - high-noise rules must enter the alert-tuning backlog (with owner and due date).

### Mitigation guidance
- Tune thresholds or add correlation conditions.
- Add dependency/context information into alert customProperties for better triage.
- Consider downgrading some alerts to informational only.

### Common false positives
- Test/maintenance alerts not properly muted or tagged.
- Single-region probe instability misclassified as global outage.

