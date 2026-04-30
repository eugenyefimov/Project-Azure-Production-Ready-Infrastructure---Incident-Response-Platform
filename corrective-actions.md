# Corrective Actions Register

This register tracks post-incident corrective actions to ensure issues are permanently reduced, not just temporarily mitigated.

Status values:

- `open`
- `in_progress`
- `done`

## Incident: INC-2026-03-06-001 (NSG Priority Regression)

Incident summary:

- customer-facing availability outage caused by NSG rule precedence conflict

Actions:

- **CA-001**
  - Follow-up: Add pre-apply connectivity validation for critical ports (`443`) in prod
  - Owner: Platform Engineering
  - Status: `done`
  - Completion date: `2026-03-18`
  - Linked change type: `config_update`
  - Implemented: Added pre-apply network path check in change workflow runbook and apply gate checklist
  - Recurrence reduction: Reduced chance of promoting broken ingress rule order

- **CA-002**
  - Follow-up: Enforce public IP and VM-size governance policy assignments in prod scope
  - Owner: Security Engineering
  - Status: `done`
  - Completion date: `2026-04-02`
  - Linked change type: `policy_change`
  - Implemented: Applied Terraform policy assignments (`pa-deny-public-ip`, `pa-allowed-vm-sizes`)
  - Recurrence reduction: Reduced unsafe network exposure and unapproved compute drift

- **CA-003**
  - Follow-up: Add NSG change review template requiring before/after effective rule proof
  - Owner: Change Management
  - Status: `done`
  - Completion date: `2026-03-22`
  - Linked change type: `config_update`
  - Implemented: Introduced required evidence section in network change process
  - Recurrence reduction: Reduced review misses on rule priority interactions

- **CA-004**
  - Follow-up: Add Activity Log alert for high-risk NSG writes
  - Owner: Monitoring/SRE
  - Status: `in_progress`
  - Completion date: `2026-05-08 (target)`
  - Linked change type: `monitoring_change`
  - Implemented: Draft scheduled query rule for NSG change risk tagging and severity routing
  - Recurrence reduction: Improves early detection of risky control-plane changes

## Incident: INC-2026-04-09-005 (Certificate Chain Mismatch)

Incident summary:

- service degradation after edge certificate update with incomplete chain validation

Actions:

- **CA-005**
  - Follow-up: Add certificate chain validation step before prod apply
  - Owner: Platform Engineering
  - Status: `done`
  - Completion date: `2026-04-13`
  - Linked change type: `config_update`
  - Implemented: Added pre-change cert validation checklist item and verification command set
  - Recurrence reduction: Reduced failed edge cert rollouts from manual mistakes

- **CA-006**
  - Follow-up: Add service-level alert annotation for cert-related dependency failures
  - Owner: Monitoring/SRE
  - Status: `done`
  - Completion date: `2026-04-16`
  - Linked change type: `monitoring_change`
  - Implemented: Updated alert metadata to include dependency context and runbook link
  - Recurrence reduction: Faster fault-domain isolation for TLS-related incidents

- **CA-007**
  - Follow-up: Add rollback-ready previous certificate reference in change ticket template
  - Owner: Change Management
  - Status: `done`
  - Completion date: `2026-04-14`
  - Linked change type: `config_update`
  - Implemented: Required rollback artifact section for cert updates
  - Recurrence reduction: Shortened rollback time during cert incidents

## Incident: INC-2026-04-19-007 (DNS Timeout Cascade)

Incident summary:

- endpoint availability degraded due to upstream DNS resolution instability

Actions:

- **CA-008**
  - Follow-up: Add DNS dependency panel and query links in operations workbook
  - Owner: Monitoring/SRE
  - Status: `done`
  - Completion date: `2026-04-23`
  - Linked change type: `monitoring_change`
  - Implemented: Added dependency-focused dashboard panel and drill-through queries
  - Recurrence reduction: Reduced triage time for dependency-path failures

- **CA-009**
  - Follow-up: Add synthetic DNS checks for critical internal FQDNs
  - Owner: Platform Engineering
  - Status: `in_progress`
  - Completion date: `2026-05-12 (target)`
  - Linked change type: `monitoring_change`
  - Implemented: Defined check set and target list; rollout in staging ongoing
  - Recurrence reduction: Expected earlier detection of DNS regressions before full impact

- **CA-010**
  - Follow-up: Harden DNS change process with explicit validation checklist
  - Owner: Platform + Operations
  - Status: `done`
  - Completion date: `2026-04-25`
  - Linked change type: `config_update`
  - Implemented: Added DNS validation section to change lifecycle template
  - Recurrence reduction: Lowered config drift risk in name-resolution path

## Incident: INC-2026-04-30-001 (NSG Regression Repeat)

Incident summary:

- repeat network availability incident confirming earlier controls were not fully closed

Actions:

- **CA-011**
  - Follow-up: Move NSG policy controls from documented to enforced Terraform module
  - Owner: Security Engineering
  - Status: `done`
  - Completion date: `2026-04-30`
  - Linked change type: `policy_change`
  - Implemented: Implemented `modules/governance` and wired policy assignments into platform module
  - Recurrence reduction: Converted guardrails from advisory to enforced deny controls

- **CA-012**
  - Follow-up: Add incident escalation trigger tied to early error-budget burn
  - Owner: Incident Management
  - Status: `done`
  - Completion date: `2026-05-01`
  - Linked change type: `monitoring_change`
  - Implemented: Added escalation thresholds in SLO/error budget policy
  - Recurrence reduction: Reduced delayed escalation risk during clustered incidents

- **CA-013**
  - Follow-up: Implement monthly corrective-action closure review
  - Owner: Platform Lead
  - Status: `in_progress`
  - Completion date: `2026-05-31 (target)`
  - Linked change type: `config_update`
  - Implemented: Defined review cadence and ownership checklist; first review pending
  - Recurrence reduction: Improves accountability and closure quality over time

## Cross-Incident Summary

## What Was Implemented

- governance controls are now enforced as policy-as-code at environment scope
- monitoring includes stronger service/dependency context and lower duplicate noise
- change controls include stricter validation and rollback evidence requirements
- error-budget thresholds now influence escalation behavior

## What Reduced Recurrence Most

Highest impact controls so far:

1. policy assignments enforced in Terraform (`deny` behavior active)
2. pre-apply validation for high-risk network and certificate changes
3. improved alert context and ownership routing for faster triage

## Remaining Risk (Open/In Progress Actions)

- NSG high-risk change alerting still being completed (`CA-004`)
- DNS synthetic checks rollout not fully complete (`CA-009`)
- monthly closure governance process not yet fully institutionalized (`CA-013`)

## Operational Rule

An incident is not considered fully closed until:

- mitigation is complete
- corrective actions have owners and due dates
- at least one recurrence-reduction control is implemented and verified
