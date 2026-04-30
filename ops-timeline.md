# 90-Day Operations Timeline (Weekly)

This timeline captures a realistic weekly operations view over ~13 weeks.

It intentionally includes:

- instability in early phase
- imperfect remediation
- repeated classes of failure before controls settle
- uneven progress during stabilization

## Phase 1: Early Instability (Weeks 1-4)

## Week 1 (2026-03-01 to 2026-03-07)

- **Timestamp:** 2026-03-01 19:04 UTC  
  **Event:** baseline production hardening apply (`CHG-4721`)  
  **Decision:** proceed with moderate-risk bundled infra updates  
  **Outcome:** apply succeeded; no immediate alerts

- **Timestamp:** 2026-03-06 11:03 UTC  
  **Event:** `Sev1` availability incident after NSG rule update (`INC-2026-03-06-001`)  
  **Decision:** escalate quickly and rollback via CI/CD path (no portal hotfix)  
  **Outcome:** service restored in same hour; trust impact noted

- **Lesson:** network changes need explicit effective-rule validation, not just static review.

## Week 2 (2026-03-08 to 2026-03-14)

- **Timestamp:** 2026-03-09 02:17 UTC  
  **Event:** VM availability alert fired during planned maintenance (false positive)  
  **Decision:** keep alert active but add maintenance tagging/muting improvement task  
  **Outcome:** no customer impact, but on-call noise increased

- **Timestamp:** 2026-03-12 15:21 UTC  
  **Event:** suspicious failed-login burst (`SEC-2026-03-12-001`)  
  **Decision:** block hostile source range + tune auth query thresholds  
  **Outcome:** contained quickly; one internal service account also flagged (noise)

- **Lesson:** early security detection worked, but signal quality still noisy.

## Week 3 (2026-03-15 to 2026-03-21)

- **Timestamp:** 2026-03-15 22:12 UTC  
  **Event:** prod apply failed due to transient control-plane/provider timeout (`CHG-4741`)  
  **Decision:** retry after short pause instead of parallel rerun  
  **Outcome:** second run succeeded; no service impact

- **Timestamp:** 2026-03-21 09:11 UTC  
  **Event:** endpoint availability alert fired twice from one probe region (false positive cluster)  
  **Decision:** adjust probe region weighting and suppress duplicate incident creation  
  **Outcome:** reduced duplicate paging in following weeks

- **Lesson:** tool instability + monitoring noise can combine into operator fatigue fast.

## Week 4 (2026-03-22 to 2026-03-28)

- **Timestamp:** 2026-03-27 18:31 UTC  
  **Event:** high CPU incident from workload/query regression (`INC-2026-03-27-004`)  
  **Decision:** scale VM one tier immediately, then fix query plan  
  **Outcome:** rapid mitigation; root fix completed next day

- **Lesson:** temporary capacity scaling is useful, but must be followed by root-cause optimization.

---

## Phase 2: Stabilization (Weeks 5-9)

## Week 5 (2026-03-29 to 2026-04-04)

- **Timestamp:** 2026-04-02 06:49 UTC  
  **Event:** policy assignment apply failed due to stale lock (`CHG-4768`)  
  **Decision:** clear lock safely and re-run with same plan  
  **Outcome:** retry succeeded; minor release delay

- **Timestamp:** 2026-04-02 07:04 UTC  
  **Event:** auth anomaly alert with real hostile source  
  **Decision:** enforce faster security triage path and incident template update  
  **Outcome:** containment in minutes; improved handoff quality

- **Lesson:** pipeline reliability is part of operations reliability, not a separate concern.

## Week 6 (2026-04-05 to 2026-04-11)

- **Timestamp:** 2026-04-05 00:48 UTC  
  **Event:** heartbeat gap triggered false availability signal  
  **Decision:** keep strict alerting but add correlation rule with service probe before escalation  
  **Outcome:** fewer unnecessary `Sev1` escalations after change

- **Timestamp:** 2026-04-09 13:22 UTC  
  **Event:** certificate chain mismatch caused service degradation (`INC-2026-04-09-005`)  
  **Decision:** rollback cert package, then re-apply with validated chain  
  **Outcome:** recovery <20 minutes; added cert pre-check into change flow

