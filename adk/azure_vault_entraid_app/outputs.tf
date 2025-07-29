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

output "vault_admins_group_id" {
  value       = azuread_group.vault_admins.object_id
  description = "Object ID of Vault Admins group."
}

output "vault_users_group_id" {
  value       = azuread_group.vault_users.object_id
  description = "Object ID of Vault Users group."
}

output "demo1_user_id" {
  value       = azuread_user.demo1.object_id
  description = "Object ID of demo1 user."
}

output "demo2_user_id" {
  value       = azuread_user.demo2.object_id
  description = "Object ID of demo2 user."
}