
resource "vault_jwt_auth_backend" "jwt" {
  description = "JWT Authentication Method"

  namespace          = var.namespace != null ? var.namespace : null
  path               = var.path
  type               = "jwt"
  oidc_discovery_url = var.oidc_discovery_url
  default_role       = "default"
}

resource "vault_jwt_auth_backend_role" "default" {
  namespace               = var.namespace != null ? var.namespace : null
  backend                 = vault_jwt_auth_backend.jwt.path
  role_name               = "default"
  role_type               = "jwt"  # Explicitly set role type to JWT (not OIDC)
  token_no_default_policy = true # Don't assign default policy - rely on group-based policies
  user_claim              = "preferred_username"  # For logging/auditing purposes only
  groups_claim            = "groups"
  verbose_oidc_logging    = true # Enable verbose logging to see user info
  token_ttl               = var.token_ttl
  token_max_ttl           = var.token_max_ttl
  
  # Bind to specific audience (client_id) - this validates the JWT was issued for our app
  bound_audiences = [var.oidc_client_id]
}

# Additional external groups - map Vault groups and policies to EntraId groups
resource "vault_identity_group" "external_groups" {
  for_each  = var.external_groups
  namespace = var.namespace != null ? var.namespace : null
  name      = each.value.group_name
  type      = "external"
  policies  = each.value.policies
  metadata = {
    name = each.value.group_name
  }
}

resource "vault_identity_group_alias" "external_group_aliases" {
  for_each       = var.external_groups
  namespace      = var.namespace != null ? var.namespace : null
  name           = each.value.alias_name
  mount_accessor = vault_jwt_auth_backend.jwt.accessor
  canonical_id   = vault_identity_group.external_groups[each.key].id
}
