output "application_object_id" {
  value = azuread_application.main.object_id
}

output "client_id" {
  value = azuread_application.main.client_id
}

output "service_principal_object_id" {
  value = azuread_service_principal.main.object_id
}

output "client_secret_value" {
  value     = azuread_application_password.main.value
  sensitive = true
}
