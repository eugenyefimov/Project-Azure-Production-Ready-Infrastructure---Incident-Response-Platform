# Change Lifecycle Example: Safe NSG Rule Addition

This document shows a realistic enterprise change lifecycle for adding a new NSG rule in production with controlled risk.

---

## 1) Change Request (Jira-Style Ticket)

- **Ticket ID:** `CHG-4821`
- **Type:** Standard Change
- **Service:** `customer-api` (prod)
- **Environment:** `prod`
- **Requested by:** Platform Engineering
- **Business owner:** Operations Manager
- **Priority:** High
- **Risk level:** Medium (network-path modification on production ingress)
- **Planned window:** `2026-05-02 22:00-22:45 UTC`
- **Backout window:** `2026-05-02 22:45-23:00 UTC`

### Summary

Add controlled inbound HTTPS rule to the application NSG for newly approved corporate egress CIDR `10.10.40.0/24`.

### Business Justification

New support team location requires secure access path to production application endpoint for operational diagnostics during incidents. Access must be restricted to approved corporate CIDR and fully auditable.

### Scope

- Update NSG rule set in prod application subnet.
- No application code changes.
- No DNS, compute, or database changes.

### Risk Assessment

- Incorrect NSG priority could block existing ingress path.
- Overly broad source range could increase attack surface.

### Mitigations

- Use explicit rule priority ordering and deny precedence review.
- Keep source CIDR exact and approved by security.
- Require plan approval + prod environment approval.
- Validate effective NSG rules before and after apply.

### Success Criteria

- Existing approved CIDRs retain access.
- New approved CIDR can reach HTTPS endpoint.
- No increase in error rate or availability alert firing during watch window.

---

## 2) Git Commit Message

```text
feat(network): add approved prod support CIDR to app HTTPS NSG rule

Enable controlled ingress from the new corporate support location for incident diagnostics.
Keep least-privilege access by allowing only TCP/443 from approved CIDR and preserving deny posture.
```

---

## 3) Pull Request Description

**Title:** `Prod NSG update: allow support CIDR 10.10.40.0/24 on HTTPS`

**Body:**

- **Summary**

- Add new approved corporate CIDR to prod app NSG HTTPS allow rule.
- Preserve existing NSG priority ordering to avoid service disruption.
- No changes to compute resources, app deployment, or routing.

- **Why**

- Support team expansion requires secure production diagnostic access.
- Access is restricted and auditable through IaC workflow.

- **Risk**

- Medium: production network policy update.
- Main failure mode: priority misconfiguration causing ingress outage.

- **Test / Validation Plan**

- [ ] Confirm `terraform plan` changes only target expected NSG rule.
- [ ] Confirm security review approval for CIDR.
- [ ] Apply only in approved prod change window.
- [ ] Verify endpoint access from new CIDR and existing CIDRs.
- [ ] Monitor alerts/error rate for 15 minutes post-apply.

- **Rollback**

- Revert commit and apply previous NSG rule set.
- Estimated rollback completion: <10 minutes.

---

## 4) Terraform Plan Output (Sanitized Example)

```text
Terraform will perform the following actions:

  # module.platform.module.network.azurerm_network_security_group.application will be updated in-place
  ~ resource "azurerm_network_security_group" "application" {
      ~ security_rule = [
          ~ {
              name                    = "allow-trusted-admin-to-app-https"
              priority                = 110
              destination_port_range  = "443"
            ~ source_address_prefixes = [
                "10.10.30.0/24",
              + "10.10.40.0/24",
              ]
            },
        ]
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Plan review decision:

- ✅ Change scope limited to expected NSG rule
- ✅ No destructive actions
- ✅ No unexpected resource drift

---

## 5) Approval Step

Required approvals before apply:

1. **Code review approval** (Platform peer reviewer)
2. **Security approval** (CIDR and least-privilege validation)
3. **Change manager approval** (ticket `CHG-4821`)
4. **GitHub environment approval** (`prod-plan-approval` then `prod`)

Approval evidence retained:

- Jira approval comments
- PR approval history
- GitHub Actions environment approval audit log

---

## 6) Apply Result (Sanitized Example)

```text
module.platform.module.network.azurerm_network_security_group.application: Modifying...
module.platform.module.network.azurerm_network_security_group.application: Modifications complete after 9s

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Immediate post-apply checks:

- `Sev1/Sev2` alerts: none fired
- Endpoint synthetic checks: healthy
- App error rate: no abnormal increase

---

## 7) Verification Steps (Operational)

### A. Configuration Verification

- Confirm effective NSG rule contains new CIDR at expected priority.
- Confirm no unintended rule reordering.

Example command:

```powershell
az network nic list-effective-nsg `
  --resource-group az-ir-platform-p-westeurope-rg-network `
  --name az-ir-platform-p-westeurope-nic-app-01 -o table
```

### B. Access Verification

- From source in new CIDR: `HTTPS 200` to application endpoint.
- From previously approved CIDR: still `HTTPS 200`.
- From non-approved source: denied as expected.

### C. Monitoring Verification

- Check availability and error-rate dashboards for 15 minutes.
- Confirm no regression in service probe success.
- Confirm no related incident channel alerts.

### D. Audit Verification

- Link ticket -> PR -> workflow run -> apply log in change record.
- Mark change as successful with timestamp and approver trail.

---

## 8) Rollback Plan

Rollback trigger conditions:

- endpoint availability drops below threshold after apply
- unauthorized ingress detected
- unexpected NSG side-effects observed

Rollback steps:

1. Revert PR commit in `main` (or apply emergency rollback commit).
2. Trigger `Terraform Prod` workflow with normal approval flow.
3. Verify previous known-good NSG rule set is restored.
4. Re-run endpoint and alert health checks.
5. Update incident/change ticket with root cause and corrective action.

Rollback RTO target:

- **Detection to rollback apply complete:** <10 minutes

---

## 9) Enterprise Process Alignment

This lifecycle follows enterprise change-control principles:

- traceable request and approval chain
- least-privilege network change
- pre-change impact analysis via plan review
- controlled production execution window
- post-change verification and watch period
- explicit rollback readiness with ownership

---

## 10) How To Present This In Internal Change Review

Use this as a real operations story:

1. Start with business need (new support location access requirement).
2. Show risk thinking (priority/order and exposure concerns).
3. Walk through controls (ticket, approvals, plan review, protected apply).
4. Show proof of safe execution (apply + verification).
5. End with rollback readiness and auditability.

Strong closing line:

"I treat network changes as reliability changes: every ingress update must be approved, verifiable, and reversible."
