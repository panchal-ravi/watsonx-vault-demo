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

module "azure_oidc" {
  source  = "bmcdonald05/oidc-auth-method/vault"
  version = "1.0.4"

  namespace                 = "admin/hashi-redhat"
  oidc_discovery_url        = var.oidc_discovery_url
  oidc_client_id            = var.oidc_client_id
  oidc_client_secret        = var.oidc_client_secret
  allowed_redirect_uris     = var.allowed_redirect_uris
  user_claim                = "name" #should be "sub" or "oid" following the recommendation from Azure. In my lab I use name to more easily identify users.
  additional_policies       = [vault_policy.admins.name]
  external_group_identifier = var.external_group_identifier # AAD uses the AD group object ID to identify the group
}

# Additional external groups - map Vault groups and policies to EntraId groups
resource "vault_identity_group" "external_groups" {
  for_each  = var.external_groups
  namespace = var.namespace != null ? var.namespace : null
  name      = each.value.group_name
  type      = "external"
  policies  = each.value.policies
}

resource "vault_identity_group_alias" "external_group_aliases" {
  for_each       = var.external_groups
  namespace      = var.namespace != null ? var.namespace : null
  name           = each.value.alias_name
  mount_accessor = module.azure_oidc.oidc_accessor
  canonical_id   = vault_identity_group.external_groups[each.key].id
}
