variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "current_object_id" {
  type = string
}

variable "aks_kubelet_object_id" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "app_vnet_id" {
  type = string
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
