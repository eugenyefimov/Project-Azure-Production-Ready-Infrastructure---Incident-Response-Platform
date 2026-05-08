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

variable "enable_synthetic_availability" {
  description = "Whether to deploy Application Insights web test monitoring for service-level availability."
  type        = bool
  default     = false
}

variable "synthetic_check_url" {
  description = "Public HTTP/HTTPS endpoint checked by synthetic availability tests (for example, the Nginx health endpoint)."
  type        = string
  default     = null

  validation {
    condition     = var.synthetic_check_url == null || can(regex("^https?://", var.synthetic_check_url))
    error_message = "synthetic_check_url must be null or start with http:// or https://."
  }
}

variable "synthetic_frequency_seconds" {
  description = "Frequency in seconds for synthetic web tests."
  type        = number
  default     = 300

  validation {
    condition     = contains([300, 600, 900], var.synthetic_frequency_seconds)
    error_message = "synthetic_frequency_seconds must be one of 300, 600, or 900."
  }
}

variable "synthetic_timeout_seconds" {
  description = "Timeout in seconds for each synthetic test attempt."
  type        = number
  default     = 30

  validation {
    condition     = var.synthetic_timeout_seconds >= 10 && var.synthetic_timeout_seconds <= 120
    error_message = "synthetic_timeout_seconds must be between 10 and 120."
  }
}

variable "synthetic_failed_location_count" {
  description = "Number of test locations that must fail before firing the availability alert."
  type        = number
  default     = 2

  validation {
    condition     = var.synthetic_failed_location_count >= 1 && var.synthetic_failed_location_count <= 5
    error_message = "synthetic_failed_location_count must be between 1 and 5."
  }
}

variable "synthetic_latency_threshold_ms" {
  description = "Average latency threshold in milliseconds for synthetic checks."
  type        = number
  default     = 2000

  validation {
    condition     = var.synthetic_latency_threshold_ms >= 500 && var.synthetic_latency_threshold_ms <= 10000
    error_message = "synthetic_latency_threshold_ms must be between 500 and 10000."
  }
}

variable "synthetic_alert_severity_availability" {
  description = "Alert severity for hard service availability failures (0=critical, 4=verbose)."
  type        = number
  default     = 1

  validation {
    condition     = var.synthetic_alert_severity_availability >= 0 && var.synthetic_alert_severity_availability <= 4
    error_message = "synthetic_alert_severity_availability must be between 0 and 4."
  }
}

variable "synthetic_alert_severity_latency" {
  description = "Alert severity for sustained latency degradation from synthetic checks (0=critical, 4=verbose)."
  type        = number
  default     = 2

  validation {
    condition     = var.synthetic_alert_severity_latency >= 0 && var.synthetic_alert_severity_latency <= 4
    error_message = "synthetic_alert_severity_latency must be between 0 and 4."
  }
}

variable "tags" {
  description = "Tags applied to monitoring resources."
  type        = map(string)
  default     = {}
}
