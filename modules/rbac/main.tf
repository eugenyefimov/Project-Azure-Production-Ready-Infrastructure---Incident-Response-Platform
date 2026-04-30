locals {
  # Least-privilege baseline:
  # - Pipeline: Contributor at resource-group scope only (never subscription Owner).
  # - Admin: Reader at RG + VM admin login roles at VM scope.
  # - Monitoring reader: Monitoring Reader scoped to Log Analytics workspace.
  role_assignments = {
    pipeline_contributor = {
      enabled              = var.pipeline_principal_object_id != null
      scope                = var.resource_group_scope_id
      role_definition_name = "Contributor"
      principal_id         = var.pipeline_principal_object_id
    }
    admin_reader_rg = {
      enabled              = var.admin_user_object_id != null
      scope                = var.resource_group_scope_id
      role_definition_name = "Reader"
      principal_id         = var.admin_user_object_id
    }
    admin_linux_vm_login = {
      enabled              = var.admin_user_object_id != null
      scope                = var.linux_vm_scope_id
      role_definition_name = "Virtual Machine Administrator Login"
      principal_id         = var.admin_user_object_id
    }
    admin_windows_vm_login = {
      enabled              = var.admin_user_object_id != null && var.windows_vm_scope_id != null
      scope                = var.windows_vm_scope_id
      role_definition_name = "Virtual Machine Administrator Login"
      principal_id         = var.admin_user_object_id
    }
    monitoring_reader_law = {
      enabled              = var.monitoring_reader_principal_object_id != null && var.log_analytics_workspace_scope_id != null
      scope                = var.log_analytics_workspace_scope_id
      role_definition_name = "Monitoring Reader"
      principal_id         = var.monitoring_reader_principal_object_id
    }
  }
}

resource "azurerm_role_assignment" "this" {
  for_each = { for k, v in local.role_assignments : k => v if v.enabled }

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}
