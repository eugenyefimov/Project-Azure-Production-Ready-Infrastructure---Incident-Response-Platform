# Log Analytics Query Results (Sanitized Samples)

These are representative outputs captured from investigation queries used during active incidents.

## Query A: Failed Logins by Account and Source (Last 60 Minutes)

| Time Window (UTC)     | Account            | Source IP     | Host                                  | FailedAttempts |
|-----------------------|--------------------|---------------|---------------------------------------|----------------|
| 2026-04-30 08:00-09:00| svc-backup-agent   | 10.20.14.11   | az-ir-platform-p-westeurope-vm-mgmt-01| 3              |
| 2026-04-30 08:00-09:00| admin.platform     | 185.142.41.77 | az-ir-platform-p-westeurope-vm-mgmt-01| 14             |
| 2026-04-30 08:00-09:00| admin.platform     | 185.142.41.79 | az-ir-platform-p-westeurope-vm-mgmt-01| 9              |
| 2026-04-30 08:00-09:00| helpdesk.ops       | 10.10.30.24   | az-ir-platform-p-westeurope-vm-mgmt-01| 2              |

Operator note:
- `svc-backup-agent` failures were expected after password rotation drift; corrected by secret sync.
- public IP attempts escalated to security triage due to burst behavior.

## Query B: VM Health Trends (Heartbeat Gaps, Last 24 Hours)

| Host                                  | LastHeartbeatUTC      | MinutesSinceHeartbeat | HealthState |
|---------------------------------------|------------------------|-----------------------|-------------|
| az-ir-platform-p-westeurope-vm-app-01 | 2026-04-30 00:46:58    | 1                     | Healthy     |
| az-ir-platform-p-westeurope-vm-mgmt-01| 2026-04-30 00:46:31    | 1                     | Healthy     |
| az-ir-platform-s-westeurope-vm-app-01 | 2026-04-30 00:40:11    | 7                     | Warning     |

Operator note:
- staging app VM heartbeat delay correlated with patch cycle; no user impact.

## Query C: Resource Anomaly Candidates (CPU Deviation >= 2x Baseline)

| TimeGeneratedUTC      | Host                                  | CurrentCPU | BaselineCPU | DeviationRatio |
|-----------------------|---------------------------------------|------------|-------------|----------------|
| 2026-04-29 14:10:00   | az-ir-platform-p-westeurope-vm-app-01 | 83.4       | 33.7        | 2.47           |
| 2026-04-29 14:25:00   | az-ir-platform-p-westeurope-vm-app-01 | 79.1       | 34.8        | 2.27           |
| 2026-04-29 14:40:00   | az-ir-platform-p-westeurope-vm-app-01 | 68.2       | 35.1        | 1.94           |

Operator note:
- final row dropped below alert threshold but remained elevated; investigation kept open for 30 more minutes.
