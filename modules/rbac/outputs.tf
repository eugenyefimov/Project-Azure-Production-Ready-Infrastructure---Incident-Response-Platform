output "role_assignment_ids" {
  description = "RBAC role assignment IDs created by this module."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}
