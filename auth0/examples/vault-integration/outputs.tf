output "client_id" {
  description = "The Auth0 client ID"
  value       = module.auth0_client_credentials.client_id
}

output "client_secret" {
  description = "The Auth0 client secret"
  value       = module.auth0_client_credentials.client_secret
  sensitive   = true
}

output "domain" {
  description = "The Auth0 domain"
  value       = module.auth0_client_credentials.domain
}

output "token_endpoint" {
  description = "The OAuth2 token endpoint URL"
  value       = module.auth0_client_credentials.token_endpoint
}

output "audience" {
  description = "The configured audience for the client credentials"
  value       = module.auth0_client_credentials.audience
}

output "curl_command" {
  description = "Example curl command to test the client credentials flow"
  value       = module.auth0_client_credentials.curl_command
  sensitive   = true
}

output "vault_jwt_config_command" {
  description = "Command to configure Vault JWT authentication"
  value = format(
    "vault write auth/jwt/config oidc_discovery_url=\"https://%s/\"",
    var.auth0_domain
  )
}

output "vault_role_command" {
  description = "Command to create Vault JWT role (replace <SUBJECT> with actual subject from JWT)"
  value = format(
    "vault write auth/jwt/role/watsonx policies=\"metrics\" user_claim=\"sub\" role_type=\"jwt\" bound_audiences=\"%s\" bound_subject=\"<SUBJECT_FROM_JWT>\"",
    var.audience
  )
}

output "vault_login_command" {
  description = "Command to test Vault login (replace <JWT_TOKEN> with actual token)"
  value = "vault write auth/jwt/login role=watsonx jwt=<JWT_TOKEN>"
}