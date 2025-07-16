# Vault JWT Authentication Terraform Module

This Terraform module configures HashiCorp Vault for JWT authentication with Auth0 integration, specifically designed for OAuth2 client credentials flow.

## Features

- 🔐 **JWT Authentication**: Configures Vault JWT auth method for Auth0 integration
- 📝 **Policy Management**: Creates and manages Vault policies for resource access
- 🎯 **Role-Based Access**: Implements JWT roles with audience and subject binding
- 🔧 **Configurable**: Supports customizable policies, roles, and authentication paths
- 🧪 **Tested**: Includes comprehensive Terraform native tests
- 📚 **Examples**: Provides basic and Auth0 integration examples

## Usage

### Basic Usage

```hcl
module "vault_jwt_auth" {
  source = "path/to/vault-config"

  auth0_domain   = "your-domain.us.auth0.com"
  auth0_audience = "https://your-domain.us.auth0.com/api/v2/"
  bound_subject  = "your-client-id@clients"
}
```

### Advanced Usage

```hcl
module "vault_jwt_auth" {
  source = "path/to/vault-config"

  # Auth0 Configuration
  auth0_domain   = "your-company.us.auth0.com"
  auth0_audience = "https://your-company.us.auth0.com/api/v2/"
  bound_subject  = "abc123def456@clients"

  # Custom Policy
  policy_name = "enhanced-metrics"
  policy_rules = <<EOF
path "sys/metrics*" {
  capabilities = ["read", "list"]
}
path "sys/health*" {
  capabilities = ["read"]
}
EOF

  # JWT Role Configuration
  role_name      = "watsonx-service"
  jwt_auth_path  = "jwt"
  token_ttl      = 3600
  token_max_ttl  = 7200
}
```

## Complete Workflow

1. **Configure Auth0 Application** for client credentials flow
2. **Deploy this module** to configure Vault JWT authentication
3. **Obtain JWT token** from Auth0 using client credentials
4. **Authenticate with Vault** using the JWT token

### Example Authentication Flow

```bash
# Step 1: Get JWT token from Auth0
JWT_TOKEN=$(curl --request POST \
  --url https://your-domain.us.auth0.com/oauth/token \
  --header 'content-type: application/json' \
  --data '{
    "client_id": "your-client-id",
    "client_secret": "your-client-secret",
    "audience": "https://your-domain.us.auth0.com/api/v2/",
    "grant_type": "client_credentials"
  }' | jq -r '.access_token')

# Step 2: Authenticate with Vault
vault write auth/jwt/login role=watsonx jwt=$JWT_TOKEN

# Step 3: Access protected resources
vault read sys/metrics
```

## Examples

- **[Basic Example](examples/basic/)**: Simple JWT authentication setup
- **[Auth0 Integration](examples/auth0-integration/)**: Complete Auth0 + Vault integration with examples

## Testing

The module includes comprehensive Terraform native tests:

```bash
terraform test
```

Test cases cover:
- Basic configuration validation
- Custom configuration options
- Policy rule validation
- JWT role configuration
- Output formatting

## Security Considerations

- **Minimal Permissions**: Default policy grants only necessary access to `sys/metrics*`
- **Subject Binding**: JWT roles are bound to specific subjects for enhanced security
- **Audience Validation**: Tokens must match configured audience for validation
- **Token TTL**: Configurable token lifetimes to limit exposure windows

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vault_auth_backend.jwt](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/auth_backend) | resource |
| [vault_jwt_auth_backend.auth0](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend) | resource |
| [vault_jwt_auth_backend_role.watsonx](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend_role) | resource |
| [vault_policy.metrics](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth0_audience"></a> [auth0\_audience](#input\_auth0\_audience) | Auth0 audience for token validation (e.g., 'https://your-domain.us.auth0.com/api/v2/') | `string` | n/a | yes |
| <a name="input_auth0_domain"></a> [auth0\_domain](#input\_auth0\_domain) | Auth0 domain for OIDC discovery URL (e.g., 'your-domain.us.auth0.com') | `string` | n/a | yes |
| <a name="input_bound_subject"></a> [bound\_subject](#input\_bound\_subject) | Subject claim from JWT token for role binding | `string` | n/a | yes |
| <a name="input_jwt_auth_path"></a> [jwt\_auth\_path](#input\_jwt\_auth\_path) | Path for JWT authentication method | `string` | `"jwt"` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name of the Vault policy to create | `string` | `"metrics"` | no |
| <a name="input_policy_rules"></a> [policy\_rules](#input\_policy\_rules) | Policy rules for the Vault policy | `string` | `"path \"sys/metrics*\" {\n  capabilities = [\"read\", \"list\"]\n}\n"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the JWT role to create | `string` | `"watsonx"` | no |
| <a name="input_role_type"></a> [role\_type](#input\_role\_type) | Type of role (jwt or oidc) | `string` | `"jwt"` | no |
| <a name="input_token_max_ttl"></a> [token\_max\_ttl](#input\_token\_max\_ttl) | Maximum token TTL in seconds | `number` | `7200` | no |
| <a name="input_token_ttl"></a> [token\_ttl](#input\_token\_ttl) | Default token TTL in seconds | `number` | `3600` | no |
| <a name="input_user_claim"></a> [user\_claim](#input\_user\_claim) | JWT claim to use as the user's identity | `string` | `"sub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bound_audiences"></a> [bound\_audiences](#output\_bound\_audiences) | Audiences bound to the JWT role |
| <a name="output_bound_subject"></a> [bound\_subject](#output\_bound\_subject) | Subject bound to the JWT role |
| <a name="output_jwt_auth_path"></a> [jwt\_auth\_path](#output\_jwt\_auth\_path) | Path of the JWT authentication method |
| <a name="output_login_command"></a> [login\_command](#output\_login\_command) | Example vault login command |
| <a name="output_oidc_discovery_url"></a> [oidc\_discovery\_url](#output\_oidc\_discovery\_url) | OIDC discovery URL configured in Vault |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | Name of the created Vault policy |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the created JWT role |
| <a name="output_test_auth_command"></a> [test\_auth\_command](#output\_test\_auth\_command) | Example command to test authentication |
<!-- END_TF_DOCS -->