# Terraform CI/CD With GitHub Actions (Azure OIDC)

This document explains the environment-separated Terraform pipelines in:

- `.github/workflows/terraform-dev.yml`
- `.github/workflows/terraform-staging.yml`
- `.github/workflows/terraform-prod.yml`

## Operational Objective

The pipeline is designed to reduce production change risk while maintaining delivery speed in lower environments.

Control goals:

- catch syntax, validation, and security issues before plan/apply
- require human approval for high-impact changes
- prevent accidental production mutation from routine merges
- keep every infrastructure change traceable to a reviewed commit and workflow run

## Pipeline Flow

Each environment workflow follows the same maturity pattern:

1. `terraform fmt -check -recursive`
2. `terraform init -backend=false` and `terraform validate`
3. optional security scan stage (`tfsec` / `checkov`) controlled by repository variables
4. `terraform plan -out=tfplan`
5. upload plan artifact
6. manual **plan approval gate** (GitHub Environment)
7. manual `terraform apply` using the previously approved plan artifact

The production workflow has additional hard stops:

- no automatic apply on push/PR
- apply is allowed only via `workflow_dispatch`
- operator must provide `approve_production_apply=APPROVE-PROD-APPLY`
- apply only from `main` and through protected `prod` environment approvals

## Why OIDC Is Better Than Static Credentials

OIDC improves security and operations because:

- No long-lived client secrets stored in GitHub
- Short-lived federated tokens are minted per workflow run
- Lower secret leakage risk and easier credential rotation
- Better traceability (token tied to workflow identity/claims)
- Supports least-privilege RBAC per environment/service principal

For production pipelines, this is strongly preferred over static client secrets.

## Azure Setup

1. Create an Entra ID application/service principal for GitHub Actions.
2. Add federated credential on that app for this GitHub repo and branch/environment trust rule.
3. Assign least-privilege RBAC roles:
   - Subscription/Resource Group scope role for Terraform changes (`Contributor` at minimum required scope)
   - Backend state access roles on storage account/container
4. Ensure backend resources exist:
   - state resource group
   - storage account
   - blob container

5. Configure GitHub Environment protections:
   - `dev`, `staging`, `prod` environments with required reviewers
   - `dev-plan-approval`, `staging-plan-approval`, `prod-plan-approval` environments for plan gates

## GitHub Repository Configuration

