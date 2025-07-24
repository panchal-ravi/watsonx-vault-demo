output "object_id" {
  value       = azuread_application.vault.object_id
  description = "Object ID of Azure AD application."
}

output "client_id" {
  value       = azuread_application.vault.client_id
  sensitive   = false
  description = "Application (Client) ID of Azure AD application."
}


output "client_secret" {
  value       = nonsensitive(azuread_application_password.vault.value)
  sensitive   = false
  description = "Client secret of Azure AD application."
}

output "client_secret_id" {
  value       = azuread_application_password.vault.id
  description = "Client secret ID of Azure AD application."
}

output "application_name" {
  value       = azuread_application.vault.display_name
  description = "Display name of Azure AD application."
}

output "tenant_id" {
  value       = data.azuread_client_config.current.tenant_id
  description = "Tenant ID of Azure subscription."
}

output "application_uri" {
  value       = azuread_application.vault.identifier_uris
  description = "Configured Application ID URIs of Azure AD application."
}