# Immutable Promotion Lifecycle (dev -> staging -> prod)

This document shows one immutable artifact promoted across environments without rebuild.

## 1) Build Output (Single Artifact Identity)

- **Build workflow:** `app-build-and-publish.yml`
- **Build run ID:** `20577431102`
- **Commit SHA:** `9f2c7e6b14d53fb66d1b4e2f8579f40d3f6a6a9a`
- **Container image tag:** `ghcr.io/org/customer-api:2026.05.18-9f2c7e6`
- **Container image digest (immutable):** `sha256:6e193a9f5c43e7ff4b23381bb8dd3b8322e1324f4f8fd94d1f0c9108bfc8c5d7`
- **SBOM artifact ID:** `sbom-customer-api-20577431102`

Build snippet:

```text
2026-05-18T10:12:31Z docker build -t ghcr.io/org/customer-api:2026.05.18-9f2c7e6 .
2026-05-18T10:13:19Z docker push ghcr.io/org/customer-api:2026.05.18-9f2c7e6
2026-05-18T10:13:47Z digest: sha256:6e193a9f5c43e7ff4b23381bb8dd3b8322e1324f4f8fd94d1f0c9108bfc8c5d7 size: 2204
2026-05-18T10:14:02Z cosign verify ghcr.io/org/customer-api@sha256:6e193a9f5c43...
2026-05-18T10:14:03Z verification: OK
```

Promotion rule:

- all environments must deploy the same digest (`sha256:6e193...c5d7`)
- no environment may rebuild or retag with different content

---

## 2) Environment Promotion Evidence

## Dev Promotion

- **Pipeline:** `Terraform Dev`
- **Run ID:** `10486712021`
- **Plan result:** `1 to change` (container image digest only)
- **Apply result:** success
- **Artifact used:** `ghcr.io/org/customer-api@sha256:6e193a9f5c43e7ff4b23381bb8dd3b8322e1324f4f8fd94d1f0c9108bfc8c5d7`

Dev pipeline snippet:

```text
2026-05-18T10:22:11Z [dev] download artifact manifest
2026-05-18T10:22:12Z image_digest=sha256:6e193a9f5c43e7ff4b23381bb8dd3b8322e1324f4f8fd94d1f0c9108bfc8c5d7
2026-05-18T10:22:17Z terraform plan -out=tfplan
2026-05-18T10:22:27Z Plan: 0 to add, 1 to change, 0 to destroy.
2026-05-18T10:23:14Z terraform apply tfplan
2026-05-18T10:23:45Z Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

## Staging Promotion

- **Pipeline:** `Terraform Staging`
- **Run ID:** `10486718809`
- **Plan result:** `2 to change` (image digest + stricter alert threshold)
- **Approval evidence:** `staging-plan-approval` approved by `teamlead.cloudsupport`
- **Apply result:** success
- **Artifact used:** same digest (`sha256:6e193...c5d7`)

Staging pipeline snippet:

```text
2026-05-18T11:04:08Z [staging] image_digest=sha256:6e193a9f5c43e7ff4b23381bb8dd3b8322e1324f4f8fd94d1f0c9108bfc8c5d7
2026-05-18T11:04:40Z terraform plan -out=tfplan
2026-05-18T11:04:53Z Plan: 0 to add, 2 to change, 0 to destroy.
2026-05-18T11:05:02Z Waiting for review from environment 'staging-plan-approval'
2026-05-18T11:08:19Z Reviewer teamlead.cloudsupport approved deployment
2026-05-18T11:08:41Z terraform apply tfplan
2026-05-18T11:09:26Z Apply complete! Resources: 0 added, 2 changed, 0 destroyed.
```

## Prod Promotion

- **Pipeline:** `Terraform Prod`
- **Run ID:** `10486732044`
- **Plan result:** `3 to change` (image digest + network policy + observability metadata)
- **Approval evidence:**
  - `prod-plan-approval` approved by `platform.manager`
  - `prod` environment approved by `ops.duty-manager`
  - manual confirmation: `approve_production_apply=APPROVE-PROD-APPLY`
- **Apply result:** success (later incident rollback executed in `10486736788`)
- **Artifact used:** same digest (`sha256:6e193...c5d7`)

Prod pipeline snippet:

```text
2026-05-18T12:55:12Z [prod] image_digest=sha256:6e193a9f5c43e7ff4b23381bb8dd3b8322e1324f4f8fd94d1f0c9108bfc8c5d7
2026-05-18T12:56:21Z terraform plan -out=tfplan
2026-05-18T12:56:37Z Plan: 0 to add, 3 to change, 0 to destroy.
2026-05-18T12:56:45Z Waiting for review from environment 'prod-plan-approval'
2026-05-18T13:01:52Z Reviewer platform.manager approved deployment
2026-05-18T13:02:19Z Waiting for review from environment 'prod'
2026-05-18T13:03:07Z Reviewer ops.duty-manager approved deployment
2026-05-18T13:03:09Z Production apply confirmation phrase validated
2026-05-18T13:03:20Z terraform apply tfplan
2026-05-18T13:12:01Z Apply complete! Resources: 0 added, 3 changed, 0 destroyed.
```

---

## 3) Terraform Plan Differences Per Environment

Same image digest promoted, environment-specific configuration differs by design.

## Dev plan (`run_id: 10486712021`)

```text
~ module.container_workload.azurerm_container_group.this
  ~ image = "ghcr.io/org/customer-api@sha256:6e193a9f5c43e7ff4b23381bb8dd3b8322e1324f4f8fd94d1f0c9108bfc8c5d7"
