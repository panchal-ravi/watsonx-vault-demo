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

output "bound_audiences" {
  description = "Audiences bound to the JWT role"
  value       = module.vault_jwt_auth.bound_audiences
}

output "bound_subject" {
  description = "Subject bound to the JWT role"
  value       = module.vault_jwt_auth.bound_subject
}

output "login_command" {
  description = "Example vault login command"
  value       = module.vault_jwt_auth.login_command
}

output "test_auth_command" {
  description = "Example command to test authentication"
  value       = module.vault_jwt_auth.test_auth_command
}

output "oauth2_flow_example" {
  description = "Example curl command to obtain JWT token from Auth0"
  value       = <<EOF
curl --request POST \
  --url https://${var.auth0_domain}/oauth/token \
  --header 'content-type: application/json' \
  --data '{
    "client_id": "${var.auth0_client_id}",
    "client_secret": "${var.auth0_client_secret}",
    "audience": "${var.auth0_audience}",
    "grant_type": "client_credentials"
  }'
EOF
}

output "complete_workflow_example" {
  description = "Complete workflow example from Auth0 token to Vault authentication"
  value       = <<EOF
# Step 1: Get JWT token from Auth0
JWT_TOKEN=$(curl --request POST \
  --url https://${var.auth0_domain}/oauth/token \
  --header 'content-type: application/json' \
  --data '{
    "client_id": "${var.auth0_client_id}",
    "client_secret": "${var.auth0_client_secret}",
    "audience": "${var.auth0_audience}",
    "grant_type": "client_credentials"
  }' | jq -r '.access_token')

# Step 2: Authenticate with Vault using JWT
vault write auth/${module.vault_jwt_auth.jwt_auth_path}/login \
  role=${module.vault_jwt_auth.role_name} \
  jwt=$JWT_TOKEN

# Step 3: Access metrics (example)
vault read sys/metrics
EOF
}