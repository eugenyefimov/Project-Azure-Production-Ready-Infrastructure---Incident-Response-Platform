# Rollback / Mitigation Considerations

Restore drills are not application releases, so “rollback” usually means:
- stop the drill safely
- revert any drill-specific changes made to the isolated target resources
- preserve evidence for analysis

## What is considered rollback-safe in a drill

1. **If restore job fails** before any VM becomes reachable:
   - do not modify production resources
   - adjust drill-only restore target configuration (e.g., target subnet choice) only after documenting the failure class

2. **If restore succeeds but service smoke check fails**:
   - keep restored VM in place until evidence is captured
   - remediate using OS-level and baseline checks first (service restart, configuration validation)
   - avoid “broad network changes” as rollback unless network parity validation indicates a definite mismatch

3. **If monitoring ingestion is delayed**:
   - do not terminate early
   - validate agent/telemetry status (heartbeat/AMA equivalent where available)
   - apply closure criteria only when telemetry is stable or declare failure explicitly

## Drill-specific rollback steps (recommended)

### Step 1: Freeze the drill state
- capture:
  - restore job ID/name
  - restore point used
  - time window of the failure
  - current VM instance view

### Step 2: Revert drill-only network settings
- if NSG/subnet assignment changed during remediation:
  - return to baseline equivalent values for the app workload subnet

### Step 3: Capture “before/after” evidence
- screenshot placeholders:
  - `screenshots/restore-job.png`
  - `screenshots/restored-vm.png`
  - `screenshots/health-check.png`
- command evidence:
  - `az vm get-instance-view`
  - `systemctl is-active nginx`
  - Log Analytics heartbeat query output

### Step 4: Close with PASS/FAIL and record why
- do not reinterpret failures as success

## Limitations

This repository does not implement automated rollback orchestration for restore drills.
Rollbacks are procedural and intentionally conservative to maintain evidence integrity.

