output "id" {
  description = "Resource ID of the AI Foundry backing AI Services account."
  value       = azurerm_cognitive_account.main.id
}

output "name" {
  description = "Name of the AI Foundry backing AI Services account."
  value       = azurerm_cognitive_account.main.name
}

output "endpoint" {
  description = "Endpoint of the AI Foundry backing AI Services account."
  value       = azurerm_cognitive_account.main.endpoint
}

output "principal_id" {
  description = "System-assigned managed identity principal ID, when identity is enabled."
  value       = try(azurerm_cognitive_account.main.identity[0].principal_id, null)
}