- **Lesson:** reliability incidents often come from dependency/config drift, not compute failure.

## Week 7 (2026-04-12 to 2026-04-18)

- **Timestamp:** 2026-04-14 04:55 UTC  
  **Event:** CPU spike due to ETL overlap with backup window  
  **Decision:** shift backup schedule and ETL offsets  
  **Outcome:** no repeat saturation in next two cycles

- **Lesson:** scheduling conflicts are quiet reliability killers in small platforms.

## Week 8 (2026-04-19 to 2026-04-25)

- **Timestamp:** 2026-04-19 10:09 UTC  
  **Event:** availability incident tied to DNS timeout cascade (`INC-2026-04-19-007`)  
  **Decision:** treat DNS as first-class dependency in runbooks and workbook panels  
  **Outcome:** improved triage speed for dependency-path faults

- **Timestamp:** 2026-04-24 16:43 UTC  
  **Event:** auth burst alert from approved penetration test (false positive)  
  **Decision:** tune alert threshold and introduce pen-test tagging requirement  
  **Outcome:** lower security alert noise without disabling detection

- **Lesson:** process gaps (like untagged tests) create avoidable noise.

## Week 9 (2026-04-26 to 2026-05-02)

- **Timestamp:** 2026-04-29 14:08 UTC  
  **Event:** CPU anomaly alert (deviation >2x baseline)  
  **Decision:** use anomaly query as `Sev2` investigation trigger instead of immediate incident escalation  
  **Outcome:** contained without outage; confirms better signal tuning

- **Timestamp:** 2026-04-30 00:18 UTC  
  **Event:** repeat NSG-related availability regression (`INC-2026-04-30-001`)  
  **Decision:** enforce stronger NSG policy controls + pre-apply connectivity checks  
  **Outcome:** recovery achieved; incident used as forcing function for governance hardening

- **Lesson:** repeated incident class means controls are still weak, even if MTTR improves.

---

## Phase 3: Optimization (Weeks 10-13)

## Week 10 (2026-05-03 to 2026-05-09)

- **Timestamp:** 2026-05-04 11:00 UTC  
  **Event:** governance policy assignments tightened across staging/prod  
  **Decision:** accept short-term friction for long-term safety  
  **Outcome:** one change blocked by policy, fixed pre-impact

- **Lesson:** guardrail friction is acceptable when it prevents production regressions.

## Week 11 (2026-05-10 to 2026-05-16)

- **Timestamp:** 2026-05-12 14:30 UTC  
  **Event:** no customer-impacting incidents; high alert volume still observed on two low-value rules  
  **Decision:** downgrade low-signal alerts and assign explicit owners per rule  
  **Outcome:** alert fatigue reduced in next cycle

- **Lesson:** stability period should be used to reduce toil, not just celebrate no incidents.

## Week 12 (2026-05-17 to 2026-05-23)

- **Timestamp:** 2026-05-19 09:45 UTC  
  **Event:** scheduled restore drill (`backup verification`)  
  **Decision:** run full restore path despite no active incident  
  **Outcome:** restore met target window; one runbook ambiguity fixed

- **Lesson:** recovery confidence decays quickly without regular drills.

## Week 13 (2026-05-24 to 2026-05-30)

- **Timestamp:** 2026-05-27 16:20 UTC  
  **Event:** monthly reliability review  
  **Decision:** prioritize automation backlog (error budget reporting + evidence export pipeline) over adding new platform features  
  **Outcome:** roadmap shifted toward repeatability and operational quality

- **Lesson:** at this maturity stage, consistency improvements create more value than new components.

---

## Trend Summary Across 90 Days

- **Incident frequency:** down overall, but not linearly (several clustered weeks remained).
- **MTTR:** improved materially, especially for known fault patterns.
- **Alert quality:** improved after repeated tuning; false positives still present but less disruptive.
- **Change safety:** stronger than initial phase, but network and dependency changes remain highest risk.

## What Actually Improved

- escalation decisions happened earlier
- fault-domain isolation became faster
- rollback discipline improved
- governance controls moved from documented to enforced

## What Still Needs Work

- more automation for KPI/error-budget reporting
- better pre-change validation for dependency and network paths
- stronger control over noisy but recurring non-actionable alerts
