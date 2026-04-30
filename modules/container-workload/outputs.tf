output "container_group_id" {
  description = "Azure resource ID of the container group."
  value       = azurerm_container_group.this.id
}

output "container_group_name" {
  description = "Name of the container group."
  value       = azurerm_container_group.this.name
}

output "container_private_ip" {
  description = "Private IP address assigned to the container group."
  value       = azurerm_container_group.this.ip_address
}

output "container_fqdn" {
  description = "FQDN assigned to the container group (null for private mode)."
  value       = azurerm_container_group.this.fqdn
}
