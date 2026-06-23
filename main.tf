data "azurerm_client_config" "current" {}

locals {
  name_prefix          = lower("${var.project_name}-${var.environment}")
  compact_prefix       = lower(replace("${local.name_prefix}${var.resource_suffix}", "-", ""))
  global_prefix        = "${local.compact_prefix}${random_string.tfstate_suffix.result}"
  postgres_server_name = substr("${local.global_prefix}pg", 0, 63)
  key_vault_name       = coalesce(var.key_vault_name, substr("${local.compact_prefix}kv", 0, 24))
  servicebus_namespace = substr("${local.global_prefix}sb", 0, 50)
  acr_name             = substr("${local.global_prefix}acr", 0, 50)
  tfstate_sa_name      = coalesce(var.tfstate_storage_account_name, substr("st${local.compact_prefix}${random_string.tfstate_suffix.result}", 0, 24))
  entra_redirect_uri   = "https://${var.app_domain}/api/auth/entra/callback"
  github_redirect_uri  = "https://${var.app_domain}/api/auth/github/callback"
  merged_tags          = merge(var.tags, { environment = var.environment, owner = var.admin_email })
}

resource "random_string" "tfstate_suffix" {
  length  = 6
  lower   = true
  numeric = true
  special = false
  upper   = false
}

module "resource_group" {
  source = "./modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = local.merged_tags
}

module "network" {
  source = "./modules/network"

  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.merged_tags
}

module "acr" {
  source = "./modules/acr"

  name                = local.acr_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.merged_tags
}

module "appgateway" {
  source = "./modules/appgateway"

  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.network.appgw_subnet_id
  tags                = local.merged_tags
}

module "aks" {
  source = "./modules/aks"

  name                = var.aks_name
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.network.aks_subnet_id
  app_gateway_id      = module.appgateway.id
  node_vm_size        = var.aks_node_vm_size
  node_count          = var.aks_node_count
  tags                = local.merged_tags
}

module "keyvault" {
  source = "./modules/keyvault"

  name                          = local.key_vault_name
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  current_object_id             = coalesce(var.keyvault_admin_object_id, data.azurerm_client_config.current.object_id)
  aks_kubelet_object_id         = module.aks.kubelet_object_id
  private_endpoint_subnet_id    = module.network.private_endpoint_subnet_id
  app_vnet_id                   = module.network.app_vnet_id
  public_network_access_enabled = var.keyvault_public_network_access_enabled
  tags                          = local.merged_tags
}

module "entra_app" {
  source = "./modules/entra-app"

  display_name                    = var.entra_app_display_name
  redirect_uris                   = [local.entra_redirect_uri]
  client_secret_display_name      = var.entra_client_secret_display_name
  client_secret_end_date_relative = var.entra_client_secret_end_date_relative
}

resource "azurerm_key_vault_secret" "entra_client_secret" {
  name         = "entra-client-secret"
  value        = module.entra_app.client_secret_value
  key_vault_id = module.keyvault.id

  depends_on = [
    module.keyvault
  ]
}

module "postgres" {
  source = "./modules/postgres"

  name                   = local.postgres_server_name
  resource_group_name    = module.resource_group.name
  location               = module.resource_group.location
  delegated_subnet_id    = module.network.postgres_subnet_id
  app_vnet_id            = module.network.app_vnet_id
  data_vnet_id           = module.network.data_vnet_id
  administrator_login    = var.postgres_admin_login
  administrator_password = var.postgres_admin_password
  private_dns_zone_name  = "${local.postgres_server_name}.private.postgres.database.azure.com"
  tags                   = local.merged_tags
}

module "servicebus" {
  source = "./modules/servicebus"

  name                = local.servicebus_namespace
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  queue_names         = var.servicebus_queue_names
  tags                = local.merged_tags
}

module "jumpbox" {
  source = "./modules/jumpbox"

  vm_name             = var.jumpbox_vm_name
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.network.jumpbox_subnet_id
  admin_username      = var.jumpbox_admin_username
  admin_password      = var.jumpbox_admin_password
  tags                = local.merged_tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_object_id
}

resource "azurerm_role_assignment" "agic_appgateway_contributor" {
  scope                = module.appgateway.id
  role_definition_name = "Contributor"
  principal_id         = module.aks.agic_object_id
}
