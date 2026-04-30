# Restore Drill Trend Report

Purpose: show repeated recovery testing behavior over time, including failures and operational learning.

Scope:

- workload: `customer-api` VM path
- platform: Azure Recovery Services Vault + CLI-led validation
- environment used for drills: isolated `staging` recovery scope

## Drill 1 - `RESTORE-2026-03-08-01`

- **Date/time:** `2026-03-08 07:40-08:29 UTC`
- **Trigger scenario:** simulated VM boot corruption after package update
- **Restore method used:** Azure Backup (Recovery Services Vault) via CLI
- **Start timestamp:** `2026-03-08T07:40:12Z`
- **Restore completion timestamp:** `2026-03-08T08:17:53Z`
- **Measured RTO:** `49m 11s`
- **Expected vs actual RPO:**
  - expected: `<=24h` (daily backup policy)
  - actual restore point age: `11h 09m`

Validation steps:

- service reachability: `HTTP 200` on `/health` from jump host
- logs consistency: app startup sequence present; no crash loop
- monitoring signals: heartbeat resumed after restore, but alert noise persisted for ~4 minutes

Issues encountered:

- DNS resolver on restored NIC inherited stale custom DNS setting
- first smoke test failed due to unresolved internal dependency host

Mistakes / wrong assumptions:

- assumed restored NIC settings would match current subnet baseline automatically

Fixes applied:

- updated NIC DNS to expected resolver pair
- added post-restore check item: `az network nic show --query "dnsSettings"`

Lessons learned:

1. restore success does not guarantee network parity with current baseline
2. first healthy app response can hide dependency lookup issues

Operational improvement:

- runbook updated with mandatory DNS and route verification before service validation.

---

## Drill 2 - `RESTORE-2026-04-21-02` (failed-first)

- **Date/time:** `2026-04-21 18:05-19:23 UTC`
- **Trigger scenario:** simulated OS disk unreadable + service unreachable
- **Restore method used:** Azure Backup restore-disks via CLI (attempt #1 failed, attempt #2 succeeded)
- **Start timestamp:** `2026-04-21T18:05:41Z`
- **Restore completion timestamp:** `2026-04-21T19:12:08Z`
- **Measured RTO:** `1h 17m`
- **Expected vs actual RPO:**
  - expected: `<=24h`
  - actual restore point age: `18h 02m`

Validation steps:

- service reachability: initial failure, then `HTTP 200` after second attempt
- logs consistency: app and nginx normal after retry restore; gap in first 3 minutes of log ingestion
- monitoring signals: heartbeat recovered; one false `vm-availability` alert auto-resolved

Issues encountered:

- restore attempt #1 targeted delegated subnet (`aci-delegated`) and NIC attach failed
- second attempt delayed by approval handoff (on-call to platform lead)

Mistakes / wrong assumptions:

- engineer assumed restore target subnet choice from previous template was still valid

Fixes applied:

- switched target to non-delegated `subnet-app-recovery`
- preflight check added: block delegated subnets for VM restore target

Lessons learned:

1. stale restore templates can break when subnet design evolves
2. access/approval handoff latency materially affects RTO

Operational improvement:

- added restore preflight script (`subnet delegation + NSG + free IP`) before restore job launch.

---

## Drill 3 - `RESTORE-2026-05-27-03`

- **Date/time:** `2026-05-27 09:00-10:06 UTC`
- **Trigger scenario:** simulated VM unresponsive after kernel panic and forced reboot loop
- **Restore method used:** Azure Backup restore-disks via CLI with isolated target resource group
- **Start timestamp:** `2026-05-27T09:00:12Z`
- **Restore completion timestamp:** `2026-05-27T09:54:42Z`
- **Measured RTO:** `57m 59s`
- **Expected vs actual RPO:**
  - expected: `<=24h`
  - actual restore point age: `9h 02m`

Validation steps:

- service reachability: SSH + local `/health` passed
- logs consistency: service logs normal; one delayed log batch arrived ~6 min later
- monitoring signals: CPU returned to staging baseline band; no sustained Sev1/Sev2 after watch period

Issues encountered:

- first validation curl timed out once due to NSG propagation lag
- short telemetry gap in Log Analytics caused delayed confidence in closure

Mistakes / wrong assumptions:

- assumed monitoring ingestion would be immediate after VM boot and agent start

Fixes applied:

- added 10-minute monitoring watch requirement before drill close
- explicit re-query step added for metrics/logs after initial validation

Lessons learned:

1. service-level validation can complete before telemetry pipeline fully catches up
2. one successful curl is not sufficient closure evidence

Operational improvement:

- closure criteria changed to require both app health and telemetry stability window.

---

## Trend Analysis

### RTO trend

| Drill ID | Date | Measured RTO | Notes |
| --- | --- | ---: | --- |
| `RESTORE-2026-03-08-01` | 2026-03-08 | 49m 11s | technically successful but DNS post-restore mismatch |
| `RESTORE-2026-04-21-02` | 2026-04-21 | 1h 17m | failed-first restore + approval delay |
| `RESTORE-2026-05-27-03` | 2026-05-27 | 57m 59s | smoother restore, still validation lag from telemetry |

Why RTO improved or worsened:

- Drill 2 worsened due to incorrect subnet target and handoff delay after first failure.
- Drill 3 improved vs Drill 2 because preflight checks reduced restore rework.
- RTO did not return to Drill 1 level because validation criteria became stricter (telemetry watch, not just service reachability).

Changes implemented between drills:

- DNS/network parity checks added after Drill 1
- restore preflight script and delegated-subnet guard added after Drill 2
- closure policy changed to include telemetry stability after Drill 3

What remains a risk:

- restore still depends on human approval in off-hours
- monitoring ingestion delay can obscure immediate post-restore confidence
- occasional NSG propagation lag affects first validation attempts

---

## Cross-Drill Improvements

- monitoring change: added explicit post-restore heartbeat/log query recheck window
- runbook update: network parity + delegated subnet preflight now mandatory
- access fix: added backup-operator fallback approver for restore drills
- automation idea: one-command restore preflight + validation bundle (`network`, `service`, `telemetry`) to reduce manual misses

---

## How to explain this in an interview

### 60-second explanation

"We tested VM recovery three times across two months, not once. One drill failed on the first attempt because we targeted a delegated subnet, and that increased RTO to 77 minutes. We fixed the process with preflight checks and updated runbooks. Later drills improved, but not perfectly, because we intentionally tightened validation to include telemetry stability, not only service reachability."

### 2-minute deep explanation

"The key point is we treated recovery as an operational process, not a backup checkbox. In Drill 1, restore worked but DNS/network parity was wrong, so we added network baseline checks. In Drill 2, the first restore attempt failed due to subnet delegation mismatch and approval latency; we documented that and added a restore preflight script plus role fallback. In Drill 3, restore execution was cleaner, but we still saw validation imperfections like one timed-out health check and delayed log ingestion. We changed closure criteria to require a watch window with stable monitoring signals.  

So the trend is not 'perfect improvement'; it's iterative risk reduction with realistic setbacks. We measured RTO and RPO each time and tied process changes directly to observed failure modes."

### Why this is credible vs theoretical backup setup

- includes failed-first recovery, not only successful drills
- RTO varies non-linearly and includes operational delays
- records wrong assumptions and concrete fixes
- uses measurable closure criteria beyond "restore job completed"
