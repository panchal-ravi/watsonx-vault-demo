# Enable JWT authentication method
resource "vault_auth_backend" "jwt" {
  type = "jwt"
  path = var.jwt_auth_path
}

# Create policy for metrics access
resource "vault_policy" "metrics" {
  name   = var.policy_name
  policy = var.policy_rules
}

# Configure JWT authentication backend
resource "vault_jwt_auth_backend" "auth0" {
  depends_on = [vault_auth_backend.jwt]

  path               = var.jwt_auth_path
  oidc_discovery_url = "https://${var.auth0_domain}/"

  # Optional: Configure additional settings
  default_role = var.role_name
}

# Create JWT role for watsonx
resource "vault_jwt_auth_backend_role" "watsonx" {
  depends_on = [vault_jwt_auth_backend.auth0]

  backend        = vault_auth_backend.jwt.path
  role_name      = var.role_name
  token_policies = [vault_policy.metrics.name]

  # JWT-specific configuration
  user_claim      = var.user_claim
  role_type       = var.role_type
  bound_audiences = [var.auth0_audience]
  bound_subject   = var.bound_subject

  # Token configuration
  token_ttl     = var.token_ttl
  token_max_ttl = var.token_max_ttl
}