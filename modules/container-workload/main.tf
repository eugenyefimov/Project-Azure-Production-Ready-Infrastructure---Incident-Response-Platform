resource "azurerm_container_group" "this" {
  name                = var.container_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Private"
  os_type             = "Linux"
  restart_policy      = "Always"
  subnet_ids          = [var.subnet_id]
  tags                = var.tags

  container {
    name   = var.container_name
    image  = var.container_image
    cpu    = var.container_cpu
    memory = var.container_memory_gb

    ports {
      port     = var.container_port
      protocol = "TCP"
    }
  }

  dynamic "diagnostics" {
    for_each = var.log_analytics_workspace_id != null && var.log_analytics_workspace_key != null ? [1] : []
    content {
      log_analytics {
        workspace_id  = var.log_analytics_workspace_id
        workspace_key = var.log_analytics_workspace_key
        log_type      = "ContainerInsights"
      }
    }
  }
}
