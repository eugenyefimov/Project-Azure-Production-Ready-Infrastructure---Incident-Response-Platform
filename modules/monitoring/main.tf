resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_in_days
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "this" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name
  tags                = var.tags

  # Placeholder notification channels; keep empty in lower environments if needed.
  dynamic "email_receiver" {
    for_each = var.action_group_email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }
}

locals {
  synthetic_monitoring_enabled = var.enable_synthetic_availability && var.synthetic_check_url != null
}

resource "azurerm_monitor_diagnostic_setting" "targets" {
  for_each = { for id in var.diagnostic_target_resource_ids : id => id }

  name                       = "diag-to-law"
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  # Category groups keep configuration generic across different resource types.
  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_metric_alert" "vm_down" {
  name                = "alert-vm-availability"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_resource_ids
  description         = "Triggers when VM availability drops below healthy state."
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

resource "azurerm_monitor_metric_alert" "high_cpu" {
  name                = "alert-vm-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_resource_ids
  description         = "Triggers when VM CPU usage is persistently high."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold_percent
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

resource "azurerm_monitor_metric_alert" "low_disk_space" {
  name                = "alert-vm-low-disk-space"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_resource_ids
  description         = "Triggers when VM OS disk usage is critically high."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Used Percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

resource "azurerm_application_insights" "synthetic" {
  count = local.synthetic_monitoring_enabled ? 1 : 0

  name                = "${var.log_analytics_workspace_name}-appi"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_application_insights_web_test" "service_endpoint" {
  count = local.synthetic_monitoring_enabled ? 1 : 0

  name                    = "synthetic-nginx-endpoint"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.synthetic[0].id
  kind                    = "ping"
  frequency               = var.synthetic_frequency_seconds
  timeout                 = var.synthetic_timeout_seconds
  enabled                 = true
  retry_enabled           = true
  geo_locations           = ["emea-nl-ams-azr", "emea-fr-pra-edge", "emea-gb-db3-azr"]
  description             = "Synthetic service check for Nginx endpoint."
  tags                    = var.tags

  configuration = <<XML
<WebTest Name="synthetic-nginx-endpoint" Id="ABD48585-0831-40CB-9069-682EA6BB358F" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="${var.synthetic_timeout_seconds}" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010">
  <Items>
    <Request Method="GET" Guid="a9818d0f-a18f-4d72-ab6d-ea4f3dcd5f5f" Version="1.1" Url="${var.synthetic_check_url}" ThinkTime="0" Timeout="${var.synthetic_timeout_seconds}" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="nginx-http-check" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML
}

resource "azurerm_monitor_metric_alert" "service_availability_down" {
  count = local.synthetic_monitoring_enabled ? 1 : 0

  name                = "alert-service-availability-endpoint"
  resource_group_name = var.resource_group_name
  scopes = [
    azurerm_application_insights_web_test.service_endpoint[0].id,
    azurerm_application_insights.synthetic[0].id
  ]
  description = "Triggers when synthetic checks fail in multiple regions."
  severity    = var.synthetic_alert_severity_availability
  frequency   = "PT5M"
  window_size = "PT15M"
  tags        = var.tags

  application_insights_web_test_location_availability_criteria {
    web_test_id           = azurerm_application_insights_web_test.service_endpoint[0].id
    component_id          = azurerm_application_insights.synthetic[0].id
    failed_location_count = var.synthetic_failed_location_count
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "service_latency_high" {
  count = local.synthetic_monitoring_enabled ? 1 : 0

  name                = "alert-service-synthetic-latency-high"
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "Service synthetic latency high"
  description         = "Triggers when synthetic endpoint latency is above threshold during the lookback window."
  severity            = var.synthetic_alert_severity_latency
  enabled             = true
  scopes              = [azurerm_log_analytics_workspace.this.id]
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  criteria {
    query = <<KQL
AppAvailabilityResults
| where Name == "synthetic-nginx-endpoint"
| where TimeGenerated > ago(15m)
| summarize avg_duration_ms = avg(DurationMs)
| where avg_duration_ms > ${var.synthetic_latency_threshold_ms}
KQL
    time_aggregation_method = "Maximum"
    threshold               = 0
    operator                = "GreaterThan"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.this.id]
  }

  tags = var.tags
}
