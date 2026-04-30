# Next Improvements (Practical Backlog)

This is the realistic follow-up backlog for the current platform baseline.

The platform is usable and structured, but it is not "finished."  
The focus here is what is still weak, what will fail under scale pressure, and what needs automation before calling this production-hardened.

## Priority 0 (Do Next) - Evidence and Reliability Discipline

## 1) Replace simulated evidence with live operational evidence

What is missing:

- recurring real Azure screenshots/exports (alerts, workbook trends, policy compliance)
- monthly reliability report based on live data, not only modeled data

Why this matters:

- current documentation quality is high, but proof quality is still mixed
- without live evidence, confidence in operational claims stays limited

## 2) Automate error budget and SLO reporting

What is missing:

- automated SLI extraction pipeline
- monthly budget ledger generated from source data

What should be automated:

- pull alert/incident timestamps into one dataset
- compute MTTD/MTTA/MTTR and budget burn weekly
- publish reliability summary dashboard automatically

Risk if ignored:

- manual reporting drift and inconsistent decision-making

## 3) Add enforced policy compliance reporting

What is missing:

- routine policy compliance trend reporting per environment
- clear exemption lifecycle artifact (owner, expiry, approval)

What should be automated:

- monthly policy compliance export
- alert on expired exemptions

---

## Priority 1 (Near-Term) - Scale and Change Safety

## 4) Strengthen change validation for network and security controls

What would break at scale:

- more frequent network changes increase chance of rule conflicts and hidden precedence issues
- human review alone will miss edge-case interaction over time

What should be automated:

- pre-apply connectivity checks for critical service paths
- policy tests for risky NSG/route patterns
- post-apply smoke checks with rollback trigger conditions

## 5) Improve alert quality management loop

What is missing:

- closed-loop process to tune noisy alerts every sprint/month
- formal ownership for each high-severity alert rule

What would break at scale:

- alert fatigue and delayed acknowledgments as service count grows

What should be automated:

- duplicate alert suppression logic
- stale alert rule review reminders
- per-rule noise scoring

## 6) Tighten incident classification and taxonomy

What is missing:

- consistent incident labels by fault domain and root cause class
- standardized incident closure template

Risk if ignored:

- trend analysis becomes unreliable
- recurring issues look like unrelated events

---

## Priority 2 (Medium-Term) - Platform Maturity

## 7) Introduce service-level dependency mapping

What is missing:

- explicit map of service dependencies (DNS, auth, upstream APIs, network boundaries)

What would break at scale:

- longer MTTR during cross-system incidents
- poor impact prediction for change windows

## 8) Expand resilience patterns beyond single-region baseline

What is missing:

- tested regional failover strategy
- documented workload tiering by criticality (RTO/RPO classes)

What would break at scale:

- prolonged outage risk from regional/provider issues

## 9) Move from point controls to lifecycle controls

What is missing:

- periodic access review workflows
- lifecycle management for runbooks and policy exceptions
- explicit operational ownership rotation

Why this matters:

- controls degrade over time without lifecycle governance

---

## Priority 3 (When Capacity Allows) - Strategic Improvements

## 10) Revisit runtime platform choice as workload complexity grows

Current state:

- ACI is appropriate for low-complexity stateless workload

Future trigger:

- if service count, deployment frequency, and traffic variability increase, evaluate AKS with clear migration criteria

## 11) Add deeper supply-chain and IaC security controls

Potential additions:

- image provenance checks
- Terraform policy tests in CI as hard gate
- artifact signing/attestation for high-assurance environments

---

## What Will Break First At Scale (Blunt View)

If demand or change volume doubles, first pain points will likely be:

1. alert noise and acknowledgment latency
2. manual evidence/reporting overhead
3. network change risk from rule interaction complexity
4. inconsistent incident categorization reducing learning quality

This is normal for a platform at this maturity stage.  
The fix is not "more tooling first," but tighter operating loops + targeted automation.

---

## Execution Principle

Prioritize improvements that reduce repeated operational pain:

- automate what is repetitive and error-prone
- standardize what affects cross-team decisions
- defer "nice architecture upgrades" until reliability basics are consistently measured and controlled
