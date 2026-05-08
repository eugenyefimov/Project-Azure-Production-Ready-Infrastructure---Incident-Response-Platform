# Incident Walkthrough: VM CPU Spike (`INC-2026-05-08-CPU-01`)

## 1) Alert trigger

### Incident metadata
- **Incident ID:** `INC-2026-05-08-CPU-01`
- **Environment:** `prod`
- **Severity:** `Sev2`
- **Service:** `customer-api` (Nginx on Linux VM)
- **Primary resource:** `az-ir-platform-p-westeurope-vm-app-01` (name pattern from `modules/platform/main.tf`)

### Triggered control (implemented)
- **Terraform resource:** `azurerm_monitor_metric_alert.high_cpu`
- **Defined in:** `modules/monitoring/main.tf`
- **Signal:** `Percentage CPU` above configured threshold (`var.cpu_alert_threshold_percent`)
- **Action routing:** `azurerm_monitor_action_group.this`

### Trigger timestamps (UTC, sanitized)
- Impact first observed: `2026-05-08T10:15:00Z`
- Alert fired: `2026-05-08T10:18:45Z`
- On-call acknowledged: `2026-05-08T10:19:10Z`

### Evidence class
- **Real evidence:** alert rule and routing are implemented in Terraform.
- **Sanitized evidence:** exact timestamps above are normalized for portfolio.
- **Simulated placeholder:** raw Azure Monitor payload export file not attached yet.

---

## 2) Investigation timeline

| Time (UTC) | Action | Owner role | Observation |
|---|---|---|---|
| 10:15:00 | Service latency increased | Monitoring/on-call | User impact began (partial degradation) |
| 10:18:45 | `alert-vm-high-cpu` fired | Azure Monitor | CPU condition met |
| 10:19:10 | Alert acknowledged | On-call engineer | Incident bridge opened |
| 10:22:30 | VM health checked | On-call engineer | VM reachable, no hard host outage |
| 10:28:00 | Incident commander assigned | Incident manager | Mitigation not immediately effective |
| 10:35:40 | Process-level CPU triage | On-call engineer | One workload path consuming sustained CPU |
| 10:42:05 | Mitigation applied | On-call engineer | CPU trend began dropping |
| 10:57:30 | Validation window passed | Incident commander | Service stable, no re-fire in watch window |
| 11:00:00 | Incident closed | Incident commander | Corrective actions recorded |

### Evidence class
- **Real evidence:** timeline steps align with runbooks and implemented alerts/workflows.
- **Sanitized evidence:** timestamps normalized.
- **Simulated placeholder:** chat screenshots/bridge transcript not attached.

---

## 3) KQL investigation

## Query A - confirm sustained CPU spike (signal query)
```kusto
let startTime = datetime(2026-05-08T10:10:00Z);
let endTime   = datetime(2026-05-08T11:00:00Z);
let targetVm  = "az-ir-platform-p-westeurope-vm-app-01";
Perf
| where TimeGenerated between (startTime .. endTime)
| where Computer == targetVm
| where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
| summarize AvgCPU=avg(CounterValue), MaxCPU=max(CounterValue) by bin(TimeGenerated, 5m), Computer
| order by TimeGenerated asc
```

## Query B - rule out VM host-down hypothesis (differentiator query)
```kusto
let startTime = datetime(2026-05-08T10:10:00Z);
let endTime   = datetime(2026-05-08T11:00:00Z);
let targetVm  = "az-ir-platform-p-westeurope-vm-app-01";
Heartbeat
| where TimeGenerated between (startTime .. endTime)
| where Computer == targetVm
| summarize LastHeartbeat=max(TimeGenerated), BeatCount=count() by Computer
```

## Query C - check for change correlation in control plane
```kusto
let startTime = datetime(2026-05-08T09:50:00Z);
let endTime   = datetime(2026-05-08T10:25:00Z);
AzureActivity
| where TimeGenerated between (startTime .. endTime)
| where ResourceGroup has "az-ir-platform-p-westeurope-rg-network"
| project TimeGenerated, OperationName=OperationNameValue, Resource, Status=ActivityStatusValue, Caller, CorrelationId
| order by TimeGenerated asc
```

### How results were interpreted
- CPU signal showed sustained saturation for multiple 5-minute bins.
- Heartbeat confirmed host remained alive, so no VM availability incident.
- Activity query used to rule in/out pre-incident control-plane changes.

