# Governance

## Enforced Policy-As-Code

Governance controls are enforced through Terraform in:

- `modules/governance/main.tf`

Implementation model:

- custom `azurerm_policy_definition` resources
- `azurerm_resource_group_policy_assignment` per environment scope

## Active Controls

1. Require mandatory tags
2. Deny public IP resources (configurable by environment policy variables)
3. Restrict VM sizes to approved allowlists

Scope and behavior are controlled in environment variables and platform module inputs.

## Enforcement Behavior

At apply time, Azure evaluates policy assignments before resource creation/update.

- compliant change -> resource operation proceeds
- non-compliant change -> Azure returns `RequestDisallowedByPolicy` and apply fails

## Defined vs Enforced

- **Defined:** policy exists as code only
- **Enforced:** policy is assigned at active scope with `deny`/`audit`

Only enforced policy changes runtime behavior.

## Violation Handling Workflow

1. Apply fails with policy assignment/definition details.
2. Engineer identifies violating property (tag, public IP, VM SKU).
3. Engineer either:
   - updates change to comply, or
   - submits governed policy change/exemption request with approvals.
4. Re-run plan/apply after approval.

Violation example (sanitized):

```text
Error: creating Linux Virtual Machine "...":
StatusCode=403
Code="RequestDisallowedByPolicy"
Message="Resource action was disallowed by policy assignment 'pa-allowed-vm-sizes'"
```

## Governance Operations

- maintain environment-specific policy parameters
- review exemptions with owner, justification, and expiry
- include policy compliance in monthly operations review
- link policy changes to change records and incident prevention actions
