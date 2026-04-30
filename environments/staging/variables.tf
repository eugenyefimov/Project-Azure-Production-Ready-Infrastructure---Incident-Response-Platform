variable "subscription_id" { type = string }
variable "tenant_id" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "location" { type = string }
variable "vnet_cidr" { type = list(string) }
variable "subnet_cidrs" {
  type = object({
    management  = string
    application = string
    monitoring  = string
  })
}
variable "container_subnet_cidr" {
  type    = string
  default = null
}
variable "admin_source_cidrs" { type = list(string) }
variable "enable_app_vm_public_ip" { type = bool }
variable "enable_windows_vm" { type = bool }
variable "vm_size" { type = string }
variable "admin_username" { type = string }
variable "admin_ssh_public_key" {
  type      = string
  sensitive = true
}
variable "windows_vm_size" { type = string }
variable "windows_admin_username" { type = string }
variable "windows_admin_password" {
  type      = string
  sensitive = true
}
variable "enable_management_vm_public_ip" { type = bool }
variable "enable_monitoring" { type = bool }
variable "log_retention_in_days" { type = number }
variable "cpu_alert_threshold_percent" { type = number }
variable "monitor_action_group_email_receivers" {
  type = list(object({
    name          = string
    email_address = string
  }))
}
variable "enable_backup" { type = bool }
variable "backup_time_utc" { type = string }
variable "backup_daily_retention_count" { type = number }
variable "owner" { type = string }
variable "cost_center" { type = string }
variable "business_unit" { type = string }
variable "extra_tags" { type = map(string) }
variable "enable_rbac" {
  type    = bool
  default = true
}
variable "pipeline_principal_object_id" {
  type    = string
  default = null
}
variable "admin_user_object_id" {
  type    = string
  default = null
}
variable "monitoring_reader_principal_object_id" {
  type    = string
  default = null
}
variable "enable_governance_policy" {
  type    = bool
  default = true
}
variable "governance_required_tags" {
  type    = list(string)
  default = ["environment", "owner", "cost_center", "business_unit"]
}
variable "governance_allowed_vm_sizes" {
  type    = list(string)
  default = ["Standard_B2s", "Standard_D2s_v5", "Standard_D4s_v5"]
}
variable "governance_enforce_public_ip_deny" {
  type    = bool
  default = true
}
variable "enable_container_workload" {
  type    = bool
  default = false
}
variable "container_image" {
  type    = string
  default = "nginx:stable-alpine"
}
variable "container_cpu" {
  type    = number
  default = 0.5
}
variable "container_memory_gb" {
  type    = number
  default = 1
}
