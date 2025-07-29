resource "vault_policy" "admins" {
  name      = "vault-admins"
  policy    = <<EOT
#vault-admin.hcl
#Allows very broad access and should not be used in production

# permit access to all sys backend configurations to administer Vault itself
path "sys/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# manage Vault auth methods
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# manage Vault identities
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# permit access to administer the OIDC auth method
path "oidc/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_jwt_auth_backend" "jwt" {
  description = "JWT Authentication Method"

  namespace          = var.namespace != null ? var.namespace : null
  path               = var.path
  type               = "jwt"
  # For JWT authentication, we only need the discovery URL for public key verification
  oidc_discovery_url = var.oidc_discovery_url
  # Client credentials are not needed for JWT validation
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
  # Don't assign any default policies - let group membership drive policy assignment
  # token_policies          = []  # Empty - policies come from groups only
  
  # Bind to specific audience (client_id) - this validates the JWT was issued for our app
  bound_audiences = [var.oidc_client_id]
}


# module "azure_oidc" {
#   source  = "bmcdonald05/oidc-auth-method/vault"
#   version = "1.0.4"

#   namespace                 = "admin/hashi-redhat"
#   oidc_discovery_url        = var.oidc_discovery_url
#   oidc_client_id            = var.oidc_client_id
#   oidc_client_secret        = var.oidc_client_secret
#   allowed_redirect_uris     = var.allowed_redirect_uris
#   user_claim                = "name" #should be "sub" or "oid" following the recommendation from Azure. In my lab I use name to more easily identify users.
#   additional_policies       = [vault_policy.admins.name]
#   external_group_identifier = var.external_group_identifier # AAD uses the AD group object ID to identify the group
# }

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
