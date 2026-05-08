locals {
  env_short_map = {
    dev     = "d"
    staging = "s"
    prod    = "p"
  }

  env_short = lookup(local.env_short_map, var.environment, var.environment)

  # Environment-specific naming: <project>-<env-short>-<location>
  naming_prefix = lower(format("%s-%s-%s", var.project_name, local.env_short, var.location))

  network_resource_group_name = "${local.naming_prefix}-rg-network"
  vnet_name                   = "${local.naming_prefix}-vnet"
  app_vm_name                 = "${local.naming_prefix}-vm-app-01"
  app_vm_nic_name             = "${local.naming_prefix}-nic-app-01"
  app_vm_public_ip_name       = "${local.naming_prefix}-pip-app-01"
  mgmt_vm_name                = "${local.naming_prefix}-vm-mgmt-01"
  mgmt_vm_nic_name            = "${local.naming_prefix}-nic-mgmt-01"
  mgmt_vm_public_ip_name      = "${local.naming_prefix}-pip-mgmt-01"
  log_analytics_workspace_name = "${local.naming_prefix}-law"
  monitor_action_group_name    = "${local.naming_prefix}-ag-support"
  monitor_action_group_short   = "ag${local.env_short}support"
  recovery_vault_name          = "${local.naming_prefix}-rsv"
  backup_policy_name           = "${local.naming_prefix}-bp-vm-daily"
  container_group_name         = "${local.naming_prefix}-aci-app"

  common_tags = merge(
    var.extra_tags,
    {
      project       = var.project_name
      environment   = var.environment
      owner         = var.owner
      cost_center   = var.cost_center
      business_unit = var.business_unit
      managed_by    = "terraform"
      platform      = "azure"
      environment_tier = var.environment
    }
  )
}

module "network" {
  source = "../network"

  resource_group_name = local.network_resource_group_name
  location            = var.location
  vnet_name           = local.vnet_name
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
  container_subnet_cidr = var.container_subnet_cidr
  admin_source_cidrs  = var.admin_source_cidrs
  tags                = local.common_tags
}

module "application_vm" {
  source = "../linux-vm"

  resource_group_name  = module.network.resource_group_name
  location             = var.location
  subnet_id            = module.network.subnet_ids.application
  vm_name              = local.app_vm_name
  nic_name             = local.app_vm_nic_name
  public_ip_name       = local.app_vm_public_ip_name
  enable_public_ip     = var.enable_app_vm_public_ip
  vm_size              = var.vm_size
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key
  source_image_version = var.linux_source_image_version
  tags                 = local.common_tags
}

module "management_windows_vm" {
  count  = var.enable_windows_vm ? 1 : 0
  source = "../windows-vm"

  resource_group_name = module.network.resource_group_name
  location            = var.location
  subnet_id           = module.network.subnet_ids.management
  vm_name             = local.mgmt_vm_name
  nic_name            = local.mgmt_vm_nic_name
  public_ip_name      = local.mgmt_vm_public_ip_name
  enable_public_ip    = var.enable_management_vm_public_ip
  vm_size             = var.windows_vm_size
  admin_username      = var.windows_admin_username
  admin_password      = var.windows_admin_password
  source_image_version = var.windows_source_image_version
  tags                = local.common_tags
}

module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "../monitoring"

  resource_group_name          = module.network.resource_group_name
  location                     = var.location
  log_analytics_workspace_name = local.log_analytics_workspace_name
  log_retention_in_days        = var.log_retention_in_days
  action_group_name            = local.monitor_action_group_name
  action_group_short_name      = local.monitor_action_group_short
  action_group_email_receivers = var.monitor_action_group_email_receivers
  cpu_alert_threshold_percent  = var.cpu_alert_threshold_percent
  enable_synthetic_availability       = var.enable_synthetic_availability
  synthetic_check_url                 = var.synthetic_check_url
  synthetic_frequency_seconds         = var.synthetic_frequency_seconds
  synthetic_timeout_seconds           = var.synthetic_timeout_seconds
  synthetic_failed_location_count     = var.synthetic_failed_location_count
  synthetic_latency_threshold_ms      = var.synthetic_latency_threshold_ms
  synthetic_alert_severity_availability = var.synthetic_alert_severity_availability
  synthetic_alert_severity_latency    = var.synthetic_alert_severity_latency
  diagnostic_target_resource_ids = compact([
    module.network.virtual_network_id,
    module.application_vm.vm_id,
    try(module.management_windows_vm[0].vm_id, null)
  ])
  vm_resource_ids = compact([
    module.application_vm.vm_id,
    try(module.management_windows_vm[0].vm_id, null)
  ])
  tags = local.common_tags
}

module "container_workload" {
  count  = var.enable_container_workload ? 1 : 0
  source = "../container-workload"

  resource_group_name          = module.network.resource_group_name
  location                     = var.location
  container_group_name         = local.container_group_name
  subnet_id                    = module.network.subnet_ids.container
  container_image              = var.container_image
  container_cpu                = var.container_cpu
  container_memory_gb          = var.container_memory_gb
  log_analytics_workspace_id   = try(module.monitoring[0].log_analytics_workspace_id, null)
  log_analytics_workspace_key  = try(module.monitoring[0].log_analytics_primary_shared_key, null)
  tags                         = local.common_tags
}

module "incident_response" {
  count  = var.enable_backup ? 1 : 0
  source = "../incident-response"

  resource_group_name   = module.network.resource_group_name
  location              = var.location
  recovery_vault_name   = local.recovery_vault_name
  backup_policy_name    = local.backup_policy_name
  backup_time_utc       = var.backup_time_utc
  daily_retention_count = var.backup_daily_retention_count
  protected_vm_ids = compact([
    module.application_vm.vm_id,
    try(module.management_windows_vm[0].vm_id, null)
  ])
  tags = local.common_tags
}

data "azurerm_resource_group" "network" {
  name = module.network.resource_group_name
}

module "rbac" {
  count  = var.enable_rbac ? 1 : 0
  source = "../rbac"

  pipeline_principal_object_id           = var.pipeline_principal_object_id
  admin_user_object_id                   = var.admin_user_object_id
  monitoring_reader_principal_object_id  = var.monitoring_reader_principal_object_id
  resource_group_scope_id                = data.azurerm_resource_group.network.id
  linux_vm_scope_id                      = module.application_vm.vm_id
  windows_vm_scope_id                    = try(module.management_windows_vm[0].vm_id, null)
  log_analytics_workspace_scope_id       = try(module.monitoring[0].log_analytics_workspace_id, null)
}

module "governance" {
  count  = var.enable_governance_policy ? 1 : 0
  source = "../governance"

  scope_id                 = data.azurerm_resource_group.network.id
  name_prefix              = local.naming_prefix
  location                 = var.location
  required_tags            = var.governance_required_tags
  allowed_vm_sizes         = var.governance_allowed_vm_sizes
  enforce_public_ip_deny   = var.governance_enforce_public_ip_deny
}
