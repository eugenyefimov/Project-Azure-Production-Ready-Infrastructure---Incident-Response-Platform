variable "resource_group_name" {
  description = "Resource group where backup resources are deployed."
  type        = string
}

variable "location" {
  description = "Azure region for backup resources."
  type        = string
}

variable "recovery_vault_name" {
  description = "Recovery Services Vault name."
  type        = string
}

variable "backup_policy_name" {
  description = "VM backup policy name."
  type        = string
}

variable "backup_time_utc" {
  description = "Daily backup time in UTC (HH:MM)."
  type        = string
  default     = "23:00"
}

variable "daily_retention_count" {
  description = "Number of daily recovery points to keep."
  type        = number
  default     = 7
}

variable "protected_vm_ids" {
  description = "VM resource IDs that should be protected by backup."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to backup resources."
  type        = map(string)
  default     = {}
}
