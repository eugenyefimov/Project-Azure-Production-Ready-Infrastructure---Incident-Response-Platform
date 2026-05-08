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

output "synthetic_application_insights_id" {
  description = "Application Insights ID used for synthetic service monitoring."
  value       = try(azurerm_application_insights.synthetic[0].id, null)
}

output "synthetic_web_test_id" {
  description = "Synthetic web test ID for service endpoint availability checks."
  value       = try(azurerm_application_insights_web_test.service_endpoint[0].id, null)
}

output "service_availability_alert_id" {
  description = "Alert ID for synthetic service availability failures."
  value       = try(azurerm_monitor_metric_alert.service_availability_down[0].id, null)
}

output "service_latency_alert_id" {
  description = "Alert ID for synthetic service latency degradation."
  value       = try(azurerm_monitor_scheduled_query_rules_alert_v2.service_latency_high[0].id, null)
}
