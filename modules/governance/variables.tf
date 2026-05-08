variable "scope_id" {
  description = "Scope where policy assignments are enforced (resource group or subscription ID)."
  type        = string
}

variable "location" {
  description = "Azure region used for policy assignment identity metadata."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used to keep policy definition names unique across environments and projects."
  type        = string
}

variable "required_tags" {
  description = "Tags that must exist on resources."
  type        = list(string)
  default     = ["environment", "owner", "cost_center", "business_unit"]

  validation {
    condition     = length(var.required_tags) > 0
    error_message = "required_tags must include at least one tag key."
  }
}

variable "allowed_vm_sizes" {
  description = "Allowed VM SKU names for this scope."
  type        = list(string)
  default     = ["Standard_B2s", "Standard_D2s_v5", "Standard_D4s_v5"]

  validation {
    condition     = length(var.allowed_vm_sizes) > 0
    error_message = "allowed_vm_sizes must include at least one VM size."
  }
}

variable "enforce_public_ip_deny" {
  description = "Whether to deny creation of public IP resources."
  type        = bool
  default     = true
}
