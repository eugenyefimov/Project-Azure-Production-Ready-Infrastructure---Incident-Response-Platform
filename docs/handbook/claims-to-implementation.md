# Claims to Implementation Traceability

This document is intentionally strict: every important claim must map to concrete implementation artifacts.

If a claim is not implemented in Terraform/GitHub Actions/monitoring configuration, it is marked as **UNSUPPORTED** (even if it exists in the evidence folder as a simulated or sample dataset).

## How to read this

- **Terraform Resource / Module**: where the infrastructure or control should be implemented.
- **CI/CD Workflow**: where pipeline safety and rollout behavior should be implemented.
- **Monitoring / Alerting**: what Azure Monitor resources should exist to support the claim.
- **Runbook**: where responders are told how to investigate and mitigate.
- **Evidence Artifact**: an artifact that should demonstrate the claim in practice.
- **Current Gaps**: exactly what is missing to consider the claim operationally supported.
- **Improvement Recommendation**: concrete next steps to close the gap.

## Traceability Matrix

| Claim | Why It Matters | Terraform Resource / Module | CI/CD Workflow | Monitoring / Alerting | Runbook | Evidence Artifact | Current Gaps | Improvement Recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Environment separation exists (`dev`, `staging`, `prod`) | Limits blast radius; supports safer operational maturity per stage | `environments/dev/main.tf`, `environments/staging/main.tf`, `environments/prod/main.tf` | `.github/workflows/terraform-dev.yml`, `.github/workflows/terraform-staging.yml`, `.github/workflows/terraform-prod.yml` | `modules/platform` composes stage-specific network/workload/monitoring | `docs/handbook/operations.md` | `evidence/live-artifacts/terraform-apply-history.csv` | State/backend initialization resources are not created by this repo; relies on external backend-config variables | Add a small Terraform “state backend bootstrap” package or document required backend resources explicitly (resource group, storage account, container, access controls) |
| State is isolated per environment (distinct Terraform state keys) | Prevents cross-environment drift and accidental overwrite of unrelated infrastructure | `environments/*/backend.tf` placeholders; state key passed via workflow | `.github/workflows/terraform-dev.yml`, `.github/workflows/terraform-staging.yml`, `.github/workflows/terraform-prod.yml` (`key=dev.terraform.tfstate` etc.) | N/A | N/A | `evidence/live-artifacts/terraform-apply-history.csv` and `evidence/live-artifacts/terraform-plan-sanitized.txt` references | Backend state containers/locking policies are not provisioned by this repo; correctness depends on external storage account configuration | Document required backend settings (locking, versioning/immutability, network access) and add a minimal Terraform bootstrap for backend resources |
| VM base images are pinned to reduce drift | Improves reproducibility of VM baselines; reduces “latest” surprises during replacements | `modules/platform/variables.tf` (`linux_source_image_version`, `windows_source_image_version`) and `modules/linux-vm/main.tf`, `modules/windows-vm/main.tf` | N/A | N/A | N/A | None currently found in evidence | No evidence artifact demonstrates which pinned versions were deployed per environment | Add a lightweight “deployment manifest” evidence export (image version inputs + plan outputs) per apply run |
| Azure Resource Group deletion is guarded in provider config | Reduces catastrophic operator mistakes (deleting non-empty RG) | `environments/dev/providers.tf`, `environments/staging/providers.tf`, `environments/prod/providers.tf` | N/A | N/A | N/A | None currently found in evidence | No captured evidence that the guard actually triggers during error cases | Add a short operational test procedure (dry-run style) or document the expected failure mode and how reviewers can verify it |
| OIDC is used for Azure auth in CI (no static cloud secrets in workflow code) | Prevents long-lived credential leakage; improves auditability | N/A (auth is pipeline behavior) | `azure/login@v2` in all workflows; `ARM_USE_OIDC: "true"` | N/A | N/A | `docs/terraform-github-actions.md`, workflow files | Requires correct Entra ID federated credential setup (not verified by Terraform in this repo) | Add a “Pre-flight reviewer checklist” doc for federated identity trust and required RBAC roles; optionally add a Terraform check for expected role assignments |
| CI enforces “plan then approval then apply” | Prevents accidental unreviewed infrastructure mutations | N/A | Workflow job graph: `terraform-plan` -> `plan-approval` -> `terraform-apply` | N/A | N/A | `evidence/terraform-plan-sanitized.txt`, `evidence/terraform-apply-sanitized.txt` | Applies still run with `-auto-approve` (safeguarded by workflow approvals, but still worth strictness) | Keep `-auto-approve` but improve blast-radius guardrails (deny deletes in prod unless explicit input token + required reviewers) |
| Plan integrity is verified via SHA-256 checksum | Prevents plan artifact tampering and ensures apply uses the reviewed plan | N/A | `sha256sum tfplan > tfplan.sha256` then `sha256sum -c tfplan.sha256` | N/A | N/A | `evidence/terraform-plan-sanitized.txt` references plan artifact usage | Checksum verification confirms file integrity, but not “plan matches git diff” (still computed from the same workspace contents at plan time) | Add an immutable `run_id` or commit hash embedding into the plan artifact name and verify it during apply |
| Lint/security checks run before planning | Reduces config mistakes and common insecure IaC patterns | N/A | `tflint`, `tfsec`, `checkov` run in the `terraform-check` job | N/A | N/A | `docs/terraform-github-actions.md` | Security checks assume correct config and policy baseline; there are no example `tflint` config files | Add explicit `tflint` config and document which rules are enabled/disabled; add a short “how to interpret scanner failures” section |
| Prod apply is restricted to manual workflow dispatch and main branch | Prevents prod mutations from PR merges | N/A | `if: github.event_name == 'workflow_dispatch' ... && github.ref == 'refs/heads/main'` | N/A | N/A | `docs/terraform-github-actions.md`, workflows | Branch protection enforcement is assumed to exist in GitHub settings (not enforced by code) | Add `CODEOWNERS` and require status checks for infra paths; document GitHub branch protection requirements in the CI doc |
| Governance policy enforces required tags | Enables cost attribution and consistent ownership; can block non-compliant resources | `modules/governance/main.tf` (`azurerm_policy_definition.require_tags`) and assignment | N/A | N/A | N/A | `evidence/live-artifacts/policy-compliance-evidence.md` and live artifact README | Evidence folder is explicitly “simulated but shaped”; no automation here proves real Azure Policy results | Replace simulated compliance exports with real Azure Policy compliance exports and link them to incident/change IDs |
| Governance policy enforces allowed VM sizes | Prevents unapproved/overprovisioned or unsupported SKUs | `modules/governance/main.tf` (`allowed_vm_sizes`) | N/A | N/A | N/A | `evidence/live-artifacts/policy-compliance-evidence.md` | Policy enforcement depends on correct `governance_allowed_vm_sizes` inputs per environment | Add a short doc listing “approved sizes” and demonstrate at least one real policy-blocked apply outcome |
| Governance can deny creation of public IP resources | Reduces direct internet exposure risk | `modules/governance/main.tf` (`deny_public_ip`) | N/A | N/A | N/A | `modules/governance/main.tf` + policy evidence docs | Public IP behavior is still partially driven by environment variables like `enable_app_vm_public_ip` | Make deny-public-ip unconditional for prod by setting environment defaults and documenting exception workflow |
| RBAC uses least-privilege scope (resource group and resource scope assignments) | Limits CI/CD and admin blast radius in Azure | `modules/rbac/main.tf` (`azurerm_role_assignment`) | N/A | N/A | N/A | `ownership-matrix.md` and RBAC module outputs | RBAC assignments depend on correct object IDs provided; there is no proof automation in this repo | Add a runbook or evidence step to validate role assignments during onboarding (who gets what, and at what scope) |
| Network security limits admin access and denies internet inbound to management | Prevents common attack paths and reduces accidental exposure | `modules/network/main.tf` NSGs + rules (management RDP allow from `admin_source_cidrs`, explicit deny from Internet) | N/A | Indirectly supports alert hygiene | `runbooks/network-issue.md` and `runbooks/vm-not-reachable.md` | `evidence/live-artifacts/activity-log-entries.csv` and incident evidence index | No NSG flow-log provisioning exists in Terraform (RCA depends on other data sources) | Add NSG flow logs / Network Watcher diagnostics and retention to support real RCA |
| Linux VM hardening disables password auth and uses SSH key-only | Reduces credential-stuffing and brute force risk | `modules/linux-vm/main.tf` (`disable_password_authentication = true`, `admin_ssh_key`) | N/A | N/A | `runbooks/ssh-failure.md` | `incident evidence` and runbooks | There is no explicit Defender for Cloud baseline or patch orchestration in Terraform | Add Defender for Cloud / Update Management onboarding (or document why excluded) |
| Monitoring forwards logs/metrics to Log Analytics | Enables investigation and historical evidence | `modules/monitoring/main.tf` (`azurerm_log_analytics_workspace`, `azurerm_monitor_diagnostic_setting`) | N/A | Diagnostic settings | N/A | `evidence/log-analytics-query-results.md` and query exports | Diagnostic setting uses `category_group = "allLogs"` but does not declare which resource types are covered beyond `diagnostic_target_resource_ids` input | Add explicit examples: which resources are in `diagnostic_target_resource_ids` per env and why |
| VM availability and high-CPU alerting exist and route to action group | Provides actionable paging for host-level faults | `modules/monitoring/main.tf` (`azurerm_monitor_metric_alert.vm_down`, `high_cpu`, and `low_disk_space`) | N/A | Metric alerts + action group | `runbooks/vm-not-reachable.md`, `runbooks/high-cpu.md` | `evidence/live-artifacts/azure-monitor-alert-history.csv` | Alert naming and semantics in evidence include many alert types not implemented in Terraform (see unsupported claims below) | Align Terraform alert resources to evidence alert IDs or explicitly label evidence alerts as simulated samples |
| Low disk space alerting exists | Prevents disk-full outages and supports earlier mitigation | `modules/monitoring/main.tf` (`azurerm_monitor_metric_alert.low_disk_space`) | N/A | Metric alert | `runbooks/vm-not-reachable.md` and `runbooks/nginx-down.md` (reused) | No dedicated low-disk evidence slice found | No dedicated runbook for low-disk alert; runbooks are generic | Add `runbooks/low-disk-space.md` and include a checklist for log rotation, tmp cleanup, and metric validation |
| Service-level availability is monitored via synthetic endpoint checks | Detects “service down” even if VM host looks healthy; supports SLO/error budget mapping | `modules/monitoring/main.tf` (`azurerm_application_insights.synthetic`, `azurerm_application_insights_web_test.service_endpoint`, `azurerm_monitor_metric_alert.service_availability_down`, `azurerm_monitor_scheduled_query_rules_alert_v2.service_latency_high`) | Workflow variables can enable/disable synthetic checks per environment | Synthetic availability and latency alerting are provisioned when enabled | `runbooks/nginx-down.md`, `runbooks/network-issue.md` | `evidence/azure-monitor-alert-payload.json`, `evidence/live-artifacts/synthetic-monitoring-evidence-example.md` | Controls are optional and may remain disabled if environment variables are not set; some evidence remains simulated/sanitized | Keep synthetic checks optional but document activation path clearly and attach at least one real sanitized alert/query export when available |
| Dependency monitoring (DNS synthetic checks, DNS timeout cascades) exists | Enables fast fault-domain isolation for common outages | **UNSUPPORTED** in Terraform: no DNS synthetic resources found | N/A | No Terraform-provisioned DNS alerting | `runbooks/dns-issue.md` (process exists) | `runbooks/dns-issue.md`, `slo-month-analysis.md` references | DNS synthetic checks appear only in documentation/evidence, not in Terraform | Add explicit Terraform resources for DNS checks or remove synthetic DNS claims from implemented baseline |
| Security alerting for failed login bursts exists | Ensures security incidents are detected and routed as operational incidents when needed | **UNSUPPORTED** in Terraform: no Log Analytics alert rules or SecurityEvent-based KQL alerts found | N/A | Evidence references `alert-auth-failed-login-burst` | `runbooks/ssh-failure.md` and (no dedicated security runbook) | `evidence/live-artifacts/azure-monitor-alert-history.csv` | Alerts appear only in simulated evidence; no pipeline/config exists to generate actual alerts | Implement KQL-based alert rules (or log-based detection) and document the ingestion source (agent/extension) |
| Incident severity matrix exists and defines escalation thresholds | Ensures consistent and fast escalation | Partially supported: current `docs/handbook/incidents.md` only defines Sev1 and Sev2 | N/A | N/A | Runbooks are severity-agnostic but mapped by symptom | `docs/handbook/incidents.md`, `incident-postmortem.md` | No Sev3/Sev4 definitions in handbook; evidence includes more types | Expand incident handbook with Sev1/2/3/4 and escalation SLAs; add a “severity to runbook mapping” table |
| Incident response workflow is runbook-driven and evidence-linked | Reduces time-to-root-cause and improves auditability | Terraform not applicable; this is process + content | N/A | N/A | `docs/handbook/incidents.md`, runbooks in `runbooks/`, incident postmortems | `evidence/README.md`, `evidence/incident-index.md`, `evidence/incidents/realistic-end-to-end-scenario/*` | Some evidence content is simulated; process claims are real, but runtime telemetry is not fully generated by Terraform | Keep process docs, and continue replacing simulated samples with real sanitized exports over time |
| Evidence collection chain uses immutable IDs to join alert -> logs -> change -> fix | Enables deterministic incident reconstruction | Terraform not applicable | N/A | N/A | N/A | `evidence/incident-index.md` | Not automated; evidence index is static content | Add a lightweight evidence assembly script or documented manual export checklist for reviewers |
| Backups are provisioned via Recovery Services Vault (optional) | Provides resilience and supports compliance expectations | `modules/incident-response/main.tf` (`azurerm_recovery_services_vault`, `azurerm_backup_policy_vm`, `azurerm_backup_protected_vm`) and `modules/platform/main.tf` wiring with `enable_backup` | N/A | N/A | `backup-verification.md`, `vm-recovery.md` | `modules/incident-response/README.md` and backup evidence in `restore-drill.md` | Backup verification is procedural and manual; restore drills are documented as reports (some simulated) | Add a scheduled “backup verification” workflow (non-destructive) that collects job status and stores evidence |
| Recovery objectives (RPO/RTO) are defined and used for closure | Prevents “backup completed” from becoming the sole success metric | Terraform not enforcing RTO/RPO | N/A | N/A | `vm-recovery.md`, `backup-verification.md`, `restore-drill.md` | `restore-drill.md`, `operations/restore-trend.md` | RTO/RPO claims are from documentation/evidence reports; no automation ensures measured RTO stays within targets | Add explicit “closure criteria checklist” in incident evidence template; document how measured RTO is computed and stored |
| Operational KPIs (MTTD/MTTA/MTTR) are measured and tracked with evidence | Makes reliability improvements defendable in interviews | Terraform not applicable | N/A | Some alert history exists as evidence data files | `operations-metrics.md` (definitions) | `evidence/live-artifacts/azure-monitor-alert-history.csv`, `operations-metrics.md` | No automated measurement pipeline; values are narrative-based and evidence might be simulated | Add an automation or at least a reproducible notebook/script to compute MTTx from exported evidence CSVs |
| Operational dashboards/workbooks exist for monitoring and alert quality | On-call needs fast visibility; reduces time-to-triage | **UNSUPPORTED** in Terraform: no workbook resources found | N/A | N/A | N/A | Mentioned in `monitoring.md` and `telemetry-trends.md` | No Azure Monitor workbook provisioning by Terraform | If you want dashboard-as-code, provision Azure Monitor workbooks via Terraform or explicitly document “manual workbook used” |

