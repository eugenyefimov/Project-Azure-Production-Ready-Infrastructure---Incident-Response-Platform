# Restore Drill Evidence: 2026-05 Monthly Drill

This folder contains evidence artifacts for a monthly VM restore drill.

Note on realism:
- The drill process is operationally realistic (Azure Backup restore -> new VM -> reachability -> service checks -> monitoring + network parity validation).
- The specific run in this portfolio is provided as a **template-grade example**. Update it with real job IDs, timestamps, and command outputs when running in a live tenant.

Drill identification
- **Drill ID:** `DRILL-2026-05-MONTHLY-01`
- **Environment:** `staging` (isolated recovery scope)
- **Workload:** `customer-api` (Linux VM with Nginx baseline)
- **Backup method:** Azure Recovery Services Vault VM backup

Expected objectives (baseline)
- **RPO:** `<= 24h`
- **RTO target:** `30-90 minutes` (document measured RTO range)

Evidence files in this folder
- `drill-preparation-checklist.md`
- `restore-execution-steps.md`
- `restore-execution-evidence.md`
- `alerting-and-monitoring-evidence.md`
- `validation-checklist.md`
- `network-parity-checks.md`
- `failure-scenarios.md`
- `rollback-considerations.md`
- `operational-findings.md`
- `lessons-learned.md`
- `future-improvements.md`
- `screenshots/` (placeholders)

