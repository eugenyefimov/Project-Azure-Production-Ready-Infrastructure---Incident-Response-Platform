# Drill Preparation Checklist

This checklist documents pre-drill preparation to avoid “procedural failures” and to make the drill reproducible.

## 0) Administrative metadata
- Drill ID: `DRILL-2026-05-MONTHLY-01`
- Evidence folder: `evidence/restore-drills/2026-05-monthly-drill/`
- Environment: `staging`
- Workload: `customer-api` (Linux VM, Nginx baseline)
- Requested by / owner role: on-call SRE (fill in)

## 1) Backup metadata and restore point selection
- [ ] Recovery Services Vault selected: (fill vault name)
- [ ] Protected VM item confirmed: (fill backup item name)
- [ ] Latest successful restore point identified: `2026-05-01T00:00:18Z` (example)
- Evidence:
  - restore point details exported from portal or Azure CLI (link to command output snippet if available)

## 2) Restore target network compatibility preflight
- [ ] Restore to **Create new VM** (recommended low-risk option)
- [ ] Target restore subnet selected is non-delegated for VM NIC attachment
- [ ] NSG expected for the restored VM NIC/subnet is present or will be applied to match baseline
- Evidence:
  - `network-parity-checks.md` will capture before/after values

## 3) Validation endpoints and reachability checks
- [ ] VM reachability method chosen:
  - Linux: SSH method + private key access assumed
  - Windows: RDP method (not used in this sample)
- [ ] Service smoke check endpoint chosen:
  - Linux: local health check via `curl` (or external trusted source check if applicable)

## 4) Monitoring verification watch window
- [ ] Watch window defined:
  - default: `15 minutes` from first successful service smoke check
- [ ] Closure criteria explicitly recorded:
  - monitoring ingestion resumes (Heartbeat)
  - no persistent alert storm attributed to restore

## 5) Screenshots and evidence capture plan
- [ ] Screenshot placeholders prepared:
  - `screenshots/restore-job.png`
  - `screenshots/restored-vm.png`
  - `screenshots/health-check.png`

Notes / limitations:
- This repo baseline is cost-conscious; restore timing and telemetry ingestion delay should be expected to vary.

