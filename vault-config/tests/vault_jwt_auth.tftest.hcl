run "basic_configuration" {
  command = plan

  variables {
    auth0_domain   = "test-domain.us.auth0.com"
    auth0_audience = "https://test-domain.us.auth0.com/api/v2/"
    bound_subject  = "test-client-id@clients"
  }

  # Test that all required resources are created
  assert {
    condition     = vault_auth_backend.jwt.type == "jwt"
    error_message = "JWT auth backend type should be 'jwt'"
  }

  assert {
    condition     = vault_auth_backend.jwt.path == "jwt"
    error_message = "JWT auth backend path should be 'jwt' by default"
  }

  assert {
    condition     = vault_policy.metrics.name == "metrics"
    error_message = "Policy name should be 'metrics' by default"
  }

  assert {
    condition     = vault_jwt_auth_backend.auth0.oidc_discovery_url == "https://test-domain.us.auth0.com/"
    error_message = "OIDC discovery URL should be constructed correctly"
  }

  assert {
    condition     = vault_jwt_auth_backend_role.watsonx.role_name == "watsonx"
    error_message = "JWT role name should be 'watsonx' by default"
  }

  assert {
    condition     = contains(vault_jwt_auth_backend_role.watsonx.bound_audiences, "https://test-domain.us.auth0.com/api/v2/")
    error_message = "JWT role should have correct bound audience"
  }

  assert {
    condition     = vault_jwt_auth_backend_role.watsonx.bound_subject == "test-client-id@clients"
    error_message = "JWT role should have correct bound subject"
  }
}

run "custom_configuration" {
  command = plan

  variables {
    auth0_domain   = "custom-domain.auth0.com"
    auth0_audience = "https://custom-domain.auth0.com/api/v2/"
    bound_subject  = "custom-client@clients"
    policy_name    = "custom-policy"
    role_name      = "custom-role"
    jwt_auth_path  = "custom-jwt"
    token_ttl      = 1800
    token_max_ttl  = 3600
  }

  assert {
    condition     = vault_auth_backend.jwt.path == "custom-jwt"
    error_message = "JWT auth backend path should be customizable"
  }

  assert {
    condition     = vault_policy.metrics.name == "custom-policy"
    error_message = "Policy name should be customizable"
  }

  assert {
    condition     = vault_jwt_auth_backend_role.watsonx.role_name == "custom-role"
    error_message = "JWT role name should be customizable"
  }

  assert {
    condition     = vault_jwt_auth_backend_role.watsonx.token_ttl == 1800
    error_message = "Token TTL should be customizable"
  }

  assert {
    condition     = vault_jwt_auth_backend_role.watsonx.token_max_ttl == 3600
    error_message = "Token max TTL should be customizable"
  }
}

run "policy_validation" {
  command = plan

  variables {
    auth0_domain   = "test-domain.us.auth0.com"
    auth0_audience = "https://test-domain.us.auth0.com/api/v2/"
    bound_subject  = "test-client-id@clients"
    policy_rules   = <<EOF
path "sys/metrics*" {
  capabilities = ["read", "list"]
}
path "sys/health*" {
  capabilities = ["read"]
}
EOF
  }

  assert {
    condition     = can(regex("sys/metrics", vault_policy.metrics.policy))
    error_message = "Policy should contain metrics access rules"
  }

  assert {
    condition     = can(regex("sys/health", vault_policy.metrics.policy))
    error_message = "Policy should contain custom health access rules"
  }
}

run "jwt_role_configuration" {
  command = plan

  variables {
    auth0_domain   = "test-domain.us.auth0.com"
    auth0_audience = "https://test-domain.us.auth0.com/api/v2/"
    bound_subject  = "test-client-id@clients"
    user_claim     = "sub"
    role_type      = "jwt"
  }

  assert {
    condition     = vault_jwt_auth_backend_role.watsonx.user_claim == "sub"
    error_message = "JWT role should have correct user claim"
  }

  assert {
    condition     = vault_jwt_auth_backend_role.watsonx.role_type == "jwt"
    error_message = "JWT role should have correct role type"
  }

  assert {
    condition     = contains(vault_jwt_auth_backend_role.watsonx.token_policies, "metrics")
    error_message = "JWT role should have metrics policy attached"
  }
}

run "output_validation" {
  command = plan

  variables {
    auth0_domain   = "test-domain.us.auth0.com"
    auth0_audience = "https://test-domain.us.auth0.com/api/v2/"
    bound_subject  = "test-client-id@clients"
  }

  # Test that outputs are properly formatted
  assert {
    condition     = can(regex("vault write auth/.*/login", output.login_command))
    error_message = "Login command output should be properly formatted"
  }

  assert {
    condition     = can(regex("vault write auth/.*/login", output.test_auth_command))
    error_message = "Test auth command output should be properly formatted"
  }
}