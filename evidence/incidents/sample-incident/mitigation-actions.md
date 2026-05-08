# Mitigation Actions (Sample)

## Immediate actions (reduce user impact)

### 1) Confirm the affected scope and safe rollback posture
- Role: on-call engineer
- `2026-05-08T10:22:30Z` - Confirm VM reachable and Nginx service state (no network isolation actions yet)
- `2026-05-08T10:23:10Z` - Check if a recent infra change occurred (use Azure Activity evidence, if available)

### 2) Apply workload-level mitigation
- Role: on-call engineer
- `2026-05-08T10:35:40Z` - Identify top CPU-consuming processes/workload signals on the VM:
  - Linux: `top` / `ps` to find the main CPU consumer
- `2026-05-08T10:37:20Z` - Restart Nginx to clear stuck worker/load conditions:

```bash
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager
```

### 3) Reduce recurrence risk during the incident
- Role: on-call engineer
- `2026-05-08T10:40:00Z` - Temporarily stop the suspected high-load job (if it is a cron/task on the VM)
- Record: start/stop times in incident channel for closure criteria.

## Decision logging (audit trail)
- `2026-05-08T10:50:30Z` - Decision:
  - No VM re-provision required to restore service
  - Root-cause fix to be executed via change workflow (follow-up)

