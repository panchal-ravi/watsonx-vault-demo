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