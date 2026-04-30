output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_primary_shared_key" {
  description = "Primary shared key for Log Analytics agents/ingestion."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  value       = azurerm_log_analytics_workspace.this.name
}

output "action_group_id" {
  description = "Action group ID used by monitoring alerts."
  value       = azurerm_monitor_action_group.this.id
}

output "vm_down_alert_id" {
  description = "Metric alert ID for VM availability monitoring."
  value       = azurerm_monitor_metric_alert.vm_down.id
}

output "high_cpu_alert_id" {
  description = "Metric alert ID for high CPU monitoring."
  value       = azurerm_monitor_metric_alert.high_cpu.id
}
