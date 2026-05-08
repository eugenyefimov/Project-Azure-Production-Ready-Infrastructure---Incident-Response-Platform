# Lessons Learned (Sample)

## What went well
- Restore execution was measurable from decision point to stable service readiness.
- Validation steps avoided “alert resolved = done” closure errors by requiring monitoring and network parity checks.

## What was risky / slow
- Monitoring telemetry might lag restore completion; closure must explicitly include an ingestion watch window.
- Network parity issues can surface after service smoke checks; always run NIC NSG/DNS/route validation before PASS closure.

## What we will change in future drills
- Add a tighter preflight step to confirm restore target subnet delegation compatibility.
- Make the monitoring watch window criteria explicit in the validation checklist.
- Store evidence in consistent filenames so reviewers can audit without searching.

