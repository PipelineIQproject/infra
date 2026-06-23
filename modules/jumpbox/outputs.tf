output "id" {
  value = azurerm_linux_virtual_machine.main.id
}

output "private_ip_address" {
  value = azurerm_network_interface.main.private_ip_address
}

output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}
