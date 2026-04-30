# Backup Verification Runbook

This runbook ensures backups are actually usable, not only configured.

## Verification Frequency

- Daily: check latest job status for protected VMs
- Weekly: perform one restore drill to isolated/test scope
- Monthly: review policy, retention, and cost trend

## Daily Checks

1. Open Recovery Services Vault -> **Backup Jobs**.
2. Confirm successful completion of scheduled VM backup jobs.
3. Investigate failed or delayed jobs immediately.
4. Verify both Linux application VM and Windows management VM are protected.

## Weekly Restore Drill

1. Pick latest successful restore point for one VM.
2. Restore as **new VM** in test/isolated scope.
3. Validate:
   - VM boots
   - login works (SSH/RDP)
   - core service responds
4. Decommission drill VM after evidence is captured.
5. Record drill duration and findings to track real RTO.

## Evidence to Capture

- Backup job IDs and timestamps
- Restore job ID and completion time
- Validation screenshots/log snippets
- Any deviations from target RPO/RTO

## Trade-Offs

### Cost vs Reliability

- Lower cost: daily backups + shorter retention -> cheaper storage, but fewer recovery options.
- Higher reliability: more frequent backups + longer retention -> better restore flexibility, higher storage/operations cost.

Current baseline is cost-conscious: one daily backup and short retention for dev-like environment.

### Backup vs Snapshot

- **Backup (Recovery Services Vault):**
  - Managed retention and policy lifecycle
  - Better for compliance and operational recovery workflows
  - Slower than snapshots for some immediate rollback cases
- **Snapshot (managed disk snapshot):**
  - Fast point-in-time capture and restore patterns
  - Useful for short-term change windows
  - Not a replacement for policy-driven, long-retention backup strategy

Recommended practice: use backups for resilience/compliance; use snapshots selectively for short-lived operational safeguards.
