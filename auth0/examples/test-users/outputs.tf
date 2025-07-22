output "client_id" {
  description = "Auth0 client ID"
  value       = module.auth0_with_users.client_id
}

output "client_secret" {
  description = "Auth0 client secret"
  value       = module.auth0_with_users.client_secret
  sensitive   = true
}

output "created_users" {
  description = "Map of created test users"
  value       = module.auth0_with_users.created_users
}

output "user_count" {
  description = "Number of users created"
  value       = module.auth0_with_users.user_count
}

output "authorization_endpoint" {
  description = "OAuth2 authorization endpoint"
  value       = module.auth0_with_users.authorization_endpoint
}

output "token_endpoint" {
  description = "OAuth2 token endpoint"
  value       = module.auth0_with_users.token_endpoint
}