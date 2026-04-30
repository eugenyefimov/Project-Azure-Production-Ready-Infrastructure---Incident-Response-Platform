output "resource_group_name" {
  description = "Name of the resource group containing network resources."
  value       = azurerm_resource_group.this.name
}

output "virtual_network_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "virtual_network_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Subnet IDs by logical role."
  value = {
    management  = azurerm_subnet.management.id
    application = azurerm_subnet.application.id
    monitoring  = azurerm_subnet.monitoring.id
    container   = try(azurerm_subnet.container[0].id, null)
  }
}

output "nsg_ids" {
  description = "Network security group IDs by subnet role."
  value = {
    management  = azurerm_network_security_group.management.id
    application = azurerm_network_security_group.application.id
    monitoring  = azurerm_network_security_group.monitoring.id
    container   = try(azurerm_network_security_group.container[0].id, null)
  }
}
