# Policy Compliance Evidence (Simulated Screenshot Notes + Sample Output)

Status: Simulated/Sanitized Sample  
Scope: Portfolio repository. No live tenant data or customer data is included.

This document describes what policy compliance screenshots should contain and includes realistic sample output values over time.

What this artifact proves:

- policy controls are enforced and measurable by scope over time
- non-compliance is tracked, remediated, and not hidden
- exceptions are governed with owner and expiry instead of permanent bypass

How generated (real-world equivalent):

- export Azure Policy compliance data weekly from portal or API
- capture assignment-level non-compliance details and remediation notes
- preserve temporary regressions after new resource onboarding

How to present in interview:

- show one month where compliance improved and one where it dipped
- explain why the dip happened and what corrective action was taken
- highlight one denied change that prevented unsafe production drift

## Screenshot Set 1 - Compliance Overview (Portal)

Where:

- Azure Portal -> Policy -> Compliance

What to capture:

- selected scope (prod resource group)
- compliance percentage
- non-compliant resource count
- top failing policy assignments
- last evaluation timestamp

What it proves:

- policies are assigned and actively evaluated
- compliance posture is measurable over time

How generated:

- portal compliance dashboard export or screenshot at weekly cadence

Interview presentation:

- show month-over-month compliance movement and explain one remediation cycle

## Screenshot Set 2 - Non-Compliant Resources

Where:

- Policy assignment -> Compliance details -> Non-compliant resources

What to capture:

- resource ID/name
- policy assignment name
- compliance state
- timestamp of last evaluation

What it proves:

- control failures are visible at resource granularity
- violations are operationally actionable, not theoretical

How generated:

- assignment-specific compliance view, filtered by environment

Interview presentation:

- walk one violation from detection to fix and re-evaluation

## Screenshot Set 3 - Exemptions and Exceptions

Where:

- Policy -> Exemptions (if used)

What to capture:

- exemption reason
- owner
- expiry date
- approved scope

What it proves:

- exception handling is governed and time-bounded

How generated:

- policy exemption list export

Interview presentation:

- show how exceptions are controlled, not used as permanent bypass

---

## Sample Compliance Output (Monthly Snapshot)

```text
Month,Scope,OverallCompliance,NonCompliantResources,TopPolicyFailure,Notes
Mar,rg: az-ir-platform-p-westeurope-rg-network,82.4%,11,pa-require-tags,legacy resources missing business_unit tag
Apr,rg: az-ir-platform-p-westeurope-rg-network,90.7%,6,pa-allowed-vm-sizes,one blocked VM resize request
May,rg: az-ir-platform-p-westeurope-rg-network,94.1%,4,pa-deny-public-ip,attempted temporary public IP for testing
Jun,rg: az-ir-platform-p-westeurope-rg-network,92.8%,5,pa-require-tags,new container resources missing owner tag
Jul,rg: az-ir-platform-p-westeurope-rg-network,95.4%,3,pa-deny-public-ip,one temporary exception expired and was removed
```

Imperfections included:

- compliance can drop after new control rollout
- temporary regressions happen when new resources are introduced
- not all failures are critical incidents

---

## Example Violation Export (Sanitized)

```text
PolicyAssignmentName: pa-allowed-vm-sizes
PolicyDefinitionName: pd-allowed-vm-sizes-platform
ResourceId: /subscriptions/***/resourceGroups/az-ir-platform-p-westeurope-rg-network/providers/Microsoft.Compute/virtualMachines/az-ir-platform-p-westeurope-vm-app-01
ComplianceState: NonCompliant
Timestamp: 2026-04-02T06:49:28Z
Details: Requested size Standard_E8s_v5 is not in allowedVmSizes parameter list.
Remediation: Change rejected; request updated to Standard_D4s_v5 and reapplied.
```

## Example Exception Record (Sanitized)

```text
ExemptionName: exm-breakglass-aci-diagnostics
Scope: /subscriptions/***/resourceGroups/az-ir-platform-p-westeurope-rg-network
PolicyAssignment: pa-require-tags
Category: Waiver
Owner: secops-contact@example.com
CreatedOn: 2026-05-06T09:12:20Z
ExpiresOn: 2026-05-13T09:12:20Z
Reason: emergency diagnostics container launched without full metadata tags during incident bridge
StatusAfterExpiry: Expired; non-compliant resource remediated and tags applied
```
