output "client_id" {
  description = "The Auth0 client ID"
  value       = auth0_client.client_credentials.id
}

output "client_secret" {
  description = "The Auth0 client secret"
  value       = auth0_client_credentials.credentials.client_secret
  sensitive   = true
}

output "domain" {
  description = "The Auth0 domain"
  value       = var.auth0_domain
}

output "token_endpoint" {
  description = "The OAuth2 token endpoint URL"
  value       = "https://${var.auth0_domain}/oauth/token"
}

output "audience" {
  description = "The configured audience for the client credentials"
  value       = var.audience != "" ? var.audience : "https://${var.auth0_domain}/api/v2/"
}

output "client_name" {
  description = "The name of the Auth0 client"
  value       = auth0_client.client_credentials.name
}

output "authorization_endpoint" {
  description = "The OAuth2 authorization endpoint URL (for Authorization Code flow)"
  value       = "https://${var.auth0_domain}/authorize"
}

output "userinfo_endpoint" {
  description = "The OAuth2 userinfo endpoint URL"
  value       = "https://${var.auth0_domain}/userinfo"
}

output "issuer" {
  description = "The OAuth2 issuer URL"
  value       = "https://${var.auth0_domain}/"
}

output "curl_command" {
  description = "Example curl command to test the client credentials flow"
  value = format(
    "curl --request POST --url https://%s/oauth/token --header 'content-type: application/json' --data '{\"client_id\":\"%s\",\"client_secret\":\"%s\",\"audience\":\"%s\",\"grant_type\":\"client_credentials\"}'",
    var.auth0_domain,
    auth0_client.client_credentials.id,
    auth0_client_credentials.credentials.client_secret,
    var.audience != "" ? var.audience : "https://${var.auth0_domain}/api/v2/"
  )
  sensitive = true
}

output "created_users" {
  description = "Map of created test users"
  value = var.create_users ? {
    for email, user in auth0_user.users : email => {
      user_id = user.user_id
      email   = user.email
      name    = user.name
    }
  } : {}
}

output "user_count" {
  description = "Number of users created"
  value       = var.create_users ? length(auth0_user.users) : 0
}