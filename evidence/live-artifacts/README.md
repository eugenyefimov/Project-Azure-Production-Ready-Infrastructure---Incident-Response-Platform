# Live Artifacts Evidence Pack

This folder is used for credibility-focused operations evidence.

Status labels used here:
- **Real Sanitized Export**: exported from a real environment and sanitized for public sharing
- **Simulated/Sanitized Sample**: structured sample to demonstrate process until real export is added
- **Planned**: target artifact not yet included

## What is currently simulated vs real

- `azure-monitor-alert-history.csv` -> **Simulated/Sanitized Sample**
- `activity-log-entries.csv` -> **Simulated/Sanitized Sample**
- `terraform-apply-history.csv` -> **Simulated/Sanitized Sample**
- `log-analytics-query-exports.md` -> **Simulated/Sanitized Sample**
- `policy-compliance-evidence.md` -> **Simulated/Sanitized Sample**

When you replace a sample with a real export, add a header line in the file:
`Status: Real Sanitized Export (captured YYYY-MM-DD, environment <env>)`

## Why sanitization is required

- protect tenant IDs, subscription IDs, object IDs, hostnames, email addresses, and IP ranges
- avoid exposing internal naming patterns and privileged account details
- keep artifacts shareable for hiring/review without leaking sensitive operational data

## Acceptable sanitization patterns

- replace subscription IDs with `00000000-0000-0000-0000-000000000000`
- replace object IDs with `<redacted-object-id>`
- replace public IPs with RFC5737 examples (`203.0.113.10`, `198.51.100.5`)
- mask tenant-specific hostnames as `<env>-vm-app-01`
- keep timestamps, severity, correlation IDs, and sequence order where possible

Do not modify:
- event ordering
- incident IDs and cross-reference keys
- pass/fail outcomes

## Minimum credible artifact set

Add at least one **Real Sanitized Export** for each:
1. alert history slice (`alerts fired/ack/closed`)
2. KQL query result slice for an incident window
3. backup or restore job output
4. policy compliance export
5. CI/CD plan/apply proof excerpt

## Authenticity without raw secrets

Authenticity is preserved by:
- stable IDs linking alert -> query -> change -> mitigation
- consistent timestamps across artifacts
- direct mapping to implemented Terraform/workflow controls
- explicit labels whenever content is simulated
