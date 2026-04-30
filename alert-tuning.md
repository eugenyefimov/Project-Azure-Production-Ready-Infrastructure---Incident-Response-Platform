# Alert Tuning History

This document records how alert quality evolved from noisy early settings to more actionable operations.

## 1) Initial State (Noisy Baseline)

Window: `2026-02-15` to `2026-03-20`

Observed issues:

- duplicate firings during single incidents (`Sev1` endpoint and auth burst alerts)
- alerts triggered on short-lived telemetry gaps with no customer impact
- weak ownership metadata in payloads slowed acknowledgment routing
- broad query windows generated low-value security bursts during tests

Baseline metrics:

- total alerts: `54`
- false positives: `17` (`31.5%`)
- duplicate alerts: `11` (`20.4%`)
- median MTTA: `4m 42s`
- missed detections (known): `0 Sev1`, `2 Sev2` (late detection on partial-path failures)

---

## 2) Tuning Changes Over Time

## Change Set A (`CHG-4748`, `2026-03-21`)

Focus: reduce endpoint probe noise.

Threshold changes:

- service availability alert condition from `3m` to `5m` sustained failure window
- added region correlation requirement (`>=2 failed checks`) before `Sev1` fire

Suppression rules:

- suppress duplicate event payloads for same rule/resource within `10m` incident window

Tagging improvements:

- required payload fields:
  - `environment`
  - `service`
  - `oncallRotation`
  - `runbook`

Immediate effect:

- duplicate `Sev1` incidents reduced, but one regional false alert class still present.

## Change Set B (`CHG-4804`, `2026-04-24`)

Focus: auth burst and diagnostic ingest noise.

Threshold changes:

- auth failed-login burst threshold increased from `>=12` to `>=18` in `5m`
- query timeout retry handling improved to avoid duplicate burst notifications

Suppression rules:

- maintenance/test suppression when `change_ticket` or `security_test=true` tag exists
- one-time retry failure in `ScheduledQueryRuleEvaluation` downgraded to informational path

Tagging improvements:

- added `change_ticket` and `security_test` tagging convention in alert enrichment

Immediate effect:

- reduced false positives from approved penetration tests and transient query timeouts.

## Change Set C (`CHG-4831`, `2026-05-05`)

Focus: partial failure detection without reintroducing noise.

Threshold changes:

- introduced network-path failure alert on deny hits for trusted CIDR with `2 consecutive bins`
- kept CPU anomaly threshold dynamic (`>2x baseline`) but required persistence across `10m`

Suppression rules:

- CPU and network alerts correlated to one incident ID when overlap occurs inside `15m`

Tagging improvements:

- `incidentHint` and `faultDomain` fields added (`network`, `compute`, `app`, `dependency`)

Immediate effect:

- earlier pivot from wrong CPU-only hypothesis during multi-factor incident class.

---

## 3) Improved State (After Tuning)

Window: `2026-04-25` to `2026-05-30`

Metrics:

- total alerts: `49`
- false positives: `8` (`16.3%`)
- duplicate alerts: `4` (`8.2%`)
- median MTTA: `2m 11s`
- missed detections (known): `1 Sev2` (partial regional packet loss detected late by 6 minutes), `0 Sev1`

Before/after summary:

- false positive rate: `31.5% -> 16.3%` (improved by `15.2` percentage points)
- duplicate alert ratio: `20.4% -> 8.2%`
- median MTTA: `4m 42s -> 2m 11s` (improved by `2m 31s`)
- missed detections: down for severe events, one remaining `Sev2` gap in partial-failure class

---

## 4) Missed Detection Record

Incident: `INC-2026-05-05-003`

- symptom began: `07:02 UTC`
- network-path alert fired: `07:08 UTC`
- detection gap: `6 minutes`

Why missed earlier:

- deny-hit threshold required two bins and aggregation lag delayed first actionable signal

Follow-up:

- added pre-alert weak-signal panel in workbook for trusted CIDR deny trend
- retained current firing threshold to avoid returning to high false-positive noise

---

## 5) Noise vs Early Detection Balance

Operating position:

- noise reduction is useful only if early incident visibility is preserved
- first weak signal may be noisy, but repeated noisy patterns still carry value

How balance is managed:

1. keep strict `Sev1` criteria for paging, but expose weak-signal trend panels for operators
2. suppress exact duplicates, not symptom classes
3. tune with measured outcomes (false positives, MTTA, missed detections), not intuition
4. do not close tuning work until one incident cycle confirms behavior

Practical rule:

- if a tuning change lowers false positives but increases missed impactful detections, revert and retune with narrower suppression scope.
