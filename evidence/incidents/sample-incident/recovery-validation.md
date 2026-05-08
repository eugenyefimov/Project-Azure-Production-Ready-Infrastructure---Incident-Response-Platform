# Recovery Validation (Sample)

Objective:
- confirm service stability (not only “CPU is falling”)
- confirm monitoring is healthy again for follow-up and evidence

## Recovery validation window
- Start: `2026-05-08T10:50:30Z` (mitigation decision logged)
- End: `2026-05-08T10:57:30Z` (stable checks passed)

## Closure criteria (pass/fail)

### A) VM / host stability
- [x] Host heartbeat stable (no heartbeat gaps in watch window)
- [x] CPU drops below alert threshold for at least one sustained interval

### B) Service checks (customer-facing)
- [x] Nginx service is active:

```bash
sudo systemctl is-active nginx
```

- [x] Local health endpoint responds (example: local HTTP check)

```bash
curl -fsS -o /dev/null http://127.0.0.1/health || curl -fsS -o /dev/null http://127.0.0.1/
```

### C) No immediate regression
- [x] No new high-CPU alerts in the final watch window
- [x] No recurring escalation within closure 10 minutes

## Evidence captured
- On-call commands output excerpts stored in incident channel (link in incident record).
- KQL analysis results archived for audit review.
- Alert history rows exported for the incident window.

## Escalation and ownership closure
- `2026-05-08T10:28:00Z` Escalated to incident commander
- `2026-05-08T10:33:15Z` Escalated to duty manager
- `2026-05-08T11:00:00Z` Incident closed

