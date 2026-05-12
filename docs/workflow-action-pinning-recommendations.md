# Workflow Action Pinning Recommendations

This repository currently uses version tags for GitHub Actions to preserve compatibility and readability.

For stronger supply-chain security, pin third-party actions to immutable commit SHAs after validation in a test branch.

## Actions to consider pinning

- `actions/checkout@v4`
- `hashicorp/setup-terraform@v3`
- `terraform-linters/setup-tflint@v4`
- `azure/login@v2`
- `aquasecurity/tfsec-action@v1.0.3`
- `bridgecrewio/checkov-action@v12`
- `actions/upload-artifact@v4`
- `actions/download-artifact@v4`

## Recommended rollout

1. Pin one workflow at a time in a non-prod test branch.
2. Validate plan and apply behavior remains unchanged.
3. Promote pinned versions across `dev`, `staging`, and `prod` workflows.
4. Revisit quarterly for dependency refresh.
