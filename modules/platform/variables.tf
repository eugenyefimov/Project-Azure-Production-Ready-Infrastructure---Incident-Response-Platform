variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_cidr" {
  type = list(string)
}

variable "subnet_cidrs" {
  type = object({
    management  = string
    application = string
    monitoring  = string
  })
}

variable "container_subnet_cidr" {
  description = "Optional subnet CIDR for private container workloads (ACI)."
  type        = string
  default     = null
}

variable "admin_source_cidrs" {
  type = list(string)
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_ssh_public_key" {
  type      = string
  sensitive = true
}

variable "enable_app_vm_public_ip" {
  type    = bool
  default = false
}

variable "enable_windows_vm" {
  type    = bool
  default = true
}

variable "windows_vm_size" {
  type = string
}

variable "windows_admin_username" {
  type = string
}

variable "windows_admin_password" {
  type      = string
  sensitive = true
}

variable "enable_management_vm_public_ip" {
  type    = bool
  default = false
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "log_retention_in_days" {
  type    = number
  default = 30
}

variable "cpu_alert_threshold_percent" {
  type    = number
  default = 85
}

variable "monitor_action_group_email_receivers" {
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "enable_backup" {
  type    = bool
  default = false
}

variable "backup_time_utc" {
  type    = string
  default = "23:00"
}

variable "backup_daily_retention_count" {
  type    = number
  default = 7
}

variable "owner" {
  type = string
}

variable "cost_center" {
  type = string
}

variable "business_unit" {
  type = string
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "enable_rbac" {
  description = "Whether to create RBAC role assignments."
  type        = bool
  default     = true
}

variable "pipeline_principal_object_id" {
  description = "Object ID of GitHub OIDC service principal."
  type        = string
  default     = null
}

variable "admin_user_object_id" {
  description = "Object ID of admin user/group for operational access."
  type        = string
  default     = null
}

variable "monitoring_reader_principal_object_id" {
  description = "Object ID for read-only monitoring user/group."
  type        = string
  default     = null
}

variable "enable_governance_policy" {
  description = "Whether to enforce governance policy assignments."
  type        = bool
  default     = true
}

variable "governance_required_tags" {
  description = "Mandatory tags enforced by policy."
  type        = list(string)
  default     = ["environment", "owner", "cost_center", "business_unit"]
}

variable "governance_allowed_vm_sizes" {
  description = "Allowed VM sizes enforced by policy."
  type        = list(string)
  default     = ["Standard_B2s", "Standard_D2s_v5", "Standard_D4s_v5"]
}

variable "governance_enforce_public_ip_deny" {
  description = "Whether policy should deny public IP resources."
  type        = bool
  default     = true
}

variable "enable_container_workload" {
  description = "Whether to deploy the cost-aware container workload (ACI)."
  type        = bool
  default     = false

  validation {
    condition     = var.enable_container_workload ? var.container_subnet_cidr != null : true
    error_message = "container_subnet_cidr must be set when enable_container_workload is true."
  }
}

variable "container_image" {
  description = "Container image for ACI workload."
  type        = string
  default     = "nginx:stable-alpine"
}

variable "container_cpu" {
  description = "CPU cores for the ACI workload."
  type        = number
  default     = 0.5
}

variable "container_memory_gb" {
  description = "Memory in GB for the ACI workload."
  type        = number
  default     = 1
}
