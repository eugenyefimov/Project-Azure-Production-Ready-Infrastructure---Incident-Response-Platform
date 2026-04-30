# Telemetry Trends (Long-Term Operations View)

This document tracks operational telemetry over time to show whether reliability work is actually improving outcomes.

Values below are realistic simulated ranges based on platform behavior patterns and incident records. They are intentionally non-linear and include noisy periods.

---

## 1) Measurement Scope

- **Time horizon:** 6 months
- **Cadence:** weekly operational review + monthly trend baseline
- **Sources:**
  - Azure Monitor alert history
  - incident records and postmortems
  - on-call acknowledgment logs
  - Log Analytics query outputs

Tracked KPIs:

- incident frequency (week/month)
- MTTR trend
- alert noise ratio (non-actionable alerts / total alerts)

---

## 2) Initial State vs Improved State

## Initial State (Month 1-2)

Typical characteristics:

- alerting mostly host-threshold driven
- weaker ownership routing in first minutes
- limited tuning of repetitive low-value alerts

Observed pattern:

- incident frequency: **2-4 incidents/week** (monthly: **10-15**)
- MTTR range: **35-60 minutes**
- alert noise ratio: **38-52%**

## Improved State (Month 4-6)

Changes in place:

- service-level and anomaly-based alerting
- cleaner escalation ownership
- alert threshold/query tuning after postmortems

Observed pattern:

- incident frequency: **1-3 incidents/week** (monthly: **5-10**)
- MTTR range: **14-32 minutes**
- alert noise ratio: **16-29%**

Notes on variability:

- month-end patch cycles temporarily increase alert volume
- network/security policy rollouts can create short-lived incident clusters
- off-hours staffing patterns still affect tail latency in MTTR

---

## 3) Example Time-Series (Realistic Simulation)

## A) Incident Frequency Trend

### Weekly incident count (last 12 weeks)

`[4, 3, 4, 2, 3, 3, 2, 2, 1, 3, 2, 1]`

Interpretation:

- overall downward direction with occasional spikes
- week 10 spike corresponds to governance policy tightening + change volume increase

### Monthly incident count (last 6 months)

`[14, 12, 10, 9, 7, 6]`

Interpretation:

- steady reduction, but not an unrealistic straight line
- decline likely driven by both better controls and fewer repeat failure classes

## B) MTTR Trend (minutes)

### Monthly MTTR (p50 / p90)

- Month 1: `p50=44`, `p90=71`
- Month 2: `p50=39`, `p90=66`
- Month 3: `p50=31`, `p90=54`
- Month 4: `p50=27`, `p90=47`
- Month 5: `p50=23`, `p90=41`
- Month 6: `p50=20`, `p90=36`

Interpretation:

- both median and tail improved, tail remains materially higher (expected)
- indicates better runbook execution, but complex incidents still take longer

## C) Alert Noise Reduction Trend

Definition:

- **Noise ratio** = alerts closed as non-actionable or duplicate / total fired alerts

### Monthly noise ratio

`[49%, 44%, 37%, 31%, 24%, 19%]`

Interpretation:

- meaningful reduction after alert tuning and severity remapping
- still non-zero by design; some signal overlap is acceptable to protect detection sensitivity

---

## 4) What Graphs To Capture In Azure

For evidence, capture these views in Azure Monitor Workbook and Alerts history.

## Graph 1: Weekly Incident Count (Line Chart)

What to show:

- x-axis: week number (last 12 weeks)
- y-axis: incident count
- split by incident class (availability, network, performance, security)

Screenshot target:

- workbook tab with filter `environment=prod`
- visible date range + incident class legend

## Graph 2: MTTR Trend (Dual Line p50/p90)

What to show:

- monthly p50 MTTR
- monthly p90 MTTR
- annotation markers for major control changes (for example: "service-level alert rollout")

Screenshot target:

- chart + annotation labels visible
- companion table beneath chart with raw values

## Graph 3: Alert Noise Ratio (Stacked Bar)

What to show:

- actionable alerts vs non-actionable alerts per month
- total monthly alert volume

Screenshot target:

- stacked bars with percentages
- footnote showing noise ratio formula

## Graph 4: Alert Response SLA Compliance

What to show:

- percentage of `Sev1/Sev2` alerts acknowledged within 5 minutes
- trend over 6 months

Screenshot target:

- SLA line target (for example 85%)
- actual monthly values

---

## 5) Trend Interpretation and Operational Decisions

## Decision 1: Add service-level detection

Signal:

- incidents were discovered too late when VM health stayed green

Action:

- added endpoint/service availability alerts

Outcome:

- MTTD improved and reduced "late discovery" incidents

## Decision 2: Tune noisy alerts

Signal:

- high non-actionable alert ratio in first two months

Action:

- adjusted thresholds, grouped duplicate alerts, remapped severities

Outcome:

- alert fatigue reduced; faster acknowledgment on high-severity signals

## Decision 3: Improve runbook flow for network faults

Signal:

- MTTR tail remained high for network incidents

Action:

- updated triage path to evaluate effective NSG/route earlier

Outcome:

- fewer wrong turns and lower MTTR for repeat network-path issues

## Decision 4: Keep conservative change controls in prod

Signal:

- weekly spikes correlated with risky change windows

Action:

- retained manual prod apply, approval gates, and rollback playbook requirement

Outcome:

- fewer high-impact change failures and clearer recovery execution

---

## 6) Data Limitations and Confidence

- Platform size is small; incident count can be volatile month-to-month.
- Mixed dataset (live incidents + controlled drills) improves coverage but affects comparability.
- Incident classification quality improved over time, so older data may under-report certain categories.
- Acknowledgment timestamps from chat systems are operationally useful but not perfectly synchronized.

Confidence level:

- **directional trend confidence:** high
- **exact point estimate confidence:** medium

---

## 7) Why Time-Based Evidence Matters In Real SRE/Cloud Roles

Point-in-time screenshots can hide instability.  
Time-based telemetry shows whether operations are truly improving or just reacting well to one incident.

In real teams, long-horizon trend evidence is used to:

- justify engineering investment (alert tuning, automation, governance controls)
- prove reliability improvements to management and auditors
- detect regressions early after process or architecture changes
- separate random good/bad weeks from structural reliability change

Operational credibility comes from repeatable trend improvement, not single-event heroics.

---

## 8) What To Improve Next

1. Automate KPI extraction into a single monthly reliability report.
2. Add per-incident-class MTTR targets (network vs app vs security).
3. Introduce error-budget style tracking for customer-facing services.
4. Add confidence intervals for key metrics as dataset grows.
5. Track "change-induced incidents" as a separate KPI tied to release controls.