Plan: 0 to add, 1 to change, 0 to destroy.
```

## Staging plan (`run_id: 10486718809`)

```text
~ module.container_workload.azurerm_container_group.this
  ~ image = "ghcr.io/org/customer-api@sha256:6e193a9f5c43e7ff4b23381bb8dd3b8322e1324f4f8fd94d1f0c9108bfc8c5d7"
~ module.monitoring.azurerm_monitor_metric_alert.cpu_anomaly
  ~ threshold = 82 -> 78
Plan: 0 to add, 2 to change, 0 to destroy.
```

## Prod plan (`run_id: 10486732044`)

```text
~ module.container_workload.azurerm_container_group.this
  ~ image = "ghcr.io/org/customer-api@sha256:6e193a9f5c43e7ff4b23381bb8dd3b8322e1324f4f8fd94d1f0c9108bfc8c5d7"
~ module.platform.azurerm_network_security_group.application
  ~ security_rule.allow-https-trusted.source_address_prefixes updated
~ module.monitoring.azurerm_monitor_action_group.main
  ~ webhook_receiver.use_common_alert_schema = true
Plan: 0 to add, 3 to change, 0 to destroy.
```

Interpretation:

- artifact is immutable and identical across environments
- plans differ due to environment-specific policy, risk posture, and monitoring controls

---

## 4) Promotion Blocked Scenario (Failure Case)

## Attempted promotion

- **From:** staging -> prod
- **Attempt run ID:** `10486690131`
- **Status:** blocked before apply

Blocking reasons:

1. `checkov` failed on prod plan (`CKV_AZURE_190`): NSG rule introduced broad source `0.0.0.0/0`.
2. Manual rejection by prod approver due to failed security gate and missing risk exception.

Failure evidence snippet:

```text
2026-05-18T12:14:44Z checkov scan started
2026-05-18T12:15:01Z FAILED: CKV_AZURE_190 Ensure restrictive NSG ingress for management ports
2026-05-18T12:15:01Z policy result: fail
2026-05-18T12:15:03Z Waiting for review from environment 'prod-plan-approval'
2026-05-18T12:18:47Z Reviewer platform.manager rejected deployment
2026-05-18T12:18:47Z Comment: "Rejected - security policy failure not waived, revise NSG rule scope and rerun."
2026-05-18T12:18:48Z Job failed with exit code 1
```

Why this is useful:

- proves pipeline can stop unsafe promotions even when artifact itself is valid
- separates application artifact trust from infrastructure policy risk

---

## 5) Rollback Reference

Related incident: `INC-2026-05-18-002`

- **Rollback run ID:** `10486736788`
- **Action:** keep NSG hotfix + roll back image from `REL-2026.05.18.1` to `REL-2026.05.17.7`
- **Evidence:** `evidence/terraform-apply-sanitized.txt`

Rollback snippet:

```text
2026-05-18T13:30:02Z ~ image = "ghcr.io/org/customer-api:REL-2026.05.17.7"
2026-05-18T13:37:49Z Apply complete! Resources: 0 added, 2 changed, 0 destroyed.
```

---

## 6) Why Immutable Promotion Is Critical For Reliability

- eliminates "works in staging, fails in prod because artifact changed" class of incidents
- narrows incident scope: if behavior differs, investigate environment config/policy, not hidden rebuild drift
- improves rollback confidence because prior known-good digest can be redeployed exactly
- makes approvals meaningful: reviewers approve a concrete digest + plan, not a mutable tag
- strengthens auditability: commit SHA, digest, plan, approval, and apply logs form one traceable chain

Operational rule:

- **Build once, promote many, never rebuild between environments.**
