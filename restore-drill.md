# Restore Drill Report: VM Failure -> Backup Restore

Status: Simulated/Sanitized Sample  
Scope: Portfolio repository. No live tenant data or customer data is included.

- **Drill ID:** `DRILL-2026-05-27-VMR-01`
- **Environment:** `staging` (isolated recovery subnet)
- **Target workload:** `az-ir-platform-s-westeurope-vm-app-01` (`customer-api`)
- **Vault:** `az-ir-platform-p-westeurope-rsv-01`
- **Scenario type:** simulated OS disk corruption and boot failure

## 1) Objectives

- prove backup is recoverable in operational conditions
- measure real restore time against RTO target
- validate that restored VM can serve traffic and emit telemetry

Target objectives from runbooks:

- **RTO target:** `30-90 minutes`
- **RPO target:** `<= 24 hours` (daily backup policy)

---

## 2) Timeline (UTC)

- **09:00:12** - Drill started by on-call engineer, incident bridge notes opened.
- **09:02:31** - Simulated failure declared (`VMUnavailable` drill inject).
- **09:04:08** - Latest restore point identified (`2026-05-27T00:00:18Z`).
- **09:06:44** - **Restore attempt #1** started (failed).
- **09:21:53** - Attempt #1 failed due to target subnet delegation conflict.
- **09:24:17** - Fix applied (changed restore target subnet/NIC config).
- **09:27:09** - **Restore attempt #2** started.
- **09:54:42** - Restore job completed successfully.
- **09:58:11** - SSH + service verification complete.
- **10:03:36** - Metrics/log stability checks complete.
- **10:06:02** - Drill closed, evidence captured.

---

## 3) Restore Command + Output (Azure CLI Style)

### 3.1 Identify backup item and restore point

```powershell
az backup item list `
  --resource-group az-ir-platform-p-westeurope-rg-backup `
  --vault-name az-ir-platform-p-westeurope-rsv-01 `
  --backup-management-type AzureIaasVM `
  --workload-type VM `
  --query "[?properties.friendlyName=='az-ir-platform-s-westeurope-vm-app-01'].[name,properties.lastRecoveryPoint]" `
  -o table
```

Output:

```text
Name                                                        LastRecoveryPoint
----------------------------------------------------------  -------------------------
VM;iaasvmcontainerv2;az-ir-platform-s-westeurope-rg-app;az-ir-platform-s-westeurope-vm-app-01  2026-05-27T00:00:18.421Z
```

```powershell
az backup recoverypoint list `
  --resource-group az-ir-platform-p-westeurope-rg-backup `
  --vault-name az-ir-platform-p-westeurope-rsv-01 `
  --container-name iaasvmcontainerv2;az-ir-platform-s-westeurope-rg-app;az-ir-platform-s-westeurope-vm-app-01 `
  --item-name VM;iaasvmcontainerv2;az-ir-platform-s-westeurope-rg-app;az-ir-platform-s-westeurope-vm-app-01 `
  --query "[0].[name,properties.recoveryPointTime,properties.recoveryPointType]" `
  -o table
```

Output:

```text
Name                                  RecoveryPointTime           RecoveryPointType
------------------------------------  --------------------------  -----------------
7661459381023363156                   2026-05-27T00:00:18.421Z   CrashConsistent
```

### 3.2 Restore attempt #1 (failed)

```powershell
az backup restore restore-disks `
  --resource-group az-ir-platform-p-westeurope-rg-backup `
  --vault-name az-ir-platform-p-westeurope-rsv-01 `
  --container-name iaasvmcontainerv2;az-ir-platform-s-westeurope-rg-app;az-ir-platform-s-westeurope-vm-app-01 `
  --item-name VM;iaasvmcontainerv2;az-ir-platform-s-westeurope-rg-app;az-ir-platform-s-westeurope-vm-app-01 `
  --rp-name 7661459381023363156 `
  --storage-account azirplatformstagingdiag `
  --target-resource-group az-ir-platform-s-westeurope-rg-restore-drill `
  --restore-to-staging-storage-account true `
  -o json
