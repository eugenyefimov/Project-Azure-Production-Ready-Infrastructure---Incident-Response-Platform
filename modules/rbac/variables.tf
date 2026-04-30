variable "pipeline_principal_object_id" {
  description = "Object ID of the GitHub OIDC service principal."
  type        = string
  default     = null
}

variable "admin_user_object_id" {
  description = "Object ID of the admin Entra ID user/group."
  type        = string
  default     = null
}

variable "monitoring_reader_principal_object_id" {
  description = "Object ID for read-only monitoring access user/group."
  type        = string
  default     = null
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
