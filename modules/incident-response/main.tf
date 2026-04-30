resource "azurerm_recovery_services_vault" "this" {
  name                = var.recovery_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = true
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = var.backup_policy_name
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  timezone            = "UTC"

  # Cost-conscious baseline: one backup per day with short daily retention.
  backup {
    frequency = "Daily"
    time      = var.backup_time_utc
  }

  retention_daily {
    count = var.daily_retention_count
  }
}

resource "azurerm_backup_protected_vm" "protected" {
  for_each = { for id in var.protected_vm_ids : id => id }

  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  source_vm_id        = each.value
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}
