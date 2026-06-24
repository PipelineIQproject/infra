resource "azurerm_cognitive_account" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "AIServices"
  sku_name            = var.sku_name

  custom_subdomain_name         = var.custom_subdomain_name
  local_auth_enabled            = var.local_auth_enabled
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [var.identity_type]

    content {
      type = identity.value
    }
  }

  tags = var.tags
}
