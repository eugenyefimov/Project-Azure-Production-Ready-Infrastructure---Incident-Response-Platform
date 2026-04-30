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
  description = "Linux VM name."
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
  description = "Admin username for SSH login."
  type        = string
}

variable "admin_ssh_public_key" {
  description = "SSH public key content used for key-based authentication."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to VM-related resources."
  type        = map(string)
  default     = {}
}
