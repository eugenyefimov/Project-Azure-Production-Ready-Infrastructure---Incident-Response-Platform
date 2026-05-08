variable "subscription_id" {
  description = "Azure subscription ID for this environment."
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID for this environment."
  type        = string
}

variable "project_name" {
  description = "Short project identifier used in naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)."
  type        = string
}

variable "location" {
  description = "Primary Azure region for this environment."
  type        = string
}

variable "vnet_cidr" {
  description = "Address space for the environment virtual network."
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
  description = "Optional delegated subnet CIDR for private ACI workload."
  type        = string
  default     = null
}

variable "admin_source_cidrs" {
  description = "Trusted source CIDRs for management access (SSH/RDP)."
  type        = list(string)
}

variable "enable_app_vm_public_ip" {
  description = "Whether the application Linux VM should have a public IP."
  type        = bool
  default     = true
}

variable "enable_windows_vm" {
  description = "Whether to deploy the Windows management VM."
  type        = bool
  default     = true
}

variable "vm_size" {
  description = "Size of the Ubuntu application VM."
  type        = string
}

variable "admin_username" {
  description = "Admin username used for Linux VM SSH access."
  type        = string
}

variable "admin_ssh_public_key" {
  description = "SSH public key for Linux VM key-based authentication."
  type        = string
  sensitive   = true
}

variable "windows_vm_size" {
  description = "Size of the Windows management VM."
  type        = string
}

variable "windows_admin_username" {
  description = "Admin username for Windows VM RDP access."
  type        = string
}

variable "windows_admin_password" {
  description = "Admin password for Windows VM (inject securely from secrets)."
  type        = string
  sensitive   = true
}

variable "enable_management_vm_public_ip" {
  description = "Whether the management Windows VM should have a public IP."
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Whether to deploy monitoring resources and alerts."
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "cpu_alert_threshold_percent" {
  description = "CPU alert threshold percentage for VM high CPU alert."
  type        = number
  default     = 85
}

variable "monitor_action_group_email_receivers" {
  description = "Optional email receivers for Azure Monitor action group."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
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
  description = "Whether to deploy backup vault, policy, and protection."
  type        = bool
  default     = false
}

variable "backup_time_utc" {
  description = "Daily VM backup time in UTC (HH:MM)."
  type        = string
  default     = "23:00"
}

variable "backup_daily_retention_count" {
  description = "Number of daily restore points to keep."
  type        = number
  default     = 7
}

variable "owner" {
  description = "Team or person responsible for this environment."
  type        = string
}

variable "cost_center" {
  description = "Cost center code used for chargeback/showback."
  type        = string
}

variable "business_unit" {
  description = "Business unit owning the platform."
  type        = string
}

variable "extra_tags" {
  description = "Additional custom tags merged into standard tags."
  type        = map(string)
  default     = {}
}

variable "enable_rbac" {
  description = "Whether to create RBAC assignments in this environment."
  type        = bool
  default     = true
}

variable "pipeline_principal_object_id" {
  description = "Object ID of the CI/CD service principal (GitHub OIDC)."
  type        = string
  default     = null
}

variable "admin_user_object_id" {
  description = "Object ID of admin user/group for operational access."
  type        = string
  default     = null
}

variable "monitoring_reader_principal_object_id" {
  description = "Object ID of read-only monitoring user/group."
  type        = string
  default     = null
}

variable "enable_governance_policy" {
  description = "Whether Azure Policy governance assignments are enforced."
  type        = bool
  default     = true
}

variable "governance_required_tags" {
  description = "Tags required by policy."
  type        = list(string)
  default     = ["environment", "owner", "cost_center", "business_unit"]
}

variable "governance_allowed_vm_sizes" {
  description = "Allowed VM sizes for this environment."
  type        = list(string)
  default     = ["Standard_B1s", "Standard_B2s", "Standard_D2s_v5"]
}

variable "governance_enforce_public_ip_deny" {
  description = "Whether policy denies public IP resources."
  type        = bool
  default     = false
}

variable "enable_container_workload" {
  description = "Whether to deploy a minimal cost-aware ACI workload."
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Container image for ACI workload."
  type        = string
  default     = "nginx:stable-alpine"
}

variable "container_cpu" {
  description = "CPU allocation for ACI workload."
  type        = number
  default     = 0.5
}

variable "container_memory_gb" {
  description = "Memory allocation in GB for ACI workload."
  type        = number
  default     = 1
}
