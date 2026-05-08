variable "pipeline_principal_object_id" {
  description = "Object ID of the GitHub OIDC service principal."
  type        = string
  default     = null

  validation {
    condition     = var.pipeline_principal_object_id == null || can(regex("^[0-9a-fA-F-]{36}$", var.pipeline_principal_object_id))
    error_message = "pipeline_principal_object_id must be null or a valid GUID."
  }
}

variable "admin_user_object_id" {
  description = "Object ID of the admin Entra ID user/group."
  type        = string
  default     = null

  validation {
    condition     = var.admin_user_object_id == null || can(regex("^[0-9a-fA-F-]{36}$", var.admin_user_object_id))
    error_message = "admin_user_object_id must be null or a valid GUID."
  }
}

variable "monitoring_reader_principal_object_id" {
  description = "Object ID for read-only monitoring access user/group."
  type        = string
  default     = null

  validation {
    condition     = var.monitoring_reader_principal_object_id == null || can(regex("^[0-9a-fA-F-]{36}$", var.monitoring_reader_principal_object_id))
    error_message = "monitoring_reader_principal_object_id must be null or a valid GUID."
  }
}

variable "resource_group_scope_id" {
  description = "Resource group scope ID for platform RBAC assignments."
  type        = string
}

variable "linux_vm_scope_id" {
  description = "Linux VM resource ID for scoped admin login assignment."
  type        = string
}

variable "windows_vm_scope_id" {
  description = "Windows VM resource ID for scoped admin login assignment."
  type        = string
  default     = null
}

variable "log_analytics_workspace_scope_id" {
  description = "Log Analytics workspace resource ID for monitoring reader scope."
  type        = string
  default     = null
}
