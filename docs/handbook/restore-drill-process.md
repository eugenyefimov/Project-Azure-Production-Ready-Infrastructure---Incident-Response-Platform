# Restore Drill Process (Monthly VM Recovery)

This document defines a repeatable restore drill process for Azure VM backups created with **Recovery Services Vault** and **daily VM backup policies**.

It is written to build operational trust:
- backups are not just “configured,” they are **recoverable and verifiable**
- recovery procedures are **repeatable** under realistic constraints
- incident responders have **evidence they can audit**

## Scope (what this drill covers)

This drill validates Recovery Services Vault restores for:
- Linux VM(s) protected by `azurerm_backup_protected_vm`
- Windows VM(s) protected by `azurerm_backup_protected_vm`

Restore method:
- **Recommended:** restore to **Create new VM** (low-risk validation)
- **Replacement restore:** allowed only when explicitly approved (higher blast radius)

## Explicit limitations (read first)

1. **Cost-conscious baseline:** the repo’s default backup policy is daily with short retention (see `backup_time_utc` and `backup_daily_retention_count` inputs). This limits intra-day RPO precision.
2. **Queue and throughput variability:** restore RTO is affected by Azure Backup restore queue load, disk size, and region load. Treat RTO as a measurable range, not a guaranteed constant.
3. **Telemetry dependencies:** recovery validation assumes Log Analytics/agent telemetry exists (Heartbeat/AMA or equivalent). If the monitoring pipeline is disrupted, some “monitoring verification” checks become limited.
4. **Network parity assumptions:** a successful restore does not automatically guarantee DNS/network parity with current subnet baseline. Closure must include **network parity validation**.
5. **Delegated subnet constraints:** if restore-to-network targeting uses a delegated subnet (e.g., container delegated subnet), VM NIC attachment may fail. The drill explicitly includes preflight checks to avoid this failure class.

## Recovery objectives

For this repository’s default daily backup schedule:
- **RPO:** up to `<= 24h` (daily backup schedule)
- **RTO target:** typically `30-90 minutes` for a single VM restore to new VM, depending on disk size and restore queue

Source of truth:
- `vm-recovery.md` (RPO/RTO guidance)
- `backup-verification.md` (daily checks + restore drill guidance)
- `modules/incident-response/main.tf` (daily backup schedule)

## Evidence requirements (non-negotiable)

For each drill run, capture evidence artifacts and store them under the drill folder:

### Required evidence files / placeholders
- `alerting-and-monitoring-evidence.md` (what was checked after restore)
- `restore-execution-evidence.md` (restore job IDs, start/end times, restore point used)
- `validation-checklist.md` (pass/fail outcomes with timestamps)
- `network-parity-checks.md` (effective NSG/route + DNS settings verification)
- `screenshots/` placeholders:
  - `screenshots/restore-job.png` (backup job status)
  - `screenshots/restored-vm.png` (VM boot + instance view)
  - `screenshots/health-check.png` (service health check response)

If screenshots are not available in the environment, document the commands run instead and reference their output snippets.

## Pass / Fail criteria

### Pass criteria (must meet all)

1. **Restore job completes successfully**
   - Backup restore job status = `Completed`
   - Restore point used is within the expected daily RPO window (`<= 24h`)
2. **VM boots and is reachable**
   - Linux: SSH works (or equivalent credential method)
   - Windows: RDP works (or equivalent credential method)
3. **Service-level smoke check passes**
   - Linux VM: Nginx is active (and local or external HTTP health check returns expected code)
4. **Monitoring signals recover**
   - Log Analytics ingestion resumes for Heartbeat (or equivalent telemetry)
   - no persistent “post-restore” metric noise beyond the expected watch window (document any anomalies)
5. **Network parity is validated**
   - NSG/route/DNS settings for the restored NIC match the current baseline expectations

### Fail criteria (any one fails the drill)

- Restore job fails (or requires repeated retries beyond the defined drill tolerance)
- Restored VM is unreachable (SSH/RDP) beyond acceptable provisioning delay
- Service smoke check fails
- Monitoring ingestion does not resume within the defined watch window
- Network parity validation reveals a meaningful mismatch (DNS misconfiguration, NSG misbinding, route mismatch) without remediation

## Drill preparation checklist

Preparation is intended to reduce failures that are procedural rather than backup-related.

### 1) Select drill target and restore point
- Choose one protected VM:
  - Linux app VM recommended first (smaller surface and simpler smoke checks)
  - Windows management VM only if operationally validated in prior drills
- Identify the most recent successful restore point
- Record:
  - restore point timestamp
  - restore point type (e.g., crash-consistent) if available

### 2) Preflight: backup metadata and job history
- Confirm Recovery Services Vault name and resource group are correct
- Confirm the VM is in **Backup items** and has a recent successful restore point

