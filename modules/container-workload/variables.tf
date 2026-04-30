variable "resource_group_name" {
  description = "Resource group name where the container group is deployed."
  type        = string
}

variable "location" {
  description = "Azure region for the container group."
  type        = string
}

variable "container_group_name" {
  description = "Name of the Azure Container Instance group."
  type        = string
}

variable "subnet_id" {
  description = "Delegated subnet ID used for private container networking."
  type        = string
}

variable "container_name" {
  description = "Container name inside the ACI group."
  type        = string
  default     = "web"
}

variable "container_image" {
  description = "Container image reference."
  type        = string
  default     = "nginx:stable-alpine"
}

variable "container_cpu" {
  description = "CPU cores allocated to the container."
  type        = number
  default     = 0.5
}

variable "container_memory_gb" {
  description = "Memory (GB) allocated to the container."
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Internal service port exposed by the container."
  type        = number
  default     = 80
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for container diagnostics."
  type        = string
  default     = null
}

variable "log_analytics_workspace_key" {
  description = "Log Analytics primary shared key for diagnostics integration."
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to container resources."
  type        = map(string)
  default     = {}
}
