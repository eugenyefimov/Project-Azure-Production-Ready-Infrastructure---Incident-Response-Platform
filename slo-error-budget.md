# SLO and Error Budget Policy

This document defines reliability objectives, error budget policy, and escalation behavior for the platform.

## 1) Service Scope

Primary service for SLO tracking:

- `customer-api` production endpoint
- environment: `prod`
- user-visible path: HTTPS request success and latency within agreed threshold

## 2) SLI, SLO, and SLA (Difference)

- **SLI (Service Level Indicator)**
  - Measured signal of service behavior (for example: successful request ratio, p95 latency, alert acknowledgment time).
  - This is raw telemetry.

- **SLO (Service Level Objective)**
  - Target value for an SLI over a time window (for example: 99.5% monthly availability).
  - This is the engineering reliability goal.

- **SLA (Service Level Agreement)**
  - Contractual/business commitment, usually with financial or legal consequences.
  - This is external/commercial accountability.

Practical rule:

- SLI = what we measure
- SLO = what we target
- SLA = what we promise contractually

## 3) SLI Definitions

## SLI-A: Availability

Definition:

- fraction of successful endpoint checks over total checks in `prod`
- source: Azure Monitor synthetic/service checks

Formula:

`Availability SLI = successful_checks / total_checks`

## SLI-B: Incident Acknowledgment

Definition:

- percentage of `Sev1/Sev2` alerts acknowledged within 5 minutes
- source: Azure Monitor alert fire time + incident channel acknowledgment timestamp

## SLI-C: Recovery Timeliness

Definition:

- percentage of customer-impacting incidents restored within 30 minutes
- source: incident records and postmortem timelines

## 4) SLO Targets

## Availability SLO (Primary)

- **Target:** `99.5%` monthly availability for `customer-api` in `prod`
- **Window:** calendar month
- **Measurement interval:** 1-minute checks

## Supporting Operations SLOs

- **Alert acknowledgment SLO:** `>= 85%` of `Sev1/Sev2` alerts acknowledged within 5 minutes
- **Recovery SLO:** `>= 80%` of customer-impacting incidents restored within 30 minutes

## 5) Acceptable Downtime and Error Budget

For monthly SLO `99.5%`, total allowed unavailability is:

- total minutes in 30-day month: `43,200`
- error budget: `0.5%` of `43,200` = **216 minutes/month**

Reference values:

- 31-day month -> **223.2 minutes**
- 28-day month -> **201.6 minutes**

## Monthly Budget Policy

- Budget tracked in minutes of user-impacting unavailability.
- Partial degradations count proportionally when user-impact is measurable (for example high 5xx with partial service).
- Planned maintenance counts against budget unless explicitly excluded by policy and communication process.

## 6) Burn Scenarios (Examples)

## Scenario A: Single Major Outage

- one 75-minute outage
- budget consumed: `75 / 216 = 34.7%`
- result: still within monthly budget, but elevated risk for rest of month

## Scenario B: Repeated Medium Incidents

- 4 incidents x 35 minutes each = 140 minutes
- budget consumed: `64.8%`
- result: little margin left for month-end change risk

## Scenario C: Early Burn (High Risk)

- 160 minutes consumed by day 10
- burn consumed: `74.1%` with two-thirds of month remaining
- result: trigger reliability freeze controls and stricter change policy

## 7) Alerts -> SLO Impact Mapping

- `Sev1 service availability alert`
  - immediate candidate for error budget consumption
  - requires impact confirmation and timeline tracking

- `Sev2 performance degradation alert`
  - may consume budget if user-impacting failure threshold is crossed
  - must correlate with error/timeout metrics

- `Sev3 warning / noisy infra alert`
  - does not directly consume budget
  - may indicate future burn risk if repetitive

Operational step:

1. Alert fires.
2. Incident owner classifies user impact.
3. If user-impact confirmed, start budget timer.
4. Stop timer when sustained recovery criteria are met.
5. Record consumed minutes in monthly budget ledger.

## 8) Incidents -> Error Budget Usage

Each customer-impacting incident must include:

- start time of user impact
- mitigation/recovery time
- total consumed budget minutes
- cumulative monthly burn percentage

Example entry:

- Incident: `INC-2026-04-30-001`
- Impact duration: 34 minutes
- Monthly budget consumed: `15.7%`
- Remaining budget: `84.3%`

## 9) Escalation Triggers

## Trigger Level 1 (Warning)

- **Condition:** 50% budget consumed before day 15
- **Action:**
  - increase change review strictness
  - require explicit risk notes in change tickets
  - prioritize top recurring incident class

## Trigger Level 2 (Critical)

- **Condition:** 75% budget consumed at any point
- **Action:**
  - temporary reliability freeze for non-essential prod changes
  - daily reliability standup until burn stabilizes
  - mandatory incident commander assignment for `Sev1/Sev2`

## Trigger Level 3 (Exceeded)

- **Condition:** >100% monthly budget consumed
- **Action:**
  - suspend high-risk infrastructure changes in prod (except break/fix)
  - executive stakeholder update with recovery plan
  - mandatory post-incident corrective action plan with deadlines
  - rebalance upcoming roadmap toward reliability work

## 10) Example Breach Scenario

Month: 30 days, budget 216 minutes.

Incidents:

- week 1: 52 min outage (network policy regression)
- week 2: 39 min degradation (dependency timeout storm)
- week 3: 68 min outage (DNS + routing change interaction)
- week 4: 73 min outage (combined deployment and NSG issue)

Total: `232 minutes` -> **107.4% budget consumed**

Outcome:

- SLO missed for month
- Trigger Level 3 actions executed
- non-critical production changes deferred
- platform team shifted sprint capacity to reliability fixes

## 11) Actions When Budget Is Exceeded

Immediate:

- enforce change freeze for non-break/fix production changes
- run incident trend review within 24 hours
- identify top 2 burn drivers by incident class

Short-term (7-14 days):

- implement targeted controls for top burn drivers
  - alert tuning
  - runbook updates
  - policy/guardrail hardening
- add explicit pre-change validation for high-risk paths

Medium-term (30-60 days):

- update SLO operating assumptions if service profile changed
- add automation for burn-rate alerts and weekly budget dashboards
- review on-call staffing and escalation latency

## 12) Governance and Reporting

Monthly reliability report should include:

- SLI trends and SLO attainment
- total budget consumed and remaining
- major incidents and burn contribution
- actions completed vs planned

Evidence references:

- `telemetry-trends.md`
- `operations-metrics.md`
- `incident-postmortem.md`
- `evidence/`
