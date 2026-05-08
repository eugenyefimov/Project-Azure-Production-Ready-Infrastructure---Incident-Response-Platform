# Runbook: Terraform Partial Apply / Failed Deployment Recovery (Azure)

This runbook is for **failed or partial Terraform applies** against the Azure infrastructure in this repo.

Goals:
- avoid making a bad situation worse
- restore a safe and understandable state
- keep Terraform as the **source of truth** after recovery

---

## 1. Symptoms

Common indicators:
- `terraform apply` exits with non-zero status:
  - provider/API timeout
  - conflict / “Another operation in progress”
  - policy denial (`RequestDisallowedByPolicy`)
  - lock or backend error
- resources partially created:
  - Azure portal shows resources that are not fully configured
  - Terraform plan output is inconsistent with recent changes
- state/resource mismatch:
  - Terraform state lists resources that no longer exist
  - Azure shows resources Terraform does not know about.

---

## 2. Detection

Detection sources:
- CI logs in GitHub Actions (`terraform apply` step failed).
- Local CLI `terraform apply` output.
- Azure Activity Log showing “Failed” or “InProgress” operations for key resources.

First actions (always):
- Save the **full apply log** for evidence.
- Do **NOT** immediately re-run `terraform apply` until you understand the failure class.

Why it matters:
- Re-running blindly can compound drift (Terraform may try to “fix” based on stale state).

---

## 3. Immediate Containment

Containment checklist:
- Stop any further manual `terraform apply` attempts.
- Communicate:
  - inform on-call / change owner in incident channel.
  - set change state to “blocked” until recovery plan agreed.
- Preserve evidence:
  - CI job link
  - apply log
  - timestamp of failure.

When **NOT** to continue apply:
- When the failure involves:
  - policy denial (`RequestDisallowedByPolicy`)
  - NSG / route / DNS changes that may already be in a bad state
  - backend or state corruption.
In these cases, treat as an incident and call incident response, not “just rerun.”

---

## 4. State Validation

Goal:
- confirm whether Terraform’s view of the world (state) is trustworthy.

Steps:
1. List state resources for the failing module:
   - `terraform state list`
2. Check for obvious anomalies:
   - missing references for resources you know exist
   - entries for resources that you know were deleted in Azure.

Why it matters:
- If state is wrong, `plan` and `apply` will be wrong.

Escalation:
- If state file appears corrupted or inconsistent in many places:
  - escalate to platform owner / incident commander
  - consider read-only investigation until consensus is reached.

---

## 5. Resource Validation (Azure-side)

Goal:
- identify what Azure actually did during the failed apply.

Steps (examples):
- Use Azure CLI / portal to inspect:
  - affected RGs (`az resource list -g <rg>`)
  - specific resources (VM, NSG, subnet, container groups).
- Check Azure Activity Log for:
  - operations with `Status != Succeeded`,
  - retries or long “InProgress” operations around failure window.

Why it matters:
- Terraform may have created or changed resources even though apply failed at a later step.

---

## 6. Drift Identification

Drift = “Terraform state vs Azure reality” mismatch.

Steps:
1. Run a **read-only** plan:
   - `terraform plan -no-color` (no `-out` needed yet).
2. Inspect plan:
   - look for unexpected **deletes** or massive changes in unrelated areas.
3. Compare with Activity Log and portal state.

If large unexpected deletes appear:
- DO NOT apply yet.
- Determine if state or configuration is wrong:
  - configuration: code changed incorrectly
  - state: Terraform thinks a resource exists / doesn’t exist incorrectly.

---

## 7. Partial Resource Cleanup (when appropriate)

Sometimes failed applies create “half-baked” Azure resources:
- e.g., VM created but extension failed
- NSG created but not associated.

Guidelines:
- Prefer **fixing via Terraform**:
  - adjust code, re-run plan/apply to complete creation.
- Only delete resources manually when:
  - they are clearly unused / failed
  - you will also fix state representation.

Why it matters:
- Manual deletion without updating state leads to repeated failures or unintended recreation.

---

