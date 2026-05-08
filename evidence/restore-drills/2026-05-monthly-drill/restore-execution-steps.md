# Restore Execution Steps (What to Run / What Was Done)

This file serves as a step-by-step operational log for the drill.

## Step 1: Identify backup item and restore point
1. List backup items:
   - Record command output / screenshot:
     - placeholder: `screenshots/restore-preflight.png`
2. Select restore point closest to expected window:
   - Selected restore point: `2026-05-01T00:00:18Z` (example)

## Step 2: Start restore to a new VM
1. Restore target:
   - Restore type: **Create new VM**
   - Isolated drill resource group for restored VM:
     - placeholder: `az-ir-platform-s-westeurope-rg-restore-drill`
2. Start restore:
   - Record restore job name/id:
     - placeholder: `RestoreDisks_<id>`

## Step 3: Monitor restore job
1. Poll restore job status until:
   - `properties.status = Completed`
2. Capture timestamps:
   - start time
   - end time

## Step 4: Provisioning wait and reachability checks
1. Verify VM instance view reaches “running”
   - evidence: `az vm get-instance-view` output snippet
2. Verify reachability:
   - Linux: SSH (private IP) + service port reachability

## Step 5: Service smoke check
1. Verify Nginx service:
   - `sudo systemctl is-active nginx`
2. Verify local health endpoint:
   - `curl -fsS -o /dev/null -w "%{http_code}" http://127.0.0.1/`

## Step 6: Monitoring + network parity validation
1. Run monitoring verification:
   - Heartbeat / Perf ingestion check in Log Analytics
2. Run network parity validation:
   - effective NSG
   - effective route table
   - NIC DNS settings

## Evidence placeholders
- `screenshots/restore-job.png`
- `screenshots/restored-vm.png`
- `screenshots/health-check.png`
- Command output snippets stored as links or embedded excerpts

