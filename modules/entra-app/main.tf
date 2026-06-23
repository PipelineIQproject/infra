resource "azuread_application" "main" {
  display_name     = var.display_name
  sign_in_audience = var.sign_in_audience

  web {
    redirect_uris = var.redirect_uris

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "main" {
  client_id = azuread_application.main.client_id
}

resource "time_static" "client_secret_created" {}

resource "azuread_application_password" "main" {
  application_id = azuread_application.main.id
  display_name   = var.client_secret_display_name

  end_date = timeadd(time_static.client_secret_created.rfc3339, var.client_secret_end_date_relative)
}
