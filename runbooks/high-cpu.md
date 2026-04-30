# Runbook: High CPU

## Symptoms

- High CPU alert triggered (`Percentage CPU` > threshold).
- Slow response times, login lag, or intermittent timeouts.
- CPU saturation sustained for several minutes.

## Possible Causes

- Traffic spike or workload burst.
- Runaway process/thread.
- Inefficient queries/jobs or cron/task scheduler spike.
- Malware/cryptomining compromise.
- Undersized VM for current demand.

## Azure Checks

1. Review CPU trend and duration in Azure Monitor.
2. Correlate with deployment/change windows.
3. Check VM sizing history and autoscale context (if any).
4. Inspect alert history for recurrence patterns.

## CLI Checks

```bash
az monitor metrics list --resource <vm-id> --metric "Percentage CPU" --interval PT1M
az monitor metrics list --resource <vm-id> --metric "Network In Total","Network Out Total"
```

## OS-Level Checks

- Linux:
  - `top` / `htop`
  - `ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head`
  - `uptime`, `vmstat 1 5`
- Windows:
  - `Get-Process | Sort-Object CPU -Descending | Select-Object -First 10`
  - `Get-Counter '\Processor(_Total)\% Processor Time'`
  - Task Manager / Resource Monitor

## Root Cause Analysis

1. Identify top CPU consumer process and owning service/team.
2. Determine if spike is expected (batch window) or abnormal.
3. Correlate with logs/errors and recent releases.
4. Verify whether capacity limit or software defect caused alert.

## Fix Steps

1. Mitigate immediate impact:
   - restart stuck service/process if safe
   - temporarily scale up VM if needed
2. Apply permanent fix:
   - optimize workload/query/code path
   - reschedule heavy jobs
   - right-size VM or redesign architecture
3. Confirm CPU returns to baseline and alert clears.

## Prevention

- Define CPU SLO/SLA thresholds by workload.
- Capacity planning with trend-based right-sizing.
- Add process-level telemetry and anomaly detection.
- Use autoscaling where architecture supports it.

## Communication Summary

"I handle high CPU by balancing incident mitigation and long-term correction. First I reduce user impact, then identify the true CPU consumer, correlate with recent changes, and implement a durable fix such as workload optimization or capacity right-sizing."
