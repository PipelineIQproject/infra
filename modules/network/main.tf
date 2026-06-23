resource "azurerm_virtual_network" "app" {
  name                = "${var.name_prefix}-app-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.app_vnet_address_space
  tags                = var.tags
}

resource "azurerm_virtual_network" "data" {
  name                = "${var.name_prefix}-data-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.data_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = [var.aks_subnet_prefix]
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = [var.appgw_subnet_prefix]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = [var.private_endpoint_subnet_prefix]
}

resource "azurerm_subnet" "jumpbox" {
  name                 = "snet-jumpbox"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = [var.jumpbox_subnet_prefix]
}

resource "azurerm_subnet" "postgres" {
  name                 = "snet-postgres"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.data.name
  address_prefixes     = [var.postgres_subnet_prefix]

  delegation {
    name = "postgres-flexible-server-delegation"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_public_ip" "nat" {
  name                = "${var.name_prefix}-nat-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "main" {
  name                = "${var.name_prefix}-natgw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "jumpbox" {
  subnet_id      = azurerm_subnet.jumpbox.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet_nat_gateway_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_virtual_network_peering" "app_to_data" {
  name                      = "${var.name_prefix}-app-to-data"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.app.name
  remote_virtual_network_id = azurerm_virtual_network.data.id

  depends_on = [
    azurerm_subnet.aks,
    azurerm_subnet.appgw,
    azurerm_subnet.private_endpoints,
    azurerm_subnet.jumpbox,
    azurerm_subnet.postgres,
    azurerm_subnet_nat_gateway_association.jumpbox,
    azurerm_subnet_nat_gateway_association.aks
  ]
}

resource "azurerm_virtual_network_peering" "data_to_app" {
  name                      = "${var.name_prefix}-data-to-app"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.data.name
  remote_virtual_network_id = azurerm_virtual_network.app.id

  depends_on = [
    azurerm_virtual_network_peering.app_to_data
  ]
}
