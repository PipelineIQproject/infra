variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "delegated_subnet_id" {
  type = string
}

variable "app_vnet_id" {
  type = string
}

variable "data_vnet_id" {
  type = string
}

variable "administrator_login" {
  type = string
}

variable "administrator_password" {
  type      = string
  sensitive = true
}

variable "private_dns_zone_name" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "GP_Standard_D4ads_v5"
}

variable "storage_mb" {
  type    = number
  default = 32768
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "database_name" {
  type    = string
  default = "pipelineiq"
}

variable "tags" {
  type    = map(string)
  default = {}
}
