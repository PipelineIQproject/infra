variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "app_vnet_address_space" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "data_vnet_address_space" {
  type    = list(string)
  default = ["10.20.0.0/16"]
}

variable "aks_subnet_prefix" {
  type    = string
  default = "10.10.1.0/24"
}

variable "appgw_subnet_prefix" {
  type    = string
  default = "10.10.2.0/24"
}

variable "private_endpoint_subnet_prefix" {
  type    = string
  default = "10.10.3.0/24"
}

variable "jumpbox_subnet_prefix" {
  type    = string
  default = "10.10.4.0/24"
}

variable "postgres_subnet_prefix" {
  type    = string
  default = "10.20.1.0/24"
}

variable "tags" {
  type    = map(string)
  default = {}
}
