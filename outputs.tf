output "resource_group_name" {
  value = module.resource_group.name
}

output "tfstate_resource_group_name" {
  value = module.resource_group.name
}

output "tfstate_storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "tfstate_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "aks_name" {
  value = module.aks.name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "application_gateway_public_ip" {
  value = module.appgateway.public_ip_address
}

output "key_vault_name" {
  value = module.keyvault.name
}

output "postgres_fqdn" {
  value = module.postgres.fqdn
}

output "servicebus_namespace_name" {
  value = module.servicebus.name
}

output "entra_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "entra_client_id" {
  value = module.entra_app.client_id
}

output "entra_application_object_id" {
  value = module.entra_app.application_object_id
}

output "entra_redirect_uri" {
  value = local.entra_redirect_uri
}

output "github_redirect_uri" {
  value = local.github_redirect_uri
}

output "jumpbox_private_ip" {
  value = module.jumpbox.private_ip_address
}

output "jumpbox_public_ip" {
  value = module.jumpbox.public_ip_address
}

output "aks_kubelet_client_id" {
  value = module.aks.kubelet_client_id
}

output "servicebus_connection_string" {
  value     = module.servicebus.default_primary_connection_string
  sensitive = true
}
