variable "display_name" {
  description = "Display name for the Microsoft Entra application."
  type        = string
}

variable "sign_in_audience" {
  description = "Microsoft Entra sign-in audience."
  type        = string
  default     = "AzureADMyOrg"
}

variable "redirect_uris" {
  description = "Web redirect URIs for the application."
  type        = list(string)
}

variable "client_secret_display_name" {
  description = "Display name for the generated application secret."
  type        = string
}

variable "client_secret_end_date_relative" {
  description = "Relative expiry duration for the generated application secret."
  type        = string
}