## Claims Not Yet Fully Implemented

1. **DNS dependency synthetic checks / DNS alerting**
   - Documentation and runbooks exist, but Terraform does not provision DNS synthetic alert rules.
2. **Security log detection alerts** (failed login burst / auth anomaly alert families)
   - Evidence references alert families that are not created by Terraform in this repo.
   - No KQL-based alert rules or agent ingestion paths are provisioned here.
3. **Operational dashboards/workbooks provisioning**
   - Docs refer to dashboards/workbooks, but Terraform resources for dashboards are not present.
4. **Automated KPI/error-budget reporting**
   - SLO/error-budget policy docs and example calculations exist, but no automation computes metrics from alert exports.
5. **Incident evidence index automation**
   - `evidence/incident-index.md` exists as static content; there is no automated evidence assembly or export pipeline.

## Reviewer Verification Guide (Fast)

### CI/CD claims

1. Open `.github/workflows/terraform-dev.yml` / `terraform-staging.yml` / `terraform-prod.yml`.
2. Verify:
   - `tflint`, `tfsec`, `checkov` jobs exist in each `terraform-check`.
   - `terraform plan` writes `tfplan` and generates `tfplan.sha256`.
   - `terraform-apply` verifies checksum with `sha256sum -c tfplan.sha256`.
   - prod/stage apply is gated to `workflow_dispatch` and `github.ref == 'refs/heads/main'`.

