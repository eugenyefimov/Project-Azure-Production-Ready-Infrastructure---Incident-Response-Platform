# Synthetic Monitoring Evidence Example

This file shows the expected evidence format after enabling Terraform-based synthetic monitoring.

## Evidence Scope

- Control: Application Insights web test against Nginx endpoint
- Endpoint under test: `https://example-prod-nginx-endpoint/`
- Environment: `prod`
- Window: `2026-05-08T06:00:00Z` to `2026-05-08T10:00:00Z`

## Availability Test Result Snapshot (Sanitized)

- Web test name: `synthetic-nginx-endpoint`
- Probe frequency: `300s`
- Failed location threshold: `2`
- Result summary:
  - Total checks: `48`
  - Failed checks: `3`
  - Availability: `93.75%`
  - Failure burst: `2026-05-08T08:35Z` to `2026-05-08T08:46Z`

## Alert Evidence

- `alert-service-availability-endpoint`:
  - Triggered: `2026-05-08T08:40:31Z`
  - Severity: `Sev1`
  - Reason: failed probe locations >= configured threshold
- `alert-service-synthetic-latency-high`:
  - Triggered: `2026-05-08T08:21:10Z`
  - Severity: `Sev2`
  - Reason: 15-minute average synthetic latency > `2000ms`

## KQL Validation Snippet (Log Analytics)

```kusto
AppAvailabilityResults
| where Name == "synthetic-nginx-endpoint"
| where TimeGenerated between (datetime(2026-05-08T06:00:00Z) .. datetime(2026-05-08T10:00:00Z))
| summarize
    TotalChecks = count(),
    FailedChecks = countif(Success == false),
    AvgDurationMs = avg(DurationMs),
    P95DurationMs = percentile(DurationMs, 95)
```

## Operational Notes

- This evidence proves service-path observability, not just VM-level health.
- Keep endpoint and alert thresholds consistent with user impact and on-call capacity.
- Attach real exported query results and alert payloads for interview review when available.
