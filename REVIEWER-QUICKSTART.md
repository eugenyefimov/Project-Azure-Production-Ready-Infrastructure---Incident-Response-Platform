# Reviewer Quickstart (10-Minute Credibility Check)

Use this file to validate what is real vs partial vs planned, without reading the whole repository.

## 1) What Is ACTUALLY Implemented

### Core infrastructure (Terraform)

- Environment-separated roots: `environments/dev`, `environments/staging`, `environments/prod`
- Platform composition and naming/tagging: `modules/platform/main.tf`
- Network, NSGs, and subnet layout: `modules/network/main.tf`
- Linux app VM + optional Windows management VM:
  - `modules/linux-vm/main.tf`
  - `modules/windows-vm/main.tf`
- Monitoring baseline (Log Analytics, diagnostics, VM alerts): `modules/monitoring/main.tf`
- Synthetic service monitoring (implemented as Terraform resources, optional by variable):
  - `azurerm_application_insights.synthetic` in `modules/monitoring/main.tf`
  - `azurerm_application_insights_web_test.service_endpoint` in `modules/monitoring/main.tf`
  - `azurerm_monitor_metric_alert.service_availability_down` in `modules/monitoring/main.tf`
  - `azurerm_monitor_scheduled_query_rules_alert_v2.service_latency_high` in `modules/monitoring/main.tf`
- Backup/recovery resources (optional by variable): `modules/incident-response/main.tf`
- Governance policies (tags, deny public IP, allowed VM sizes): `modules/governance/main.tf`
- RBAC role assignments: `modules/rbac/main.tf`

### CI/CD safety model (GitHub Actions)

- Workflows:
  - `.github/workflows/terraform-dev.yml`
  - `.github/workflows/terraform-staging.yml`
  - `.github/workflows/terraform-prod.yml`
- Implemented controls:
  - `terraform fmt`, `validate`, `tflint`, `tfsec`, `checkov`
  - OIDC login with `azure/login@v2`
  - plan artifact checksum (`tfplan.sha256`) and apply-time checksum verification
  - manual apply gates (especially strict in prod) with environment approvals

### Runbooks and operational process

- Core incident and platform runbooks:
  - `runbooks/nginx-down.md`
  - `runbooks/high-cpu.md`
  - `runbooks/vm-not-reachable.md`
  - `runbooks/network-issue.md`
  - `runbooks/dns-issue.md`
  - `runbooks/ssh-failure.md`
  - `runbooks/rdp-failure.md`
  - `runbooks/terraform-partial-apply-recovery.md`
  - `runbooks/oidc-authentication-failure.md`
- Recovery workflow docs:
  - `docs/handbook/restore-drill-process.md`
  - `backup-verification.md`
  - `vm-recovery.md`
  - `restore-drill.md`

## 2) What Is PARTIALLY Implemented

- Synthetic monitoring enablement is implemented in Terraform, but operational rollout is variable-driven:
  - resources exist in `modules/monitoring/main.tf`
  - defaults are `false` in environment variables (`environments/*/variables.tf`)
  - workflow env var sets currently do not explicitly pass synthetic variables in `.github/workflows/terraform-*.yml`
- Evidence model exists and is structured, but some artifacts are sanitized/simulated rather than raw production exports:
  - see `evidence/live-artifacts/README.md`
  - see `evidence/incidents/realistic-end-to-end-scenario/README.md`
- Recovery drills are process-strong and evidence-oriented, but not automated end-to-end:
  - see `docs/handbook/restore-drill-process.md`

## 3) What Is PLANNED / NOT FULLY CLOSED

- Automated evidence assembly pipeline (currently manual/documented process)
- Fully automated KPI computation (MTTD/MTTA/MTTR from exported evidence)
- Optional expansion of synthetic checks beyond one high-value endpoint
- More direct capture of live Azure exports to reduce simulation footprint further

## 4) Exact Terraform Locations (High-Value)

- Root environment orchestration:
  - `environments/dev/main.tf`
  - `environments/staging/main.tf`
  - `environments/prod/main.tf`
- Provider/backends:
  - `environments/dev/providers.tf`, `environments/staging/providers.tf`, `environments/prod/providers.tf`
  - `environments/*/backend.tf`
- Platform composition:
  - `modules/platform/main.tf`
  - `modules/platform/variables.tf`
- Monitoring:
  - `modules/monitoring/main.tf`
  - `modules/monitoring/variables.tf`
  - `modules/monitoring/outputs.tf`
