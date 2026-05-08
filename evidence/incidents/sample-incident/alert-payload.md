# Alert Payload (Sample)

## Incident context
- **Incident ID**: `INC-2026-05-08-001`
- **Environment**: `prod`
- **Service / Workload**: `customer-api` on VM `az-ir-platform-p-<region>-vm-app-01`
- **Fault domain**: compute / performance
- **Severity**: `Sev2`

## Alert rule (what triggered)
- **Alert rule name**: `alert-vm-high-cpu`
- **Alert family**: VM metric alert
- **Metric**: `Percentage CPU`
- **Threshold**: (example) `>= 75%` for 5-minute window
- **Alert severity (Azure Monitor)**: `2`

## Business impact assessment (sample)
- **Impact type**: performance degradation (partial customer impact)
- **User impact**: elevated latency and intermittent request timeouts for a subset of clients
- **Scope**: single region / single app VM (application subnet)
- **Duration estimate (initial)**: ~30-45 minutes until CPU returns below threshold
- **Operational risk**: risk of cascading retries increasing load and prolonging recovery if mitigation is delayed

## Anchor timestamps (UTC)
- **Incident declared (impact first observed)**: `2026-05-08T10:15:00Z`
- **First high-confidence alert fired**: `2026-05-08T10:18:45Z`

## Simplified payload excerpt

```json
{
  "alertRule": "alert-vm-high-cpu",
  "severity": "Sev2",
  "firedDateTime": "2026-05-08T10:18:45Z",
  "targetResource": "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/az-ir-platform-p-<region>-vm-app-01",
  "monitorCondition": "Fired",
  "customProperties": {
    "environment": "prod",
    "service": "customer-api",
    "runbook": "runbooks/high-cpu.md"
  }
}
```

## What responders were expected to do first
- Verify VM health (heartbeat/availability)
- Identify whether CPU spike correlates with symptoms (latency/timeouts)
- Use the runbook for high CPU triage and decide mitigation vs rollback vs capacity change

