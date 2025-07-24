# resource "vault_auth_backend" "approle" {
#   type = "approle"
#   path = "approle"
# }

#this is an existing mount
data "vault_auth_backend" "approle" {
  path = "approle"
}

resource "vault_approle_auth_backend_role" "this" {
  backend        = data.vault_auth_backend.approle.path
  role_name      = var.tenant
  token_policies = ["watsonxdemo"]
}

resource "vault_approle_auth_backend_role_secret_id" "this" {
  backend   = vault_approle_auth_backend_role.this.backend
  role_name = var.tenant
}

resource "vault_identity_entity" "this" {
  name = var.tenant
  metadata = {
    ssh_role_name = var.tenant
  }
}

#create entity alias for the role
resource "vault_identity_entity_alias" "this" {
  name           = vault_approle_auth_backend_role.this.role_id
  mount_accessor = data.vault_auth_backend.approle.accessor
  canonical_id   = vault_identity_entity.this.id
}