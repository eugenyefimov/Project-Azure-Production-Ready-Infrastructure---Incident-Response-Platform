# Terraform Plan Artifact Template

Status: Simulated/Sanitized Sample

Workflow: `Terraform <Env>`  
Run ID: `<github-run-id>`  
Commit: `<short-sha>`  
Environment: `dev|staging|prod`

## Plan summary excerpt

```text
Terraform will perform the following actions:
  # module.network.azurerm_network_security_group.application will be updated in-place
  ~ resource "azurerm_network_security_group" "application" { ... }

Plan: 0 to add, 1 to change, 0 to destroy.
```

## Integrity proof excerpt

```text
sha256sum tfplan > tfplan.sha256
sha256sum -c tfplan.sha256
tfplan: OK
```

## Sanitization notes

- remove subscription IDs, tenant IDs, and secrets
- keep resource action types (`add/change/destroy`) and totals
