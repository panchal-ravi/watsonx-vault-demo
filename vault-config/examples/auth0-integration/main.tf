terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

provider "vault" {
  # Configuration will be provided via environment variables:
  # VAULT_ADDR, VAULT_TOKEN, etc.
}

module "vault_jwt_auth" {
  source = "../../"

  # Auth0 configuration - replace with your actual values
  auth0_domain   = var.auth0_domain
  auth0_audience = var.auth0_audience

  # JWT subject from your Auth0 application
  # For Auth0 client credentials, this is typically: {client_id}@clients
  bound_subject = var.bound_subject

  # Custom policy for enhanced metrics access
  policy_name  = "enhanced-metrics"
  policy_rules = <<EOF
path "sys/metrics*" {
  capabilities = ["read", "list"]
}
path "sys/health*" {
  capabilities = ["read"]
}
path "sys/version" {
  capabilities = ["read"]
}
EOF

  # JWT role configuration
  role_name     = "watsonx-service"
  jwt_auth_path = "jwt"

  # Token configuration
  token_ttl     = 3600 # 1 hour
  token_max_ttl = 7200 # 2 hours
}