### 3) Preflight: restore target network compatibility
- Confirm restore-to-network target will allow restored VM NIC attachment
- Block or avoid delegated subnets for VM restore target
- Confirm expected NSG association exists for the restored VM NIC/subnet

### 4) Prepare validation endpoints
- Record:
  - VM private IP (expected baseline)
  - service health check endpoint used for verification (e.g., local `http://localhost` or externally from trusted source)

### 5) Define watch window
- Monitoring verification watch window:
  - start at “first service check success”
  - default `15 minutes` to confirm Heartbeat/telemetry stability

## Restore execution steps (Azure CLI oriented)

The process below assumes you can run Azure CLI with appropriate RBAC permissions in the subscription / vault scope.

### Step 1: Identify backup item and restore point
1. List backup items and match friendly name:
   - `az backup item list ...`
2. Get recovery points:
   - `az backup recoverypoint list ...`

Record:
- backup item name
- recovery point name / ID used by restore

### Step 2: Start restore to **Create new VM**
1. Run restore-disks to a new target resource group (isolated)
2. Wait for restore job completion:
   - capture restore job ID
   - capture restore job start/end times

### Step 3: Provisioning wait + instance view checks
1. Verify VM instance view:
   - power state = running
2. Verify VM SSH/RDP reachable:
   - within “acceptable provisioning delay”

## Validation checklist (service + monitoring + network parity)

Use the following checklist. Mark each as pass/fail and record timestamps.

### A) VM boot / reachability
- [ ] Linux: `ssh` works
- [ ] Windows: `Test-NetConnection` / RDP port reachable
- Evidence: command output and screenshot placeholders

### B) Service smoke check (Nginx baseline)
- [ ] Nginx is active
- [ ] Health check endpoint returns expected HTTP code

Example commands (Linux):
```bash
sudo systemctl is-active nginx
curl -fsS -o /dev/null -w "%{http_code}" http://127.0.0.1/ || true
```

### C) Monitoring verification (Log Analytics ingestion)
- [ ] Heartbeat telemetry resumes (no persistent heartbeat gaps)
- [ ] Metrics ingestion continues (CPU/availability signals visible after restore)

If Heartbeat isn’t available, document what telemetry is available and why closure criteria changes.

### D) Network parity validation
- [ ] Restored NIC is associated with expected subnet and NSG binding
- [ ] DNS settings match baseline expectations
- [ ] Routes are consistent with current VNet baseline

Azure verification commands (examples):
```bash
az network nic show --ids <restored-nic-id> --query "ipConfigurations[].privateIpAddress"
az network nic show-effective-nsg -g <rg> -n <nic-name>
az network nic show-effective-route-table -g <rg> -n <nic-name>
```

## Failure scenarios and rollback considerations

This section enumerates realistic failure classes and what to do next.

### Scenario 1: Restore job fails due to delegated subnet / NIC attachment conflict
- Symptom: restore job status fails with NIC attachment / delegation mismatch
- Containment:
  - do not proceed with workaround “replace existing VM” restore
- Recovery:
  - select a non-delegated subnet target for the restored VM
  - ensure NSG association matches the app VM baseline
- Evidence:
  - restore job error details + updated target selection notes

### Scenario 2: Restore job succeeds but service smoke check fails
- Symptom: VM boot is OK, but Nginx is not healthy / config error
- Containment:
  - validate OS-level service status and logs
- Recovery:
  - restart service (validated config)
  - if persistent, consider restoring application configuration via baseline known-good approach
- Evidence:
  - service logs (snippets), commands executed

### Scenario 3: Restore succeeds but monitoring ingestion is delayed
- Symptom: VM is reachable, but Heartbeat/telemetry is missing or delayed
- Containment:
  - document watch window and time-to-telemetry
- Recovery:
  - validate monitoring agent/extension status
- Evidence:
  - agent status and any related extension logs

### Scenario 4: Network parity mismatch after restore (DNS/NSG/UDR mismatch)
- Symptom: service check may pass locally, but connectivity fails externally or DNS is wrong
- Containment:
  - do not “close early”; treat as meaningful mismatch
- Recovery:
  - remediate restored NIC settings to match baseline
  - re-run service and monitoring checks for the closure watch window

## Operational findings section (what you record)

Record the following:
- restore point age (hours)
- measured RTO (start -> service stable time)
- measured “monitoring resumption time” (service stable -> telemetry stable)
- any evidence gaps (missing telemetry categories, incomplete screenshots)
- what failure class occurred (if any)

## Lessons learned and future improvements

Prevention improvements should map to:
- runbook updates
- preflight checklist tightening
- CI/CD/workflow guardrails (if restore automation is created later)
- monitoring verification query tweaks

No “big bang DR architecture.” Prefer incremental maturity based on actual failures observed.

