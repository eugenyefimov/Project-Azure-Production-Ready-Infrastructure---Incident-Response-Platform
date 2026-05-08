# Incident Timeline (Sample)

All timestamps are UTC. This timeline is written for operational review and auditability.

## T0: Detection and classification
- `2026-05-08T10:15:00Z` - Incident declared (performance symptoms first observed by monitoring + user reports)
- `2026-05-08T10:18:45Z` - First high-confidence alert fired: `alert-vm-high-cpu` (`Sev2`)
- `2026-05-08T10:19:10Z` - On-call acknowledges alert in incident channel (MTTA anchor)
- `2026-05-08T10:22:30Z` - Initial triage confirms:
  - VM host is reachable
  - CPU is sustained above threshold
  - service latency is elevated (partial impact)

## T1: Escalation
- `2026-05-08T10:28:00Z` - Escalated to incident commander (customer impact ongoing; first mitigation insufficient)
- `2026-05-08T10:33:15Z` - Escalated to duty manager (risk of error budget consumption; sustained Sev2 profile)

## T2: Mitigation
- `2026-05-08T10:35:40Z` - Mitigation begins: identify top CPU consumers and restart affected service component(s)
- `2026-05-08T10:42:05Z` - Mitigation step completed: CPU begins to fall toward baseline
- `2026-05-08T10:50:30Z` - Apply-only remediation decision logged:
  - service instability mitigated without VM re-provision
  - follow-up scheduled for root-cause fix via change workflow

## T3: Recovery and stabilization
- `2026-05-08T10:57:30Z` - Recovery validation completed (service stable checks pass for watch window)
- `2026-05-08T11:00:00Z` - Incident closed after confirmation of no regressions and reduced alert recurrence

## Operational metrics (anchors)
- **MTTD**: `10:18:45Z - 10:15:00Z` = 3m45s (~3.75m)
- **MTTA**: `10:19:10Z - 10:18:45Z` = 25s (~0.42m)
- **MTTR**: `10:57:30Z - 10:19:10Z` = 38m20s (~38.33m)

Note: MTTA can be sensitive to when “ack” is recorded; keep “ack semantics” consistent across incidents.

