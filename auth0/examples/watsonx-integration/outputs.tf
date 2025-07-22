output "client_id" {
  description = "Auth0 client ID for WatsonX integration"
  value       = module.watsonx_auth0.client_id
}

output "client_secret" {
  description = "Auth0 client secret for WatsonX integration"
  value       = module.watsonx_auth0.client_secret
  sensitive   = true
}

output "auth0_domain" {
  description = "Auth0 domain for WatsonX integration"
  value       = var.auth0_domain
}

output "authorization_endpoint" {
  description = "OAuth2 authorization endpoint URL"
  value       = "https://${var.auth0_domain}/authorize"
}

output "token_endpoint" {
  description = "OAuth2 token endpoint URL"  
  value       = "https://${var.auth0_domain}/oauth/token"
}

output "userinfo_endpoint" {
  description = "OAuth2 userinfo endpoint URL"
  value       = "https://${var.auth0_domain}/userinfo"
}

output "issuer" {
  description = "OAuth2 issuer URL"
  value       = "https://${var.auth0_domain}/"
}