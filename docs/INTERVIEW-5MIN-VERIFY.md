# Interview 5-Minute Verify

## 1) What this repo demonstrates

Support-focused Azure operations practice:

- environment-separated Terraform for VM platform operations
- controlled GitHub Actions CI/CD with Azure OIDC and plan integrity checks
- baseline monitoring/alerting and practical runbooks
- governance/RBAC controls and evidence-driven incident/restore workflow

## 2) What is fully implemented

### Implemented

- Terraform roots: `environments/dev`, `environments/staging`, `environments/prod`
- Module composition: `modules/platform/main.tf`
- Monitoring baseline resources: `modules/monitoring/main.tf`
- Governance policy definitions/assignments: `modules/governance/main.tf`
- RBAC role assignments: `modules/rbac/main.tf`
- OIDC CI/CD + plan checksum flow: `.github/workflows/terraform-*.yml`
- Core runbooks in `runbooks/`

## 3) What is simulated/documented

### Partial

- Synthetic endpoint monitoring is conditional and may be disabled per environment.
- Restore evidence is process-strong but includes placeholder/sanitized artifacts.

### Simulated/Sanitized

- Portions of `evidence/live-artifacts/` are intentionally simulated/sanitized.

### Planned

- KPI automation pipeline (MTTD/MTTA/MTTR auto-calculation)
- Workbook-as-code
- Advanced anomaly/security alerting

## 4) Fast verification checklist

1. Confirm implementation honesty labels in `README.md` and `docs/handbook/claims-to-implementation.md`.
2. Verify Terraform environment separation in `environments/*/main.tf`.
3. Verify CI/CD OIDC + plan/apply controls in `.github/workflows/terraform-prod.yml`.
4. Verify monitoring alerts in `modules/monitoring/main.tf`.
5. Verify governance and RBAC in `modules/governance/main.tf` and `modules/rbac/main.tf`.
6. Verify incident and recovery runbooks in `runbooks/`.
7. Verify evidence authenticity notes in `evidence/live-artifacts/README.md`.

## 5) Key files to inspect

- `README.md`
- `REVIEWER-QUICKSTART.md`
- `docs/handbook/claims-to-implementation.md`
- `modules/platform/main.tf`
- `.github/workflows/terraform-prod.yml`
- `modules/monitoring/main.tf`
- `docs/handbook/incidents.md`

## 6) CI/CD proof points

- `azure/login@v2` with OIDC in all terraform workflows
- mandatory check stage includes `fmt`, `validate`, `tflint`, `tfsec`, `checkov`
- plan artifact (`tfplan`) + checksum (`tfplan.sha256`) generated and uploaded
- apply job verifies checksum before apply
- production apply requires `workflow_dispatch` + explicit confirmation input + protected environment

## 7) Monitoring proof points

- Log Analytics workspace and diagnostic settings are provisioned
- VM alerts are provisioned: availability, high CPU, low disk
- action group is wired for alert routing
- synthetic service checks exist as optional resources

## 8) Governance/RBAC proof points

- Policy controls: required tags, allowed VM sizes, optional deny public IP
- RBAC scope model: pipeline contributor at RG scope, scoped VM admin login, monitoring reader
- enforcement behavior is documented and linked to apply failure handling runbooks

## 9) Incident response proof points

- Incident flow and severity model: `docs/handbook/incidents.md`
- Evidence template: `docs/handbook/incident-evidence-template.md`
- Failure recovery runbooks: `runbooks/terraform-partial-apply-recovery.md`, `runbooks/oidc-authentication-failure.md`
- Evidence indexing chain: `evidence/incident-index.md`

## 10) Evidence authenticity explanation

- This repository separates implementation proof from evidence realism.
- Simulated/sanitized artifacts are explicitly labeled and never presented as raw production telemetry.
- Authenticity is preserved through consistent IDs, repeatable structure, and cross-reference to implemented controls.

## 11) Suggested interview questions

- "What is implemented in code vs documented only?"
- "How does the plan checksum reduce apply risk?"
- "What would you improve first for operational trust?"
- "How do you handle OIDC failure without weakening security?"
- "How do runbooks and evidence reduce mean time to recovery?"

## 12) Known limitations

- Some evidence remains simulated/sanitized and should be progressively replaced with real sanitized exports.
- Severity and KPI process is documented; KPI calculation is not fully automated.
- Backend bootstrap and GitHub branch protections are external prerequisites, not provisioned by this repo.
