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

  # Auth0 configuration
  auth0_domain   = "your-domain.us.auth0.com"
  auth0_audience = "https://your-domain.us.auth0.com/api/v2/"

  # JWT subject from your Auth0 application
  bound_subject = "your-client-id@clients"

  # Optional: Override defaults
  policy_name   = "metrics"
  role_name     = "watsonx"
  jwt_auth_path = "jwt"
}