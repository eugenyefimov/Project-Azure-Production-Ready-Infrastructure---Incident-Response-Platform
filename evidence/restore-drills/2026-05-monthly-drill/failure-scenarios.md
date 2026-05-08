# Failure Scenarios (If/When They Happen)

This document enumerates realistic restore drill failure modes and how to handle them without breaking operational safety.

## Scenario A: Restore job fails (NIC attachment / delegation mismatch)
- Typical symptom:
  - Azure Backup restore job error indicates the target network/subnet is incompatible
  - example class: “delegated subnet cannot attach restored VM NIC”
- Detection:
  - restore job status != `Completed`
  - restore job error details available in the portal / `az backup job show`
- Containment:
  - do not proceed to “replace existing VM” unless change approval is explicit
  - switch restore target to a non-delegated subnet and ensure NSG association matches the app VM baseline
- Recovery evidence:
  - restore job error details excerpt
  - updated target selection notes

## Scenario B: Restore job completes, but VM is unreachable
- Typical symptom:
  - VM doesn’t reach running state within expected provisioning delay
  - SSH/RDP checks fail
- Detection:
  - `az vm get-instance-view` indicates provisioning issues
  - SSH/RDP connection attempts fail
- Containment:
  - treat as a restore failure for closure criteria
  - verify boot diagnostics/serial logs if available
- Recovery evidence:
  - VM instance view + error summary

## Scenario C: VM is reachable but service smoke check fails
- Typical symptom:
  - Nginx not active or returns unexpected HTTP status
- Detection:
  - `systemctl is-active nginx` != `active`
  - `curl` health check returns failure code
- Containment:
  - do not “open NSG broader” as first mitigation
  - validate config/ports locally on VM first
- Recovery evidence:
  - service status output and local curl results

## Scenario D: Restore completes, but monitoring ingestion is delayed
- Typical symptom:
  - VM reachability is OK, but Heartbeat or metrics are missing in Log Analytics for the watch window
- Detection:
  - Log Analytics queries show stale LastHeartbeat timestamp
- Containment:
  - closure requires documented watch-window behavior:
    - either monitoring resumption occurs within the allowed window
    - or closure is marked as FAIL due to missing telemetry stability
- Recovery evidence:
  - Log Analytics query output snapshot / timestamps

## Scenario E: Network parity mismatch after restore (DNS/NSG/route)
- Typical symptom:
  - local service checks pass but external connectivity fails
  - DNS resolution behaves differently than current baseline
- Detection:
  - network parity checks fail (effective NSG/route/DNS settings mismatch)
- Containment:
  - do not close incident if parity mismatch exists; remediation must align restored NIC/network baseline
- Recovery evidence:
  - effective NSG/route and DNS values before/after remediation