```

Output excerpt:

```json
{
  "name": "RestoreDisks_1748336804",
  "properties": {
    "status": "InProgress",
    "startTime": "2026-05-27T09:06:44.882Z"
  }
}
```

Job failure status:

```powershell
az backup job show `
  --resource-group az-ir-platform-p-westeurope-rg-backup `
  --vault-name az-ir-platform-p-westeurope-rsv-01 `
  --name RestoreDisks_1748336804 `
  --query "[properties.status,properties.errorDetails[0].errorString]" `
  -o table
```

```text
Result
--------------------------------------------------------------------------------------------------------
Failed
Target subnet /subscriptions/<sub-id>/.../subnets/aci-delegated is delegated and cannot attach restored VM NIC.
```

### 3.3 Fix + restore attempt #2 (successful)

Fix applied:

- switched target NIC/subnet to `subnet-app-recovery` (non-delegated)
- pre-created NSG association matching app baseline

```powershell
az backup restore restore-disks `
  --resource-group az-ir-platform-p-westeurope-rg-backup `
  --vault-name az-ir-platform-p-westeurope-rsv-01 `
  --container-name iaasvmcontainerv2;az-ir-platform-s-westeurope-rg-app;az-ir-platform-s-westeurope-vm-app-01 `
  --item-name VM;iaasvmcontainerv2;az-ir-platform-s-westeurope-rg-app;az-ir-platform-s-westeurope-vm-app-01 `
  --rp-name 7661459381023363156 `
  --storage-account azirplatformstagingdiag `
  --target-resource-group az-ir-platform-s-westeurope-rg-restore-drill `
  --restore-to-staging-storage-account true `
  -o json
```

Output excerpt:

```json
{
  "name": "RestoreDisks_1748338029",
  "properties": {
    "status": "Completed",
    "startTime": "2026-05-27T09:27:09.019Z",
    "endTime": "2026-05-27T09:54:42.733Z"
  }
}
```

---

## 4) Failed Attempt Analysis

### What went wrong

- restore target used an ACI-delegated subnet (`aci-delegated`)
- restored VM NIC could not be attached to delegated subnet

### Fix applied

- changed restore target to `subnet-app-recovery`
- validated subnet delegation and NSG binding before retry
- updated recovery checklist to include pre-restore subnet compatibility check

---

## 5) RTO and RPO Measurement

## Measured RTO

- **RTO start:** `09:00:12` (drill start / restore decision point)
- **RTO stop:** `09:58:11` (service reachable + SSH verification complete)
- **Measured RTO:** `57m 59s`
- **RTO target:** `30-90 minutes`
- **Result:** `within target`

## RPO (Expected vs Actual)

- **Expected RPO:** `<= 24h` (daily backup policy)
- **Failure declared at:** `2026-05-27T09:02:31Z`
- **Restore point used:** `2026-05-27T00:00:18Z`
- **Actual RPO:** `9h 02m 13s`
- **Result:** `better than target`

---

## 6) Validation Checklist

- [x] VM booted and SSH reachable (`09:56 UTC`)
- [x] `customer-api` service healthy (`systemctl status` active/running)
- [x] `/health` endpoint returned `HTTP 200`
- [x] application logs show normal startup and request flow (no crash loop)
- [x] CPU and memory returned to expected staging baseline band
- [x] heartbeat/log ingestion resumed in Log Analytics

Verification command/output excerpts:

```powershell
ssh ops-user@192.0.2.19 "sudo systemctl is-active customer-api && curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/health"
```

```text
active
200
```

```powershell
az monitor metrics list `
  --resource "/subscriptions/<sub-id>/resourceGroups/az-ir-platform-s-westeurope-rg-restore-drill/providers/Microsoft.Compute/virtualMachines/az-ir-platform-s-westeurope-vm-app-01-restore" `
  --metric "Percentage CPU" `
  --interval PT1M `
  --start-time 2026-05-27T09:50:00Z `
  --end-time 2026-05-27T10:05:00Z `
  --query "value[0].timeseries[0].data[-5:].average" `
  -o tsv
```

```text
29.4
31.1
27.8
26.9
28.3
```

---

## 7) What This Proves

- backups are not only configured but operationally restorable
- failed restore attempts can be diagnosed and corrected quickly
- recovery objectives are measurable and met with evidence
- restore verification covers service health, logs, and platform metrics

## 8) Follow-Up Improvements

- add preflight script to block restore into delegated subnets
- include automated post-restore smoke test (`SSH + /health + heartbeat check`)
- keep monthly drill trend for measured RTO variance
