variable "subscription_id" {
  description = "Azure subscription ID used by this environment."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used by this environment."
  type        = string
}

variable "project_name" {
  description = "Short lowercase project identifier used in naming."
  type        = string
}

variable "environment" {
  description = "Environment name. Must remain 'prod' for this root."
  type        = string

  validation {
    condition     = var.environment == "prod"
    error_message = "environment must be set to prod in the prod root."
  }
}

variable "location" {
  description = "Primary Azure region for production resources."
  type        = string
}

variable "vnet_cidr" {
  description = "Address spaces for production virtual network."
  type        = list(string)
}

variable "subnet_cidrs" {
  description = "CIDR ranges for management, application, and monitoring subnets."
  type = object({
    management  = string
    application = string
    monitoring  = string
  })
}

variable "container_subnet_cidr" {
  description = "Optional delegated subnet CIDR for ACI."
  type        = string
  default     = null
}

variable "admin_source_cidrs" {
  description = "Trusted source CIDRs allowed for SSH/RDP administrative access."
  type        = list(string)
}

variable "enable_app_vm_public_ip" {
  description = "Whether to create a public IP for the application VM."
  type        = bool
}

variable "enable_windows_vm" {
  description = "Whether to deploy the management Windows VM."
  type        = bool
}

variable "vm_size" {
  description = "SKU for the Linux application VM."
  type        = string
}

variable "admin_username" {
  description = "Linux VM admin username."
  type        = string
}

variable "admin_ssh_public_key" {
  description = "SSH public key for Linux VM authentication."
  type        = string
  sensitive   = true
}

variable "windows_vm_size" {
  description = "SKU for the Windows management VM."
  type        = string
}

variable "windows_admin_username" {
  description = "Windows VM local administrator username."
  type        = string
}

variable "windows_admin_password" {
  description = "Windows VM administrator password from secure secret source."
  type        = string
  sensitive   = true
}

variable "enable_management_vm_public_ip" {
  description = "Whether to create a public IP for the management VM."
  type        = bool
}

variable "enable_monitoring" {
  description = "Whether to deploy monitoring resources."
  type        = bool
}

variable "log_retention_in_days" {
  description = "Retention days for Log Analytics."
  type        = number
}

variable "cpu_alert_threshold_percent" {
  description = "Threshold percent for high CPU alerts."
  type        = number
}

variable "monitor_action_group_email_receivers" {
  description = "Email receivers for Azure Monitor action group notifications."
  type = list(object({
    name          = string
    email_address = string
  }))
}

variable "enable_synthetic_availability" {
  description = "Enable Application Insights synthetic endpoint checks."
  type        = bool
  default     = false
}

variable "synthetic_check_url" {
  description = "Public URL used by synthetic endpoint checks."
  type        = string
  default     = null
}

variable "synthetic_frequency_seconds" {
  description = "Synthetic check frequency in seconds."
  type        = number
  default     = 300
}

variable "synthetic_timeout_seconds" {
  description = "Synthetic check timeout in seconds."
  type        = number
  default     = 30
}

variable "synthetic_failed_location_count" {
  description = "Probe locations that must fail before availability alert fires."
  type        = number
  default     = 2
}

variable "synthetic_latency_threshold_ms" {
  description = "Latency threshold in milliseconds for synthetic checks."
  type        = number
  default     = 2000
}

variable "synthetic_alert_severity_availability" {
  description = "Severity for synthetic availability alerts."
  type        = number
  default     = 1
}

variable "synthetic_alert_severity_latency" {
  description = "Severity for synthetic latency alerts."
  type        = number
  default     = 2
}

variable "enable_backup" {
  description = "Whether to deploy backup resources."
  type        = bool
}

variable "backup_time_utc" {
  description = "Daily backup time in UTC HH:MM format."
  type        = string
}

variable "backup_daily_retention_count" {
  description = "Number of daily restore points retained."
  type        = number
}

variable "owner" {
  description = "Ownership tag value."
  type        = string
}

variable "cost_center" {
  description = "Cost center tag value."
  type        = string
}

variable "business_unit" {
  description = "Business unit tag value."
  type        = string
}

variable "extra_tags" {
  description = "Additional custom tags merged into baseline tags."
  type        = map(string)
}

variable "enable_rbac" {
  description = "Whether to deploy RBAC role assignments."
  type        = bool
  default     = true
}

variable "pipeline_principal_object_id" {
  description = "Object ID of the CI/CD principal."
  type        = string
  default     = null
}

variable "admin_user_object_id" {
  description = "Object ID of operations admin user/group."
  type        = string
  default     = null
}

variable "monitoring_reader_principal_object_id" {
  description = "Object ID for read-only monitoring access."
  type        = string
  default     = null
}

variable "enable_governance_policy" {
  description = "Whether to assign governance policy controls."
  type        = bool
  default     = true
}

variable "governance_required_tags" {
  description = "Tag keys required by policy."
  type        = list(string)
  default     = ["environment", "owner", "cost_center", "business_unit"]
}

variable "governance_allowed_vm_sizes" {
  description = "Allowed VM sizes enforced by policy."
  type        = list(string)
  default     = ["Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5"]
}

variable "governance_enforce_public_ip_deny" {
  description = "Whether policy denies creation of public IP resources."
  type        = bool
  default     = true
}

variable "enable_container_workload" {
  description = "Whether to deploy the optional ACI workload."
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Container image for optional ACI workload."
  type        = string
  default     = "nginx:stable-alpine"
}

variable "container_cpu" {
  description = "CPU cores for optional ACI workload."
  type        = number
  default     = 0.5
}

variable "container_memory_gb" {
  description = "Memory in GB for optional ACI workload."
  type        = number
  default     = 1
}
