# Cost vs Reliability Decision Log

This log records practical trade-offs made for this platform.  
The goal is not perfect architecture; the goal is controlled reliability within budget.

## Decision 1 - Not Implemented Due to Cost

### Decision (Trade-off 1)

Did **not** implement active-active multi-region production deployment (paired region with hot traffic split).

### Alternative options considered (Trade-off 1)

1. Active-passive DR with warm standby in paired region
2. Active-active with global load balancing and replicated app path
3. Current model: single-region production with tested backup/restore and documented recovery runbooks

### Estimated cost impact (Trade-off 1)

- active-active estimate: +`EUR 1,200-1,900/month` (duplicate compute, monitoring, egress, operations overhead)
- active-passive estimate: +`EUR 500-900/month`
- chosen model: baseline cost, no regional duplication spend

### Reliability impact (Trade-off 1)

- downside accepted:
  - higher risk during full regional outage
  - higher potential RTO for region-wide failure than active-active
- controls kept:
  - tested restore drill
  - backup policy and recovery runbooks
  - incident response and rollback discipline

### Final reasoning (Trade-off 1)

For the current workload scale, active-active cost was not justified by business impact profile.  
We prioritized strong recovery operations over permanent dual-region spend.

---

## Decision 2 - Simplified Design (Risk Accepted)

### Decision (Trade-off 2)

Kept backup frequency at **daily VM backup** instead of 4-hour snapshots + daily backup combination.

### Alternative options considered (Trade-off 2)

1. Daily backup only (current)
2. Daily backup + 4-hour incremental disk snapshots
3. Daily backup + app-level continuous replication

### Estimated cost impact (Trade-off 2)

- option 2 would add approx `EUR 120-260/month` storage + snapshot management overhead
- option 3 would add higher tooling and engineering cost (`EUR 300+/month` equivalent including ops time)
- chosen option keeps storage and operational complexity lower

### Reliability impact (Trade-off 2)

- downside accepted:
  - worse potential data-loss window than snapshot-heavy setup
  - less granular restore points for intra-day incidents
- benefit retained:
  - simpler restore process
  - lower failure modes in backup operations
  - clear and testable RPO expectation

### Final reasoning (Trade-off 2)

We accepted coarser RPO to reduce ongoing cost and operational complexity.  
Given incident profile, daily recovery points were considered adequate, with regular restore drills to prove recoverability.

---

## Decision 3 - Kept Strict (Paid the Cost)

### Decision (Trade-off 3)

Kept **manual approval gates + protected production apply** in CI/CD (no automatic prod apply).

### Alternative options considered (Trade-off 3)

1. Auto-apply to prod on merge (fastest, highest risk)
2. Time-windowed auto-apply with limited checks
3. Manual apply with environment approvals, plan gate, and explicit confirmation (current)

### Estimated cost impact (Trade-off 3)

- direct productivity cost: approx `2-5 engineer-hours/week` in approvals, coordination, and waiting time
- slower lead time for urgent but non-incident changes
- occasional change-window friction across teams

### Reliability impact (Trade-off 3)

- strong positive impact:
  - lower chance of unsafe prod drift
  - better prevention of change-induced outages
  - better auditability and rollback readiness
- known trade-off:
  - delivery speed reduced in exchange for safer production behavior

### Final reasoning (Trade-off 3)

This platform is more likely to fail from bad change control than from slightly slower delivery.  
We intentionally pay process overhead to reduce high-severity production incidents.

---

## Operating Principle

When forced to choose, we optimize for:

1. predictable recovery
2. controlled production change
3. cost efficiency for current scale

Re-evaluation trigger:

- if incident frequency, customer impact, or business criticality increases, revisit these decisions and move reliability controls up even with higher cost.
