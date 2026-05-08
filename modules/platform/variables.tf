variable "project_name" {
  type = string

  validation {
    condition     = length(trim(var.project_name)) >= 3 && can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must be at least 3 chars and use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
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

  validation {
    condition     = var.container_subnet_cidr == null || can(cidrnetmask(var.container_subnet_cidr))
    error_message = "container_subnet_cidr must be null or a valid CIDR."
  }
}

variable "admin_source_cidrs" {
  type = list(string)

  validation {
    condition     = length(var.admin_source_cidrs) > 0 && alltrue([for cidr in var.admin_source_cidrs : can(cidrnetmask(cidr))])
    error_message = "admin_source_cidrs must contain at least one valid CIDR."
  }
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
  default = false
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

  validation {
    condition     = var.log_retention_in_days >= 7 && var.log_retention_in_days <= 730
    error_message = "log_retention_in_days must be between 7 and 730."
  }
}

variable "cpu_alert_threshold_percent" {
  type    = number
  default = 85

  validation {
    condition     = var.cpu_alert_threshold_percent >= 50 && var.cpu_alert_threshold_percent <= 99
    error_message = "cpu_alert_threshold_percent must be between 50 and 99."
  }
}

variable "monitor_action_group_email_receivers" {
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "enable_synthetic_availability" {
  description = "Whether to enable Application Insights synthetic checks for the service endpoint."
  type        = bool
  default     = false
}

variable "synthetic_check_url" {
  description = "Public URL checked by the synthetic web test."
  type        = string
  default     = null

  validation {
    condition     = var.synthetic_check_url == null || can(regex("^https?://", var.synthetic_check_url))
    error_message = "synthetic_check_url must be null or start with http:// or https://."
  }
}

variable "synthetic_frequency_seconds" {
  description = "Synthetic check frequency in seconds."
  type        = number
  default     = 300

  validation {
    condition     = contains([300, 600, 900], var.synthetic_frequency_seconds)
    error_message = "synthetic_frequency_seconds must be one of 300, 600, or 900."
  }
}

variable "synthetic_timeout_seconds" {
  description = "Synthetic check timeout in seconds."
  type        = number
  default     = 30

  validation {
    condition     = var.synthetic_timeout_seconds >= 10 && var.synthetic_timeout_seconds <= 120
    error_message = "synthetic_timeout_seconds must be between 10 and 120."
  }
}

variable "synthetic_failed_location_count" {
  description = "How many probe locations must fail before availability alerting triggers."
  type        = number
  default     = 2

  validation {
    condition     = var.synthetic_failed_location_count >= 1 && var.synthetic_failed_location_count <= 5
    error_message = "synthetic_failed_location_count must be between 1 and 5."
  }
}

variable "synthetic_latency_threshold_ms" {
  description = "Synthetic latency threshold in milliseconds."
  type        = number
  default     = 2000

  validation {
    condition     = var.synthetic_latency_threshold_ms >= 500 && var.synthetic_latency_threshold_ms <= 10000
    error_message = "synthetic_latency_threshold_ms must be between 500 and 10000."
  }
}

variable "synthetic_alert_severity_availability" {
  description = "Severity for synthetic availability alerts (0-4)."
  type        = number
  default     = 1

  validation {
    condition     = var.synthetic_alert_severity_availability >= 0 && var.synthetic_alert_severity_availability <= 4
    error_message = "synthetic_alert_severity_availability must be between 0 and 4."
  }
}

variable "synthetic_alert_severity_latency" {
  description = "Severity for synthetic latency alerts (0-4)."
  type        = number
  default     = 2

  validation {
    condition     = var.synthetic_alert_severity_latency >= 0 && var.synthetic_alert_severity_latency <= 4
    error_message = "synthetic_alert_severity_latency must be between 0 and 4."
  }
}

variable "enable_backup" {
  type    = bool
  default = false
}

variable "backup_time_utc" {
  type    = string
  default = "23:00"

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.backup_time_utc))
    error_message = "backup_time_utc must be in HH:MM 24-hour UTC format."
  }
}

variable "backup_daily_retention_count" {
  type    = number
  default = 7

  validation {
    condition     = var.backup_daily_retention_count >= 7 && var.backup_daily_retention_count <= 365
    error_message = "backup_daily_retention_count must be between 7 and 365."
  }
}

variable "owner" {
  type = string

  validation {
    condition     = length(trim(var.owner)) > 0
    error_message = "owner must not be empty."
  }
}

variable "cost_center" {
  type = string

  validation {
    condition     = length(trim(var.cost_center)) > 0
    error_message = "cost_center must not be empty."
  }
}

variable "business_unit" {
  type = string

  validation {
    condition     = length(trim(var.business_unit)) > 0
    error_message = "business_unit must not be empty."
  }
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

  validation {
    condition     = length(var.governance_required_tags) > 0
    error_message = "governance_required_tags must include at least one tag key."
  }
}

variable "governance_allowed_vm_sizes" {
  description = "Allowed VM sizes enforced by policy."
  type        = list(string)
  default     = ["Standard_B2s", "Standard_D2s_v5", "Standard_D4s_v5"]

  validation {
    condition     = length(var.governance_allowed_vm_sizes) > 0
    error_message = "governance_allowed_vm_sizes must include at least one VM size."
  }
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

  validation {
    condition     = length(trim(var.container_image)) > 0
    error_message = "container_image must not be empty."
  }
}

variable "container_cpu" {
  description = "CPU cores for the ACI workload."
  type        = number
  default     = 0.5

  validation {
    condition     = var.container_cpu >= 0.5 && var.container_cpu <= 4
    error_message = "container_cpu must be between 0.5 and 4."
  }
}

variable "container_memory_gb" {
  description = "Memory in GB for the ACI workload."
  type        = number
  default     = 1

  validation {
    condition     = var.container_memory_gb >= 1 && var.container_memory_gb <= 16
    error_message = "container_memory_gb must be between 1 and 16."
  }
}

variable "linux_source_image_version" {
  description = "Pinned source image version for Linux VM to reduce drift from automatic latest image updates."
  type        = string
  default     = "22.04.202502130"
}

variable "windows_source_image_version" {
  description = "Pinned source image version for Windows VM to reduce drift from automatic latest image updates."
  type        = string
  default     = "20348.2849.250207"
}
