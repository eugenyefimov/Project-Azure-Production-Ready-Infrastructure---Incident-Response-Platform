# VM Recovery Runbook

This runbook describes recovery steps for Linux and Windows Azure VMs protected by Recovery Services Vault backups.

## Recovery Objectives

- **RPO (Recovery Point Objective):** up to 24 hours with current daily backup schedule.
- **RTO (Recovery Time Objective):** typically 30-90 minutes for single VM restore (depends on disk size and region load).

## When to Use This Runbook

- VM corruption or failed boot
- OS-level compromise requiring known-good restore point
- Accidental destructive change to system state

## Restore Steps (Azure Portal)

1. Open **Recovery Services Vault** -> **Backup items** -> **Azure Virtual Machine**.
2. Select affected VM and open **Restore VM**.
3. Choose restore point timestamp (closest safe point before incident).
4. Select restore type:
   - **Create new VM** (recommended first for validation and low-risk recovery)
   - **Replace existing** (use only with change approval)
5. Select target resource group, network, and naming suffix.
6. Start restore job and monitor **Backup Jobs** until completed.
7. Validate restored VM:
   - boot state
   - network reachability
   - application/service checks
8. Update incident ticket with restore point used, start/end times, and validation evidence.

## Post-Restore Validation

- Confirm NSG rules and subnet placement are correct.
- Confirm monitoring agent/log flow resumes.
- Confirm backup protection is still enabled for restored workload.
- Run smoke tests (SSH/RDP + service checks).

## Escalation Criteria

- No valid restore points in expected window
- Restore job fails repeatedly
- Data integrity concerns after restore

Escalate to cloud platform owner and incident manager with job ID and vault details.