### Governance and RBAC claims

1. Open `modules/governance/main.tf`.
2. Verify policy definitions:
   - `require_tags`, `deny_public_ip`, `allowed_vm_sizes` are present.
3. Open `modules/governance/variables.tf` and confirm `name_prefix` is required and used in policy names.
4. Open `modules/rbac/main.tf`.
5. Verify `azurerm_role_assignment` roles and scopes:
   - pipeline principal at resource group scope (Contributor)
   - admin roles at VM scope
   - monitoring reader at Log Analytics workspace scope.

### Monitoring claims

1. Open `modules/monitoring/main.tf`.
2. Verify:
   - `azurerm_log_analytics_workspace`
   - `azurerm_monitor_diagnostic_setting`
   - metric alerts: `vm_down`, `high_cpu`, and `low_disk_space`.
3. Confirm service-level synthetic resources exist and are optional:
   - `azurerm_application_insights`
   - `azurerm_application_insights_web_test`
   - `azurerm_monitor_metric_alert.service_availability_down`
   - `azurerm_monitor_scheduled_query_rules_alert_v2.service_latency_high`
4. Verify activation model:
   - synthetic resources are conditionally created only when `enable_synthetic_availability` is true and a valid synthetic URL is provided.

### Backups and recovery claims

1. Open `modules/incident-response/main.tf`.
2. Verify:
   - `azurerm_recovery_services_vault`
   - `azurerm_backup_policy_vm` daily schedule
   - `azurerm_backup_protected_vm` binds to VM IDs.
3. Validate runbooks exist:
   - `backup-verification.md`
   - `vm-recovery.md`
   - `restore-drill.md`
   - `operations/restore-trend.md`

### Evidence claims

1. Open `evidence/README.md` and `evidence/incident-index.md`.
2. Verify evidence chain:
   - alert payload -> logs/query results -> apply history -> follow-up.
3. Confirm whether evidence is simulated:
   open `evidence/live-artifacts/README.md` and note “simulated but intentionally shaped.”
