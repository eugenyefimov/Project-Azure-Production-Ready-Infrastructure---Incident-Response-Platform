# Realistic End-to-End Incident Scenario

## Scenario selected
**VM CPU spike causing service degradation**  
Why this scenario: it maps directly to **implemented** Terraform resources and workflows:
- Terraform monitoring alert: `azurerm_monitor_metric_alert.high_cpu` in `modules/monitoring/main.tf`
- Workload: Linux VM + Nginx (`modules/linux-vm/main.tf`, `modules/linux-vm/cloud-init.yaml`)
- CI/CD and controlled change path: `.github/workflows/terraform-prod.yml`

## Scope and trust model

This package intentionally separates evidence quality:

- **Real evidence (implemented controls)**
  - The control path exists in code (Terraform + workflows + runbooks).
  - Commands and KQL are runnable against the implemented stack.
- **Sanitized evidence**
  - Incident values/timestamps are realistic but redacted and normalized for portfolio sharing.
- **Simulated placeholders**
  - Explicitly marked where a live export should be attached later.

Use this scenario as a credible walkthrough of operational behavior with the current repository architecture.