### Evidence class
- **Real evidence:** queries are valid for the implemented Log Analytics + diagnostics model.
- **Sanitized evidence:** query time windows and VM name are portfolio-safe.
- **Simulated placeholder:** raw query result exports for this exact incident not attached.

---

## 4) Root cause analysis

### Root cause (operational statement)
A workload/process on the application VM consumed sustained CPU beyond the configured threshold, degrading Nginx request handling. The host stayed healthy, so this was a service-performance incident, not a host-down event.

### Contributing factors
- CPU alerting was symptom-driven; it did not immediately identify the top CPU consumer.
- Early mitigation reduced pressure but did not fully restore service until process-level correction was completed.

### Weakness in original controls
- No automated process-level telemetry alert in this baseline.
- Triage required manual host inspection for top CPU consumers.

### Evidence class
- **Real evidence:** this logic maps to implemented `high_cpu` alert + runbook flow.
- **Sanitized evidence:** wording and details normalized.
- **Simulated placeholder:** per-process historical telemetry export not attached.

---

## 5) Mitigation

### Immediate mitigation executed
- Followed `runbooks/high-cpu.md`:
  - identified top CPU consumers
  - restarted affected service component(s) safely
  - verified Nginx state and local health

### Example command evidence (sanitized)
```bash
sudo systemctl status nginx --no-pager
sudo systemctl restart nginx
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head
curl -I http://127.0.0.1/
```

### Escalation path used
- Escalated to incident commander after continued impact during initial triage.
- Escalated to duty manager when risk of sustained degradation increased.

### Evidence class
- **Real evidence:** commands and runbook path are consistent with repository runbooks.
- **Sanitized evidence:** command outputs omitted/redacted.
- **Simulated placeholder:** original terminal capture not attached.

---

## 6) Rollback / recovery path

This incident used **service-level mitigation** and did not require infra rollback.

If mitigation had failed, recovery fallback path would be:
1. controlled Terraform change through `.github/workflows/terraform-prod.yml`
2. plan approval gate
3. apply verified plan artifact (`tfplan + checksum`)

Reference controls:
- `docs/terraform-github-actions.md`
- `runbooks/terraform-partial-apply-recovery.md`

### Evidence class
- **Real evidence:** workflow controls are implemented.
- **Sanitized evidence:** this incident did not invoke rollback apply.
- **Simulated placeholder:** no rollback apply artifact for this specific incident.

---

## 7) Closure validation

### Validation checklist
- [x] CPU returned below threshold and remained stable in watch window.
- [x] Nginx service active after mitigation.
- [x] local health endpoint returned expected HTTP response.
- [x] no immediate repeat high-CPU alert in closure window.

### Closure timestamps (sanitized)
- Stable service window start: `2026-05-08T10:50:30Z`
- Closure decision: `2026-05-08T11:00:00Z`

### Operational metrics
- **MTTD:** `3m 45s`
- **MTTA:** `25s`
- **MTTR:** `38m 20s`

### Evidence class
- **Real evidence:** closure criteria align with runbook + monitoring model.
- **Sanitized evidence:** metric values/timestamps normalized.
- **Simulated placeholder:** no signed closure report export attached.

---

## 8) Lessons learned

- Host-level availability and performance alerts are useful, but not enough for root-cause precision.
- Service recovery should not be declared on first successful check; a watch window is required.
- Incident timeline quality improved when escalation timestamps were captured explicitly.

---

## 9) Prevention improvements

### Implemented / in repo workflow
- Added/kept CPU triage and closure guidance in runbooks.
- Maintained CI safety controls for any follow-up infra changes (OIDC, approval gates, plan integrity).

### Next high-ROI improvements
1. Add process-level performance telemetry guidance to `runbooks/high-cpu.md`.
2. Add one explicit “CPU incident evidence bundle” export checklist (query output + command snippets + closure record).
3. Add repeatability script/notebook to compute MTTD/MTTA/MTTR from exported artifacts.

---

## Mapping to implemented repository controls

- Monitoring:
  - `modules/monitoring/main.tf`
  - alert: `azurerm_monitor_metric_alert.high_cpu`
- Workload:
  - `modules/linux-vm/main.tf`
  - `modules/linux-vm/cloud-init.yaml`
- Incident/ops runbooks:
  - `runbooks/high-cpu.md`
  - `runbooks/nginx-down.md`
  - `runbooks/terraform-partial-apply-recovery.md` (fallback)
- CI/CD safety path:
  - `.github/workflows/terraform-prod.yml`

