output "vm_id" {
  description = "Windows VM resource ID."
  value       = azurerm_windows_virtual_machine.this.id
}

output "vm_name" {
  description = "Windows VM name."
  value       = azurerm_windows_virtual_machine.this.name
}

output "public_ip_address" {
  description = "Public IP address for RDP support access."
  value       = try(azurerm_public_ip.this[0].ip_address, null)
}

output "private_ip_address" {
  description = "Private IP address inside the management subnet."
  value       = azurerm_network_interface.this.private_ip_address
}
