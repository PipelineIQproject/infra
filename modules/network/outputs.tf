output "app_vnet_id" {
  value = azurerm_virtual_network.app.id
}

output "data_vnet_id" {
  value = azurerm_virtual_network.data.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "jumpbox_subnet_id" {
  value = azurerm_subnet.jumpbox.id
}

output "postgres_subnet_id" {
  value = azurerm_subnet.postgres.id
}
