output "recovery_vault_id" {
  description = "Recovery Services Vault ID."
  value       = azurerm_recovery_services_vault.this.id
}

output "recovery_vault_name" {
  description = "Recovery Services Vault name."
  value       = azurerm_recovery_services_vault.this.name
}

output "backup_policy_id" {
  description = "Backup policy ID for protected VMs."
  value       = azurerm_backup_policy_vm.daily.id
}