Add the following **Repository Variables**:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`
- `TF_PROJECT_NAME`
- `TF_LOCATION`
- `TF_VNET_CIDR_JSON` (example: `["10.40.0.0/16"]`)
- `TF_SUBNET_CIDRS_JSON` (example: `{"management":"10.40.1.0/24","application":"10.40.2.0/24","monitoring":"10.40.3.0/24"}`)
- `TF_ADMIN_SOURCE_CIDRS_JSON` (example: `["10.10.10.0/24"]`)
- `TF_ENABLE_APP_VM_PUBLIC_IP` (`true`/`false`)
- `TF_LINUX_VM_SIZE`
- `TF_LINUX_ADMIN_USERNAME`
- `TF_WINDOWS_VM_SIZE`
- `TF_ENABLE_MANAGEMENT_VM_PUBLIC_IP` (`true`/`false`)
- `TF_WINDOWS_ADMIN_USERNAME`
- `TF_LOG_RETENTION_IN_DAYS`
- `TF_CPU_ALERT_THRESHOLD_PERCENT`
- `TF_ACTION_GROUP_EMAIL_RECEIVERS_JSON` (example: `[{"name":"cloudsupport-oncall","email_address":"oncall@example.com"}]`)
- `TF_BACKUP_TIME_UTC` (example: `23:00`)
- `TF_BACKUP_DAILY_RETENTION_COUNT`
- `TF_OWNER`
- `TF_COST_CENTER`
- `TF_BUSINESS_UNIT`
- `TF_EXTRA_TAGS_JSON` (example: `{"service":"incident-response"}`)
- `TF_ENABLE_CONTAINER_WORKLOAD` (`true`/`false`, optional)
- `TF_CONTAINER_SUBNET_CIDR` (example: `10.40.4.0/24`, required if container workload enabled)
- `TF_CONTAINER_IMAGE` (example: `nginx:stable-alpine`)
- `TF_CONTAINER_CPU` (example: `0.5`)
- `TF_CONTAINER_MEMORY_GB` (example: `1`)
- `ENABLE_TFSEC` (`true`/`false`, optional)
- `ENABLE_CHECKOV` (`true`/`false`, optional)

Add the following **Repository Secrets**:

- `TF_ADMIN_SSH_PUBLIC_KEY`
- `TF_WINDOWS_ADMIN_PASSWORD`

## Workflow Execution

- Pull requests / pushes to `main`:
  - run environment-specific `fmt`, `validate`, optional security scans, and `plan`
- Manual apply for `dev`/`staging`:
  1. Open the specific workflow (`Terraform Dev` or `Terraform Staging`)
  2. Click **Run workflow**
  3. Set `run_apply=true`
  4. Complete plan approval and environment approval
- Manual apply for `prod`:
  1. Open `Terraform Prod`
  2. Click **Run workflow**
  3. Set `run_apply=true`
  4. Set `approve_production_apply=APPROVE-PROD-APPLY`
  5. Complete plan approval and production environment approval

## Why Separation Of Environments Matters

- Prevents high-risk production behavior from being coupled to dev iteration speed.
- Allows stricter controls in prod (stronger approvals, tighter defaults, no accidental apply).
- Improves blast-radius control when a bad change enters the pipeline.
- Supports realistic promotion flow (`dev` -> `staging` -> `prod`) with confidence gates.

## State Protection Recommendations

Use these controls to protect Terraform state and reduce destructive pipeline mistakes:

- Store state in dedicated Azure Storage account with least-privilege RBAC.
- Disable public network access for state storage where possible; use private endpoints.
- Enable soft delete and blob versioning on the state container.
- Turn on storage account immutability/version retention based on compliance policy.
- Use state locking and avoid parallel applies to same workspace/environment.
- Keep one state key per environment (`dev.terraform.tfstate`, `staging...`, `prod...`).
- Monitor and alert on state storage access anomalies.
- Back up state snapshots and test recovery procedure regularly.

## Risks Of Bad CI/CD Design

Common anti-patterns and consequences:

- **Single pipeline for all environments with weak guards**
  - dev-grade changes can leak into prod path
- **Automatic apply on merge to main**
  - production outages from unreviewed or poorly understood changes
- **No plan approval**
  - operators may apply destructive changes without human verification
- **Recalculating plan at apply time without artifact control**
  - code drift between plan/apply introduces unreviewed changes
- **Broad IAM permissions for pipeline identities**
  - CI compromise becomes subscription-wide compromise
- **No security checks in CI**
  - risky Terraform constructs reach apply stage undetected

## How CI/CD Mistakes Can Break Production

CI/CD is a force multiplier: safe design prevents incidents, unsafe design amplifies them.

Examples:

- A mistaken NSG rule auto-applied to prod can block customer traffic in minutes.
- An incorrect Terraform variable default can remove critical resources if applies are ungated.
- A compromised pipeline token with broad access can alter security controls and exfiltrate data.
- Missing policy/security checks allows insecure drift that later causes outages or compliance failures.

The practical control model is:

- separate environments
- mandatory plan review
- manual/protected production apply
- least-privilege OIDC identity
- policy and security checks before apply

## Security Review And Bad Practice Check

### Current Security Strengths

- Uses OIDC (`azure/login`) instead of static cloud credentials
- Minimal workflow token permissions (`contents:read`, `id-token:write` only where required)
- No hardcoded secrets in workflow code
- Manual apply gate is explicit (`workflow_dispatch` + approvals)
- Separate workflow isolation by environment
- Production apply requires explicit confirmation phrase
- Terraform state uses environment-specific keys in remote backend

### Risks To Watch

- `terraform apply -auto-approve` is non-interactive: rely on strong environment approval gates
- Broad RBAC roles can still be risky if not scoped tightly
- Public IP toggles must be disabled (`false`) in higher environments unless explicitly justified
- Optional security scans are bypassed when not enabled (`ENABLE_TFSEC` / `ENABLE_CHECKOV`)

### Recommended Improvements

- Scope RBAC to resource group instead of subscription when possible
- Enforce required reviewers for all plan approval and apply environments
- Add policy/security checks (`tflint`, `tfsec`, `checkov`) before plan/apply
- Consider signed attestations for plan artifacts in higher assurance environments
- Enforce stricter branch protections and CODEOWNERS for infrastructure paths
