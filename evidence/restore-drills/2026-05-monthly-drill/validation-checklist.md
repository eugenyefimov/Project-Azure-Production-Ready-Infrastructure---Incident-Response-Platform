# Restore Validation Checklist (Pass/Fail)

This checklist is the closure basis for the drill.

## Time anchors (UTC)
- Restore decision point: `2026-05-08T09:00:00Z` (example)
- Restore job completed: `2026-05-08T09:42:30Z` (example)
- First successful VM reachability check: `2026-05-08T09:47:10Z` (example)
- Service stable time (closure watch start): `2026-05-08T09:52:00Z` (example)
- Monitoring stable time (closure watch end): `2026-05-08T10:07:00Z` (example)

## Pass / Fail criteria (mark each)

### A) Restore job succeeded
- [ ] Restore status `Completed`
- Evidence: `restore-execution-evidence.md` and `screenshots/restore-job.png`

### B) VM boot / reachability
- [ ] Linux SSH reachable for restored VM
- Evidence: command output / screenshot `screenshots/restored-vm.png`

### C) Service smoke check (Nginx baseline)
- [ ] `systemctl is-active nginx` = `active`
- [ ] Health endpoint returns expected HTTP code
- Evidence: `curl` output and `screenshots/health-check.png`

Example service checks:
```bash
sudo systemctl is-active nginx
curl -fsS -o /dev/null -w "%{http_code}" http://127.0.0.1/
```

### D) Monitoring verification
- [ ] Heartbeat telemetry resumes in Log Analytics within expected watch window
- [ ] CPU/availability metrics ingestion visible again after restore
- Evidence: monitoring evidence file (`alerting-and-monitoring-evidence.md`)

### E) Network parity validation
- [ ] Restored NIC attached to expected subnet and NSG association exists
- [ ] DNS settings match baseline expectations
- [ ] Effective routes match current VNet baseline
- Evidence: `network-parity-checks.md`

## Drill closure decision
- Pass criteria outcome: `[PASS/FAIL]`
- Notes on any deviations:
  - Example: “telemetry ingestion delayed by 4 minutes; closure still allowed after stable watch window”

