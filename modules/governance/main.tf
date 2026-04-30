resource "azurerm_policy_definition" "require_tags" {
  name         = "pd-require-tags-platform"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require mandatory tags on resources"
  description  = "Denies resource create/update when mandatory tags are missing."

  parameters = jsonencode({
    requiredTags = {
      type = "Array"
      metadata = {
        displayName = "Required tags"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field     = "type"
          notEquals = "Microsoft.Resources/subscriptions/resourceGroups"
        },
        {
          count = {
            value = "[parameters('requiredTags')]"
            name  = "requiredTag"
            where = {
              field  = "[concat('tags[', current('requiredTag'), ']')]"
              exists = "false"
            }
          }
          greater = 0
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "pd-deny-public-ip-platform"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny public IP resources"
  description  = "Denies creation of Microsoft.Network/publicIPAddresses resources."

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "allowed_vm_sizes" {
  name         = "pd-allowed-vm-sizes-platform"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allow only approved VM sizes"
  description  = "Denies VM deployment when SKU is outside approved list."

  parameters = jsonencode({
    allowedVmSizes = {
      type = "Array"
      metadata = {
        displayName = "Allowed VM sizes"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Compute/virtualMachines"
        },
        {
          not = {
            field = "Microsoft.Compute/virtualMachines/sku.name"
            in    = "[parameters('allowedVmSizes')]"
          }
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "require_tags" {
  name                 = "pa-require-tags"
  resource_group_id    = var.scope_id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  display_name         = "Enforce required tags"
  location             = var.location
  parameters           = jsonencode({ requiredTags = { value = var.required_tags } })
}

resource "azurerm_resource_group_policy_assignment" "deny_public_ip" {
  count                = var.enforce_public_ip_deny ? 1 : 0
  name                 = "pa-deny-public-ip"
  resource_group_id    = var.scope_id
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  display_name         = "Deny public IP usage"
  location             = var.location
}

resource "azurerm_resource_group_policy_assignment" "allowed_vm_sizes" {
  name                 = "pa-allowed-vm-sizes"
  resource_group_id    = var.scope_id
  policy_definition_id = azurerm_policy_definition.allowed_vm_sizes.id
  display_name         = "Enforce allowed VM sizes"
  location             = var.location
  parameters           = jsonencode({ allowedVmSizes = { value = var.allowed_vm_sizes } })
}
