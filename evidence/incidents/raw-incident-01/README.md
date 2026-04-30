# Raw Incident Evidence Bundle 01

Incident reference: `INC-2026-05-18-002`  
Environment: `prod`  
Service: `customer-api`

This bundle is intentionally raw-style. Artifacts are presented in the same order responders used them during the incident.  
Redaction is minimal (`<sub-id>`, `<tenant-id>`, `<endpoint>`).

## Artifact Order (Alert -> Logs -> Commands -> Fix -> Verify)

1. `01-alert-payload.json`
2. `02-activity-log-list-raw.txt`
3. `03-log-analytics-raw-results.txt`
4. `04-commands-executed-raw.txt`
5. `05-terraform-apply-raw-snippet.txt`

## What Happened (Operator Notes)

### Wrong hypothesis first

- Initial assumption at `13:10 UTC`: deployment regression only (CPU-driven).
- Supporting early evidence:
  - high CPU anomaly fired before network-path alert
  - cache miss and queue depth spikes in app logs
- Why it was wrong:
  - this explained latency and retries, but not region-specific request denials.

### Pivot moment

- Pivot at `13:19-13:23 UTC` after two signals:
  - network-path query alert reported denied `TCP/443` for trusted CIDR
  - effective NSG output showed trusted source range missing from allow rule
- Direction changed from single-cause rollback to dual-fault mitigation.

### Final fix

- Restored missing trusted CIDR in prod NSG allow rule.
- Rolled back deployment from `REL-2026.05.18.1` to `REL-2026.05.17.7`.
- Applied through controlled Terraform run (`run_id: 10486736788`).

### Verification evidence

- regional failure rate converged from ~54% to <7% in affected region
- p95 latency dropped from ~3s to <800ms
- no repeated deny entries for trusted CIDR in post-fix window
- no new `Sev1` alerts during 27-minute watch period
