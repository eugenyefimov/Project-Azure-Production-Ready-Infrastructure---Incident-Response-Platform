output "naming_prefix" {
  value = local.naming_prefix
}

output "common_tags" {
  value = local.common_tags
}

output "network_resource_group_name" {
  value = module.network.resource_group_name
}

output "virtual_network_name" {
  value = module.network.virtual_network_name
}

output "virtual_network_id" {
  value = module.network.virtual_network_id
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

output "nsg_ids" {
  value = module.network.nsg_ids
}

output "application_vm_name" {
  value = module.application_vm.vm_name
}

output "application_vm_id" {
  value = module.application_vm.vm_id
}

output "application_vm_private_ip" {
  value = module.application_vm.private_ip_address
}

output "application_vm_public_ip" {
  value = module.application_vm.public_ip_address
}

output "management_windows_vm_name" {
  value = try(module.management_windows_vm[0].vm_name, null)
}

output "management_windows_vm_id" {
  value = try(module.management_windows_vm[0].vm_id, null)
}

output "management_windows_vm_private_ip" {
  value = try(module.management_windows_vm[0].private_ip_address, null)
}

output "management_windows_vm_public_ip" {
  value = try(module.management_windows_vm[0].public_ip_address, null)
}

output "container_group_name" {
  value = try(module.container_workload[0].container_group_name, null)
}

output "container_group_id" {
  value = try(module.container_workload[0].container_group_id, null)
}

output "container_private_ip" {
  value = try(module.container_workload[0].container_private_ip, null)
}

output "log_analytics_workspace_name" {
  value = try(module.monitoring[0].log_analytics_workspace_name, null)
}

output "log_analytics_workspace_id" {
  value = try(module.monitoring[0].log_analytics_workspace_id, null)
}

output "monitor_action_group_id" {
  value = try(module.monitoring[0].action_group_id, null)
}

output "alert_vm_down_id" {
  value = try(module.monitoring[0].vm_down_alert_id, null)
}

output "alert_high_cpu_id" {
  value = try(module.monitoring[0].high_cpu_alert_id, null)
}

output "recovery_vault_name" {
  value = try(module.incident_response[0].recovery_vault_name, null)
}

output "recovery_vault_id" {
  value = try(module.incident_response[0].recovery_vault_id, null)
}

output "backup_policy_id" {
  value = try(module.incident_response[0].backup_policy_id, null)
}

output "rbac_role_assignment_ids" {
  value = try(module.rbac[0].role_assignment_ids, {})
}

output "governance_policy_definition_ids" {
  value = try(module.governance[0].policy_definition_ids, {})
}

output "governance_policy_assignment_ids" {
  value = try(module.governance[0].policy_assignment_ids, {})
}
