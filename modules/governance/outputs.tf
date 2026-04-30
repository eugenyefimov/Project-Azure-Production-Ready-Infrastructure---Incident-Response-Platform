output "policy_definition_ids" {
  description = "Policy definition IDs created by governance module."
  value = {
    require_tags     = azurerm_policy_definition.require_tags.id
    deny_public_ip   = azurerm_policy_definition.deny_public_ip.id
    allowed_vm_sizes = azurerm_policy_definition.allowed_vm_sizes.id
  }
}

output "policy_assignment_ids" {
  description = "Policy assignment IDs enforced at scope."
  value = {
    require_tags     = azurerm_resource_group_policy_assignment.require_tags.id
    deny_public_ip   = try(azurerm_resource_group_policy_assignment.deny_public_ip[0].id, null)
    allowed_vm_sizes = azurerm_resource_group_policy_assignment.allowed_vm_sizes.id
  }
}
