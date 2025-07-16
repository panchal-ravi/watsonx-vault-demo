output "jwt_auth_path" {
  description = "Path of the JWT authentication method"
  value       = vault_auth_backend.jwt.path
}

output "policy_name" {
  description = "Name of the created Vault policy"
  value       = vault_policy.metrics.name
}

output "role_name" {
  description = "Name of the created JWT role"
  value       = vault_jwt_auth_backend_role.watsonx.role_name
}

output "oidc_discovery_url" {
  description = "OIDC discovery URL configured in Vault"
  value       = vault_jwt_auth_backend.auth0.oidc_discovery_url
}

output "bound_audiences" {
  description = "Audiences bound to the JWT role"
  value       = vault_jwt_auth_backend_role.watsonx.bound_audiences
}

output "bound_subject" {
  description = "Subject bound to the JWT role"
  value       = vault_jwt_auth_backend_role.watsonx.bound_subject
}

output "login_command" {
  description = "Example vault login command"
  value       = "vault write auth/${vault_auth_backend.jwt.path}/login role=${vault_jwt_auth_backend_role.watsonx.role_name} jwt=$JWT_TOKEN"
}

output "test_auth_command" {
  description = "Example command to test authentication"
  value       = "vault write auth/${vault_auth_backend.jwt.path}/login role=${vault_jwt_auth_backend_role.watsonx.role_name} jwt=\"<YOUR_JWT_TOKEN>\""
}