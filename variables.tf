variable "project_name" {
  description = "Short project name used for Azure resource names."
  type        = string
  default     = "pipelineiq"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "resource_suffix" {
  description = "Short suffix for globally unique resources such as ACR, Key Vault, PostgreSQL, and Service Bus. Use lowercase letters and numbers."
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "Main resource group name."
  type        = string
  default     = "rg-pipelineiq-sweden"
}

variable "aks_name" {
  description = "AKS cluster name."
  type        = string
  default     = "pipeline-aks"
}

variable "aks_node_vm_size" {
  description = "VM size for the AKS system node pool."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "aks_node_count" {
  description = "Node count for the AKS system node pool. Keep this within the available regional vCPU quota."
  type        = number
  default     = 1
}

variable "jumpbox_vm_name" {
  description = "Name of the SSH jumpbox VM."
  type        = string
  default     = "pipelinevm"
}

variable "tfstate_storage_account_name" {
  description = "Optional globally unique Azure Storage Account name for Terraform state. Leave null to generate one."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.tfstate_storage_account_name == null || can(regex("^[a-z0-9]{3,24}$", var.tfstate_storage_account_name))
    error_message = "The Terraform state storage account name must be 3-24 lowercase letters or numbers."
  }
}

variable "tfstate_container_name" {
  description = "Blob container name for Terraform state."
  type        = string
  default     = "tfstate"
}

variable "app_domain" {
  description = "Public application domain used by App Gateway and Entra redirect URI."
  type        = string
  default     = "www.pipelinesolutions.xyz"
}

variable "key_vault_name" {
  description = "Optional Azure Key Vault name used for application secrets. Leave null to derive one from the project/environment suffix."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.key_vault_name == null || can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.key_vault_name))
    error_message = "The Key Vault name must be 3-24 characters, start with a letter, end with a letter or number, and contain only letters, numbers, and hyphens."
  }
}

variable "entra_app_display_name" {
  description = "Display name for the Microsoft Entra app registration."
  type        = string
  default     = "PipelineIQ"
}

variable "entra_client_secret_display_name" {
  description = "Display name for the generated Microsoft Entra client secret."
  type        = string
  default     = "pipelineiq-auth"
}

variable "entra_client_secret_end_date_relative" {
  description = "Relative expiry duration for the generated Microsoft Entra client secret."
  type        = string
  default     = "8760h"
}

variable "admin_email" {
  description = "Owner/contact email for documentation and generated tags."
  type        = string
}

variable "jumpbox_admin_username" {
  description = "Admin username for the private jumpbox VM."
  type        = string
  default     = "azureuser"
}

variable "jumpbox_admin_password" {
  description = "Admin password for the private jumpbox VM."
  type        = string
  sensitive   = true
}

variable "postgres_admin_login" {
  description = "PostgreSQL administrator username."
  type        = string
  default     = "pgadminuser"
}

variable "postgres_admin_password" {
  description = "PostgreSQL administrator password. This is stored in Terraform state because Azure requires it at create time."
  type        = string
  sensitive   = true
}

variable "keyvault_public_network_access_enabled" {
  description = "Keep Key Vault public access enabled during setup. Set false after you are ready to manage secrets through private network access."
  type        = bool
  default     = true
}

variable "servicebus_queue_names" {
  description = "Service Bus queues required by PipelineIQ services."
  type        = list(string)
  default = [
    "pipeline.monitor",
    "pipeline.analyze",
    "pipeline.ai",
    "pipeline.notify"
  ]
}

variable "tags" {
  description = "Common Azure tags."
  type        = map(string)
  default = {
    project    = "pipelineiq"
    managed_by = "terraform"
  }
}
