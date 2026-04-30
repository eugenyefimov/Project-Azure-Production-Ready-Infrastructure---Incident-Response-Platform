variable "resource_group_name" {
  description = "Resource group name for networking resources."
  type        = string
}

variable "location" {
  description = "Azure region for networking resources."
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name."
  type        = string
}

variable "vnet_cidr" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "subnet_cidrs" {
  description = "CIDR blocks for management, application, and monitoring subnets."
  type = object({
    management = string
    application = string
    monitoring = string
  })
}

variable "container_subnet_cidr" {
  description = "Optional CIDR block for delegated container subnet (ACI private networking)."
  type        = string
  default     = null
}

variable "admin_source_cidrs" {
  description = "Trusted admin source CIDRs allowed to access management subnet."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to all networking resources."
  type        = map(string)
  default     = {}
}
