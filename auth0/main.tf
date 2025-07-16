data "auth0_tenant" "current" {}

resource "auth0_client" "client_credentials" {
  name        = var.name
  description = var.description
  app_type    = "non_interactive"

  # Configure for client credentials flow
  grant_types = ["client_credentials"]
  
  # Configure custom audience if provided
  dynamic "jwt_configuration" {
    for_each = var.audience != "" ? [1] : []
    content {
      secret_encoded = false
    }
  }
}

# Configure client credentials authentication
resource "auth0_client_credentials" "credentials" {
  client_id             = auth0_client.client_credentials.id
  authentication_method = var.token_endpoint_auth_method
}

# Configure resource server and scopes if audience is provided
resource "auth0_resource_server" "api" {
  count = var.audience != "" ? 1 : 0

  name             = "${var.name} API"
  identifier       = var.audience
  signing_alg      = "RS256"
  allow_offline_access = false
  token_lifetime   = 86400
  skip_consent_for_verifiable_first_party_clients = true
}

# Configure resource server scopes
resource "auth0_resource_server_scope" "scopes" {
  count = var.audience != "" ? length(var.scopes) : 0

  resource_server_identifier = auth0_resource_server.api[0].identifier
  scope                      = var.scopes[count.index]
  description                = "Scope: ${var.scopes[count.index]}"
}

# Grant scopes to the client
resource "auth0_client_grant" "grant" {
  count = var.audience != "" ? 1 : 0

  client_id = auth0_client.client_credentials.id
  audience  = auth0_resource_server.api[0].identifier
  scopes    = var.scopes
}