- Governance and RBAC:
  - `modules/governance/main.tf`
  - `modules/rbac/main.tf`
- Recovery:
  - `modules/incident-response/main.tf`

## 5) Exact Monitoring Resources

Defined in `modules/monitoring/main.tf`:

- `azurerm_log_analytics_workspace.this`
- `azurerm_monitor_action_group.this`
- `azurerm_monitor_diagnostic_setting.targets`
- `azurerm_monitor_metric_alert.vm_down`
- `azurerm_monitor_metric_alert.high_cpu`
- `azurerm_monitor_metric_alert.low_disk_space`
- `azurerm_application_insights.synthetic` (synthetic telemetry component)
- `azurerm_application_insights_web_test.service_endpoint` (HTTP synthetic check)
- `azurerm_monitor_metric_alert.service_availability_down` (failed probe locations)
- `azurerm_monitor_scheduled_query_rules_alert_v2.service_latency_high` (latency degradation)

## 6) Exact CI/CD Workflows

- `.github/workflows/terraform-dev.yml`
- `.github/workflows/terraform-staging.yml`
- `.github/workflows/terraform-prod.yml`

Reviewer checks:

- OIDC auth path (`azure/login@v2`, `ARM_USE_OIDC`)
- security/static checks before plan
- plan/apply split with checksum verification
- prod apply hard gate (`workflow_dispatch` + explicit confirmation input)

## 7) Exact Runbooks

- `runbooks/nginx-down.md`
- `runbooks/high-cpu.md`
- `runbooks/vm-not-reachable.md`
- `runbooks/network-issue.md`
- `runbooks/dns-issue.md`
- `runbooks/ssh-failure.md`
- `runbooks/rdp-failure.md`
- `runbooks/terraform-partial-apply-recovery.md`
- `runbooks/oidc-authentication-failure.md`

## 8) Exact Evidence Folders

- `evidence/`
- `evidence/live-artifacts/`
- `evidence/incidents/`
- `evidence/incidents/realistic-end-to-end-scenario/`
- `evidence/incidents/sample-incident/`
- `evidence/restore-drills/`
- `evidence/restore-drills/2026-05-monthly-drill/`

## 9) Exact Recovery Workflows

- Terraform backup resources:
  - `modules/incident-response/main.tf`
- Operational process and drill:
  - `docs/handbook/restore-drill-process.md`
  - `restore-drill.md`
  - `backup-verification.md`
  - `vm-recovery.md`
- Recovery evidence package:
  - `evidence/restore-drills/2026-05-monthly-drill/`

## 10) Exact Limitations (Direct, No Marketing)

- This is a small-scope, VM-centric platform, not a large distributed production estate.
- Some evidence is intentionally sanitized/simulated to show process quality without exposing real tenant data.
- Synthetic monitoring is implemented but may not be active in all environments unless variables are explicitly enabled.
- No full automation pipeline yet for evidence collection and KPI calculation.
- Backend state bootstrap and GitHub branch protection are assumed external controls, not fully provisioned by this repo.

## Suggested Interview Discussion Topics

- Why VM health is not equivalent to service health, and why synthetic checks were added.
- Why plan checksum verification was added in CI/CD and what risk it mitigates.
- How OIDC reduces secret management risk vs static credentials.
- How governance policies are enforced in Terraform and where they can still drift operationally.
- How restore drills prove recoverability better than "backup configured" claims.
- What is intentionally simulated and why that is disclosed.

## Suggested Technical Walkthrough Order (Reviewer-Friendly)

1. `README.md` (project framing and scope honesty)
2. `modules/platform/main.tf` (composition model)
3. `modules/monitoring/main.tf` (host + service-level monitoring)
4. `.github/workflows/terraform-prod.yml` (safety gates and OIDC)
5. `modules/incident-response/main.tf` + `docs/handbook/restore-drill-process.md` (recovery maturity)
6. `runbooks/terraform-partial-apply-recovery.md` and `runbooks/oidc-authentication-failure.md` (operational support depth)
7. `evidence/incidents/realistic-end-to-end-scenario/` and `evidence/restore-drills/2026-05-monthly-drill/` (credibility artifacts)
8. `docs/handbook/claims-to-implementation.md` (honesty and gap tracking)

## Known Realism Limitations

- Limited scale by design (single-platform operational baseline).
- No claim of full SRE automation; this is a realistic operations portfolio, not a production SaaS control plane.
- Evidence quality is mixed (real structure, partly simulated content) and must be called out in interviews.
- Manual operational steps still exist in incident and recovery evidence assembly.
