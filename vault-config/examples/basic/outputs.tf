output "jwt_auth_path" {
  description = "Path of the JWT authentication method"
  value       = module.vault_jwt_auth.jwt_auth_path
}

output "policy_name" {
  description = "Name of the created Vault policy"
  value       = module.vault_jwt_auth.policy_name
}

output "role_name" {
  description = "Name of the created JWT role"
  value       = module.vault_jwt_auth.role_name
}

output "oidc_discovery_url" {
  description = "OIDC discovery URL configured in Vault"
  value       = module.vault_jwt_auth.oidc_discovery_url
}

output "login_command" {
  description = "Example vault login command"
  value       = module.vault_jwt_auth.login_command
}

output "test_auth_command" {
  description = "Example command to test authentication"
  value       = module.vault_jwt_auth.test_auth_command
}