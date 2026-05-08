# Restore Execution Evidence

This file captures what happened in Azure Backup during the restore drill.

## Restore objective
- Validate that Recovery Services Vault can restore the protected Linux VM to a new target VM reliably.
- Measure restore timing from decision point to service-stable time.

## Restore point used
- **Restore point timestamp (UTC):** `2026-05-01T00:00:18Z` (example)
- **Restore point type:** `CrashConsistent` (example)
- **Expected RPO target:** `<= 24h`

## Vault and backup item identifiers (placeholders)
- **Vault name:** `az-ir-platform-<env>-rsv-01` (update with real)
- **Backup RG:** `az-ir-platform-<env>-rg-backup` (update with real)
- **Backup item (friendly name):** `az-ir-platform-<env>-vm-app-01` (update with real)

## Restore job
- **Restore to:** Create new VM in isolated drill RG
- **Start time (UTC):** `2026-05-08T09:00:00Z` (example)
- **End time (UTC):** `2026-05-08T09:42:30Z` (example)
- **Measured restore job duration:** `42m 30s`
- **Restore job ID / name:** `RestoreDisks_<example>` (update with real)
- **Restore status:** `Completed` (expected pass)

## Evidence placeholders
- `screenshots/restore-job.png`

## Azure CLI verification snippets (example)

```bash
# Example: list recovery points (use values matching your vault and item)
az backup item list \
  --resource-group <backup-rg> \
  --vault-name <vault-name> \
  --workload-type AzureIaasVM \
  --query "[].properties.friendlyName" -o tsv

az backup recoverypoint list \
  --resource-group <backup-rg> \
  --vault-name <vault-name> \
  --container-name <container-name> \
  --item-name <item-name> \
  --query "[0].[name,properties.recoveryPointTime,properties.recoveryPointType]" \
  -o table

# Restore (restore-disks)
az backup restore restore-disks \
  --resource-group <backup-rg> \
  --vault-name <vault-name> \
  --container-name <container-name> \
  --item-name <item-name> \
  --rp-name <recovery-point-name> \
  --storage-account <target-storage-account> \
  --target-resource-group <drill-restore-rg> \
  --restore-to-staging-storage-account true \
  -o json

# Restore job status
az backup job show \
  --resource-group <backup-rg> \
  --vault-name <vault-name> \
  --name <restore-job-name> \
  --query "{status:properties.status,error:properties.errorDetails[0].errorString,start:properties.startTime,end:properties.endTime}" \
  -o json
```

