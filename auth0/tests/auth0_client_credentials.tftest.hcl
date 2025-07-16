variables {
  auth0_domain = "test-domain.auth0.com"
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "basic_client_credentials" {
  variables {
    name         = "Test Client Credentials App"
    description  = "Test application for client credentials flow"
    auth0_domain = "test-domain.auth0.com"
  }

  assert {
    condition     = auth0_client.client_credentials.name == "Test Client Credentials App"
    error_message = "Client name should match the provided name"
  }

  assert {
    condition     = auth0_client.client_credentials.app_type == "non_interactive"
    error_message = "Client should be configured as non-interactive (machine-to-machine)"
  }

  assert {
    condition     = contains(auth0_client.client_credentials.grant_types, "client_credentials")
    error_message = "Client should support client_credentials grant type"
  }

  assert {
    condition     = auth0_client_credentials.credentials.authentication_method == "client_secret_post"
    error_message = "Client credentials should use client_secret_post authentication method"
  }

  assert {
    condition     = output.client_id != ""
    error_message = "Client ID should be generated"
  }

  assert {
    condition     = output.client_secret != ""
    error_message = "Client secret should be generated"
  }

  assert {
    condition     = output.token_endpoint == "https://test-domain.auth0.com/oauth/token"
    error_message = "Token endpoint should be correctly formatted"
  }

  assert {
    condition     = output.domain == "test-domain.auth0.com"
    error_message = "Domain should match the provided domain"
  }
}

run "client_credentials_with_custom_audience" {
  variables {
    name         = "Test Client with Custom Audience"
    description  = "Test application with custom audience"
    auth0_domain = "test-domain.auth0.com"
    audience     = "https://api.example.com"
    scopes       = ["read:data", "write:data"]
  }

  assert {
    condition     = auth0_resource_server.api[0].identifier == "https://api.example.com"
    error_message = "Resource server should have the correct audience identifier"
  }

  assert {
    condition     = output.audience == "https://api.example.com"
    error_message = "Output audience should match the provided audience"
  }

  assert {
    condition     = auth0_client_grant.grant[0].audience == "https://api.example.com"
    error_message = "Client grant should be configured with the correct audience"
  }

  assert {
    condition     = contains(auth0_client_grant.grant[0].scopes, "read:data")
    error_message = "Client grant should include read:data scope"
  }

  assert {
    condition     = contains(auth0_client_grant.grant[0].scopes, "write:data")
    error_message = "Client grant should include write:data scope"
  }
}

run "client_credentials_with_different_auth_method" {
  variables {
    name                        = "Test Client with Basic Auth"
    description                 = "Test application with basic authentication"
    auth0_domain               = "test-domain.auth0.com"
    token_endpoint_auth_method = "client_secret_basic"
  }

  assert {
    condition     = auth0_client_credentials.credentials.authentication_method == "client_secret_basic"
    error_message = "Client credentials should use client_secret_basic authentication method"
  }
}

run "output_validation" {
  variables {
    name         = "Output Validation Test"
    description  = "Test to validate all outputs are correct"
    auth0_domain = "test-domain.auth0.com"
    audience     = "https://vault.example.com"
    scopes       = ["read:metrics"]
  }

  assert {
    condition     = can(regex("^[a-zA-Z0-9]+$", output.client_id))
    error_message = "Client ID should be alphanumeric"
  }

  assert {
    condition     = length(output.client_secret) > 0
    error_message = "Client secret should not be empty"
  }

  assert {
    condition     = output.client_name == "Output Validation Test"
    error_message = "Client name output should match input"
  }

  assert {
    condition     = can(regex("^https://.*\\.auth0\\.com/oauth/token$", output.token_endpoint))
    error_message = "Token endpoint should be a valid Auth0 OAuth token URL"
  }

  assert {
    condition     = contains(output.curl_command, output.client_id)
    error_message = "Curl command should contain the client ID"
  }

  assert {
    condition     = contains(output.curl_command, "https://vault.example.com")
    error_message = "Curl command should contain the custom audience"
  }
}