# Module: monitoring

Reusable Azure monitoring baseline module.

Includes:

- Log Analytics Workspace
- Azure Monitor Action Group (placeholder)
- Diagnostic settings forwarding logs/metrics to Log Analytics
- VM alerts:
  - VM availability down
  - High CPU usage
  - Low OS disk space on VMs (critical threshold)
- Optional synthetic monitoring (Application Insights):
  - HTTP endpoint web test
  - Availability alert based on repeated failed probe locations
  - Latency alert based on synthetic result trends in Log Analytics
