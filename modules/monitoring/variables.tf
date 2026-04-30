variable "resource_group_name" {
  description = "Resource group where monitoring resources are deployed."
  type        = string
}

variable "location" {
  description = "Azure region for monitoring resources."
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "Retention period for logs."
  type        = number
  default     = 30
}

variable "action_group_name" {
  description = "Azure Monitor action group name."
  type        = string
}

variable "action_group_short_name" {
  description = "Short name for action group (<=12 chars)."
  type        = string
}

variable "action_group_email_receivers" {
  description = "Placeholder email receivers for alert notifications."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "diagnostic_target_resource_ids" {
  description = "Resource IDs where diagnostic settings should be enabled."
  type        = list(string)
  default     = []
}

variable "vm_resource_ids" {
  description = "Virtual machine resource IDs monitored for availability and CPU."
  type        = list(string)
}

variable "cpu_alert_threshold_percent" {
  description = "CPU alert threshold percentage."
  type        = number
  default     = 85
}

variable "tags" {
  description = "Tags applied to monitoring resources."
  type        = map(string)
  default     = {}
}
