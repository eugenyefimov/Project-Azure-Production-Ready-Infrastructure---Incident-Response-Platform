# Lessons Learned (Sample)

## What worked
- VM-level availability monitoring kept the team from chasing connectivity-only hypotheses.
- The CPU alert provided a timely symptom anchor and gave responders a clear next step (apply high-CPU runbook).
- Recovery validation used a watch window and service checks, not only “alert resolved”.

## What slowed us down
- Initial triage required manual correlation to confirm whether the CPU spike was expected (known workload) or runaway.
- The CPU symptom did not immediately identify the primary CPU consumer; additional process-level evidence collection took time.

## Changes we will enforce next time
- During Sev2 CPU incidents:
  - first 10 minutes must include “top CPU consumer process identification” on the VM,
  - escalation criteria should be explicit if mitigations do not restore service stability quickly.

