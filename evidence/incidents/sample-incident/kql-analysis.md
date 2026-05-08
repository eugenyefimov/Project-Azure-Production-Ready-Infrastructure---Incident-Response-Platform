# KQL Analysis (Sample)

Purpose:
- validate the CPU symptom
- rule out false hypotheses (host down vs service down)
- provide evidence for root-cause candidate selection

Assumptions:
- VM monitoring/guest telemetry is available in Log Analytics (Heartbeat / Perf). If you do not have VM Insights/AMA configured, these queries may return empty results.

## Query 1 (signal): CPU sustained above baseline

```kusto
let startTime = datetime(2026-05-08T10:10:00Z);
let endTime = datetime(2026-05-08T11:10:00Z);
let targetVm = "az-ir-platform-p-westeurope-vm-app-01";

Perf
| where TimeGenerated between (startTime .. endTime)
| where Computer == targetVm
| where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
| summarize AvgCPU = avg(CounterValue) by bin(TimeGenerated, 1m)
| order by TimeGenerated asc
```

Expected interpretation:
- CPU is persistently elevated around the alert fired window.

## Query 2 (differentiator): Host remains healthy (avoid “VM is down” narratives)

```kusto
let startTime = datetime(2026-05-08T10:10:00Z);
let endTime = datetime(2026-05-08T10:55:00Z);
let targetVm = "az-ir-platform-p-westeurope-vm-app-01";

Heartbeat
| where TimeGenerated between (startTime .. endTime)
| where Computer == targetVm
| summarize LastBeat = max(TimeGenerated) by Computer
```

Expected interpretation:
- Host heartbeat is recent (no hard VM outage).

## Query 3 (optional): Correlate with activity / config drift

```kusto
let startTime = datetime(2026-05-08T09:50:00Z);
let endTime = datetime(2026-05-08T10:25:00Z);

AzureActivity
| where TimeGenerated between (startTime .. endTime)
| where ResourceGroup has "az-ir-platform"
| where OperationNameValue has_any ("virtualMachines/write", "networkSecurityGroups/write", "extensions/write")
| project TimeGenerated, OperationName=OperationNameValue, Resource, Caller, Status=ActivityStatusValue
| order by TimeGenerated asc
```

Use this when CPU spikes might be correlated with a recent infrastructure change (e.g., extension install, agent restart, or VM-level configuration updates).

## Triage conclusion from evidence
- CPU symptom is real and sustained.
- Host is healthy (so focus on guest/workload/resource saturation rather than connectivity).
- If AzureActivity shows a change in the pre-alert window, treat that change as a root-cause candidate.

