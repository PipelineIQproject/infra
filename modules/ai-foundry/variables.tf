variable "name" {
  description = "Name of the Azure AI Foundry backing AI Services account."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,62}[a-zA-Z0-9]$", var.name))
    error_message = "The AI Foundry account name must be 3-64 characters, start and end with a letter or number, and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group where the AI Foundry account will be created."
  type        = string
}

variable "location" {
  description = "Azure region for the AI Foundry account."
  type        = string
}

variable "sku_name" {
  description = "SKU for the AI Services account."
  type        = string
  default     = "S0"
}

variable "custom_subdomain_name" {
  description = "Custom subdomain for the AI Services endpoint. Leave null to let Azure use the account name where supported."
  type        = string
  default     = null
  nullable    = true
}

variable "local_auth_enabled" {
  description = "Whether key-based local authentication is enabled."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for initial setup."
  type        = bool
  default     = true
}

variable "identity_type" {
  description = "Managed identity type. Use SystemAssigned for standard AI Foundry integration, or null to omit identity."
  type        = string
  default     = "SystemAssigned"
  nullable    = true

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned"], var.identity_type)
    error_message = "identity_type must be SystemAssigned or null."
  }
}

variable "tags" {
  description = "Tags to apply to the AI Foundry account."
  type        = map(string)
  default     = {}
}
