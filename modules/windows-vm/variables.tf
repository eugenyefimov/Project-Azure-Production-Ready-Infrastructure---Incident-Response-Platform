variable "resource_group_name" {
  description = "Resource group where VM resources are deployed."
  type        = string
}

variable "location" {
  description = "Azure region for the VM."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the VM NIC is attached."
  type        = string
}

variable "vm_name" {
  description = "Windows VM name."
  type        = string
}

variable "nic_name" {
  description = "Network interface name."
  type        = string
}

variable "public_ip_name" {
  description = "Public IP resource name."
  type        = string
}

variable "enable_public_ip" {
  description = "Whether to create and attach a public IP to the VM NIC."
  type        = bool
  default     = false
}

variable "vm_size" {
  description = "Azure VM SKU size."
  type        = string
}

variable "admin_username" {
  description = "Local administrator username for RDP login."
  type        = string
}

variable "admin_password" {
  description = "Local administrator password supplied securely by pipeline/secret store."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to VM-related resources."
  type        = map(string)
  default     = {}
}

variable "source_image_version" {
  description = "Windows image version pin to avoid non-deterministic rebuilds."
  type        = string
  default     = "20348.2849.250207"
}
