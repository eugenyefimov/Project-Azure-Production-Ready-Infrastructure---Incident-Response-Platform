# Root Cause Analysis (Sample)

## Root cause statement
The CPU spike was caused by a runaway workload on the VM that increased CPU utilization for the duration of the alert window, leading to degraded Nginx request handling. Host health remained normal, so the incident was compute/workload saturation rather than a connectivity outage.

## Contributing factors
- Workload burst aligned with the alert window and sustained CPU elevation (Perf evidence).
- Nginx restart reduced symptoms, indicating the performance impact was in the request handling path rather than a hard VM outage.
- Lack of a pre-change load validation step for this workload meant the CPU threshold was exceeded before detection reached an actionable state.

## Why safeguards were insufficient
- Alerting is threshold-based (CPU sustained > configured percent). It detected the symptom but did not differentiate “expected burst” vs “runaway workload” early.
- Runbooks provided a triage path, but the incident required escalation because mitigations did not immediately restore service stability.

## Evidence correlation performed
- Verified CPU sustained above baseline in Log Analytics (KQL signal query).
- Verified host heartbeat remained healthy (differentiator query) to rule out VM outage narratives.
- Reviewed Azure Activity (optional query) for any VM/extensions changes in the pre-alert window.