## 8. Using `terraform import` Safely

Use `terraform import` when:
- a resource exists in Azure, but is missing from state OR
- state was lost but resource should now be managed by Terraform.

Steps:
1. Confirm the resource configuration in `.tf` matches the real Azure properties (or will converge to them).
2. Run:
   - `terraform import <resource.address> <azure-resource-id>`
3. Follow up with `terraform plan` to ensure plan is near-empty for that resource.

When **NOT** to use `import`:
- When the existing resource configuration is wildly different and will cause destructive changes on next apply.
- When the resource should **not** be managed by Terraform long-term.

Escalation:
- For prod-critical resources, require peer review before import.

---

## 9. Using `terraform state rm` Safely

Use `terraform state rm` when:
- Terraform state refers to a resource that no longer exists in Azure **and** you do not want Terraform to recreate it.

Steps:
1. Confirm in Azure:
   - resource does not exist
   - and should not be recreated.
2. Run:
   - `terraform state rm <resource.address>`
3. Run `terraform plan`:
   - confirm that Terraform does **not** try to recreate the removed resource unless intended.

When **NOT** to use `state rm`:
- To “get past” a failure for an existing, important resource.
- When the underlying resource still exists and is or should be managed by Terraform.

Escalation:
- For prod, require agreement from platform lead / incident commander before removing anything from state.

---

## 10. Recovery Workflow (High-Level)

1. **Containment**
   - stop further applies
   - open incident/change record
2. **State and resource validation**
   - inspect `terraform state list`
   - inspect portal/CLI for actual Azure resources
3. **Classify failure type**
   - provider/API timeout
   - policy denial
   - lock / backend error
   - partial creation / mismatch
4. **Decide strategy**
   - re-run apply with same plan (safe only for transient provider errors, no drift)
   - fix configuration and re-apply
   - use `import` / `state rm` to repair state mismatches
5. **Execute recovery**
   - perform chosen operations
   - run `terraform plan` to confirm small, expected delta
   - apply if safe
6. **Validate post-recovery**
   - ensure plan is clean or accepts only expected drift corrections
   - ensure monitoring/alerts behave as expected.

---

## 11. Validation After Recovery

Checklist:
- `terraform plan` is either:
  - empty, or
  - contains only known, approved drift corrections.
- Azure resources:
  - are in the expected configuration (NSG rules, VM sizes, backup bindings, etc.).
- Monitoring:
  - no new unexpected alerts due to misconfigured resources.
- Evidence:
  - recovery steps and decisions recorded in incident/change record.

Why it matters:
- Without validation, you may assume “apply succeeded” while drift or broken configuration remains.

---

## 12. Post-Incident Review

Topics to cover:
- **Root cause of failure**
  - e.g., provider timeout, policy denial, configuration error.
- **Was Terraform’s state accurate?**
  - if not, why did divergence arise?
- **Did we run apply again too early?**
  - were any additional failures self-inflicted?
- **What guardrails should we add?**
  - CI/CD improvements (e.g., block destructive plans in prod)
  - better policy/pre-change checks
  - improved state backup/inspection process.

Escalation guidance:
- For prod or high-impact paths:
  - always treat failed/partial applies as incidents
  - involve platform lead / incident commander early if NSGs, routes, or DNS are involved
  - do not bypass safeguards “just this once” to get apply to succeed.

---

## Realistic Failure Scenarios (Examples)

- **Interrupted apply (network/runner failure):**
  - some Azure operations completed; Terraform did not finish writing state.
  - Recovery: reconcile resources vs state, then carefully re-apply or use `import`.
- **Provider/API timeout:**
  - transient Azure control-plane issue; re-apply may be safe if no drift occurred.
  - Recovery: verify via Activity Log; avoid parallel manual changes.
- **Policy denial:**
  - Azure Policy prevents resource creation/update.
  - Recovery: fix configuration or adjust policy with approval; do not force through.
- **Lock contention / backend errors:**
  - state lock not released or backend unavailable.
  - Recovery: resolve backend issues, confirm no concurrent applies, and retry only when safe.

