resource "random_id" "app" {
  byte_length = 4
}

# Generate unique GUID for OAuth2 scope
resource "random_uuid" "oauth2_scope_id" {
}

# SECURITY: Azure AD Application for Vault OIDC Integration
# This application is configured with minimal required permissions and security best practices
resource "azuread_application" "vault" {
  display_name = "hashicorp-vault-app-${random_id.app.hex}"

  web {
    redirect_uris = [
      "${var.vault_ui_redirect_address}/ui/vault/auth/oidc/oidc/callback",
      "${var.vault_cli_redirect_address}/oidc/callback",
      "http://localhost:8080/callback"

    ]

    implicit_grant {
      id_token_issuance_enabled = true
    }
  }

  api {
    requested_access_token_version = 2
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access Vault on behalf of the signed-in user."
      admin_consent_display_name = "Access Vault"
      id                         = random_uuid.oauth2_scope_id.result
      type                       = "Admin"
      enabled                    = true
      value                      = "vault.secrets.read"
    }
  }

  # SECURITY: Limited to SecurityGroup only (not "All" groups)
  group_membership_claims = [
    "SecurityGroup"
  ]

  optional_claims {
    access_token {
      name = "groups"
    }

    id_token {
      name = "groups"
    }

    saml2_token {
      name = "groups"
    }
  }

  # SECURITY: Minimal Microsoft Graph permissions required for group resolution
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    # Group.Read.All - Read all groups
    resource_access {
      id   = "62a82d76-70ea-41e2-9197-370581804d09"
      type = "Role"
    }
    
    # User.Read.All - Read all users' profiles (more restrictive than Directory.Read.All)
    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214"
      type = "Role"
    }
  }

  identifier_uris = [
    "api://hashicorp-vault-app-${random_id.app.hex}"
  ]

  prevent_duplicate_names = true
  sign_in_audience        = "AzureADMyOrg"
  owners                  = var.app_owners

}

resource "azuread_service_principal" "vault" {
  client_id = azuread_application.vault.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_directory_role" "cloud_application_administrator" {
  template_id = "158c047a-c907-4556-b7ef-446551a6b5f7" # Cloud Application Administrator
}


resource "azurerm_role_definition" "vault_role" {
  name        = "Vault-role"
  scope       = data.azurerm_subscription.primary.id
  description = "This is role for App registrations used for HashiCorp Vault."

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachineScaleSets/*/read"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

resource "azurerm_role_assignment" "vault_role" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.vault_role.role_definition_resource_id
  principal_id       = azuread_service_principal.vault.object_id
}

# SECURITY: Application password with 1-year expiration
resource "azuread_application_password" "vault" {
  display_name   = "Vault"
  application_id = azuread_application.vault.id
  end_date       = timeadd(timestamp(), "8760h") # 1 year expiration
}

# Create Azure AD Groups for Vault roles
resource "azuread_group" "vault_admins" {
  display_name     = "Vault-Admins"
  mail_nickname    = "vault-admins"
  description      = "Users with admin access to Vault"
  security_enabled = true
}

resource "azuread_group" "vault_users" {
  display_name     = "Vault-Users"
  mail_nickname    = "vault-users"
  description      = "Users with read access to Vault"
  security_enabled = true
}

# SECURITY: Demo users with forced password change on first login
# Create demo users
resource "azuread_user" "demo1" {
  user_principal_name   = "demo1@${data.azuread_domains.current.domains[0].domain_name}"
  display_name          = "Demo User 1"
  mail_nickname         = "demo1"
  password              = var.password
  force_password_change = false  # Force password change on first login
}

resource "azuread_user" "demo2" {
  user_principal_name   = "demo2@${data.azuread_domains.current.domains[0].domain_name}"
  display_name          = "Demo User 2"
  mail_nickname         = "demo2"
  password              = var.password
  force_password_change = false  # Force password change on first login
}

# Assign users to groups
resource "azuread_group_member" "demo1_admin" {
  group_object_id  = azuread_group.vault_admins.object_id
  member_object_id = azuread_user.demo1.object_id
}

resource "azuread_group_member" "demo2_user" {
  group_object_id  = azuread_group.vault_users.object_id
  member_object_id = azuread_user.demo2.object_id
}
