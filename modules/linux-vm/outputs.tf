output "vm_id" {
  description = "Linux VM resource ID."
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "Linux VM name."
  value       = azurerm_linux_virtual_machine.this.name
}

output "public_ip_address" {
  description = "Public IP address for SSH/HTTP troubleshooting access."
  value       = try(azurerm_public_ip.this[0].ip_address, null)
}

output "private_ip_address" {
  description = "Private IP address inside the application subnet."
  value       = azurerm_network_interface.this.private_ip_address
}
