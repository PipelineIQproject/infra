resource "azurerm_servicebus_namespace" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  tags                = var.tags
}

resource "azurerm_servicebus_queue" "queues" {
  for_each     = toset(var.queue_names)
  name         = each.value
  namespace_id = azurerm_servicebus_namespace.main.id
}
