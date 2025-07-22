# Auth0 Client Credentials Terraform Module

This Terraform module creates an Auth0 application configured for the OAuth2 client credentials flow, specifically designed for machine-to-machine authentication with services like Hashicorp Vault.

## Features

- Creates an Auth0 non-interactive (machine-to-machine) application
- Configures client credentials authentication flow
- Supports custom audiences and scopes
- Includes optional resource server configuration
- Provides formatted curl command for testing
- Comprehensive testing with native Terraform tests

## Usage

### Basic Usage

```hcl
module "auth0_client_credentials" {
  source = "path/to/this/module"

  name         = "My M2M Application"
  description  = "Machine-to-machine application for API access"
  auth0_domain = "your-domain.auth0.com"
}
```

### With Custom Audience and Scopes

```hcl
module "auth0_client_credentials" {
  source = "path/to/this/module"

  name         = "Vault JWT Auth Client"
  description  = "Client credentials for Vault JWT authentication"
  auth0_domain = "your-domain.auth0.com"
  audience     = "https://vault.example.com/v1/auth/jwt"
  scopes       = ["read:metrics", "read:vault"]
}
```

### Testing the OAuth2 Flow

After deployment, you can test the client credentials flow using the provided curl command:

```bash
# Get the curl command from Terraform output
terraform output -raw curl_command | bash
```

## Prerequisites

Before using this module, you need to set up Auth0 and configure the Terraform provider authentication.

### Setup Using Auth0 CLI (Recommended)

1. **Install Auth0 CLI**:
   ```bash
   # Install via npm
   npm install -g @auth0/auth0-cli
   
   # Or via Homebrew (macOS)
   brew install auth0/auth0-cli/auth0
   ```

2. **Login to Auth0**:
   ```bash
   auth0 login --scopes create:client_grants
   ```

3. **Create Machine-to-Machine Application**:
   ```bash
   # Create a machine-to-machine application on Auth0
   export AUTH0_M2M_APP=$(auth0 apps create \
     --name "Auth0 Terraform Provider" \
     --description "Auth0 Terraform Provider M2M" \
     --type m2m \
     --reveal-secrets \
     --json | jq -r '. | {client_id: .client_id, client_secret: .client_secret}')

   # Extract the client ID and client secret from the output
   export AUTH0_CLIENT_ID=$(echo $AUTH0_M2M_APP | jq -r '.client_id')
   export AUTH0_CLIENT_SECRET=$(echo $AUTH0_M2M_APP | jq -r '.client_secret')
   ```
4. Add client grant
```
# Get the ID and IDENTIFIER fields of the Auth0 Management API
export AUTH0_MANAGEMENT_API_ID=$(auth0 apis list --json | jq -r 'map(select(.name == "Auth0 Management API"))[0].id')
export AUTH0_MANAGEMENT_API_IDENTIFIER=$(auth0 apis list --json | jq -r 'map(select(.name == "Auth0 Management API"))[0].identifier')
# Get the SCOPES to be authorized
export AUTH0_MANAGEMENT_API_SCOPES=$(auth0 apis scopes list $AUTH0_MANAGEMENT_API_ID --json | jq -r '.[].value' | jq -ncR '[inputs]')

# Authorize the Auth0 Terraform Provider application to use the Auth0 Management API
auth0 api post "client-grants" --data='{"client_id": "'$AUTH0_CLIENT_ID'", "audience": "'$AUTH0_MANAGEMENT_API_IDENTIFIER'", "scope":'$AUTH0_MANAGEMENT_API_SCOPES'}'
```


5. **Set Auth0 Domain**:
   ```bash
   export AUTH0_DOMAIN=your-tenant.auth0.com
   ```

### Required Dependencies

- **jq**: JSON processor for parsing CLI output
  ```bash
  # Install jq
  brew install jq  # macOS
  sudo apt-get install jq  # Ubuntu/Debian
  ```

### Terraform Provider Configuration

```hcl
terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

provider "auth0" {
  domain        = var.auth0_domain
  # client_id and client_secret will be read from environment variables
}
```

## Examples

See the `examples/` directory for complete usage examples:

- `examples/basic/` - Basic client credentials setup
- `examples/vault-integration/` - Vault JWT authentication integration

## Testing

This module includes comprehensive tests using native Terraform testing:

```bash
terraform test
```

## Vault Integration

This module is designed to work seamlessly with Hashicorp Vault's JWT authentication method. After creating the Auth0 client credentials, you can configure Vault as follows:

```bash
# Configure Vault JWT authentication
vault auth enable jwt
vault write auth/jwt/config \
  oidc_discovery_url="https://your-domain.auth0.com/"

# Create a role for the client
vault write auth/jwt/role/your-role \
  policies="your-policy" \
  user_claim="sub" \
  role_type="jwt" \
  bound_audiences="your-audience" \
  bound_subject="your-client-subject"
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_auth0"></a> [auth0](#requirement\_auth0) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_auth0"></a> [auth0](#provider\_auth0) | 1.24.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [auth0_client.client_credentials](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/client) | resource |
| [auth0_client_credentials.credentials](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/client_credentials) | resource |
| [auth0_client_grant.grant](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/client_grant) | resource |
| [auth0_resource_server.api](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/resource_server) | resource |
| [auth0_resource_server_scope.scopes](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/resource_server_scope) | resource |
| [auth0_tenant.current](https://registry.terraform.io/providers/auth0/auth0/latest/docs/data-sources/tenant) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_audience"></a> [audience](#input\_audience) | Target audience for the client credentials tokens | `string` | `""` | no |
| <a name="input_auth0_domain"></a> [auth0\_domain](#input\_auth0\_domain) | Auth0 domain (e.g., 'your-domain.auth0.com') | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the Auth0 application | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Auth0 application | `string` | n/a | yes |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | List of scopes to request for the client credentials | `list(string)` | `[]` | no |
| <a name="input_token_endpoint_auth_method"></a> [token\_endpoint\_auth\_method](#input\_token\_endpoint\_auth\_method) | Authentication method for the token endpoint | `string` | `"client_secret_post"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_audience"></a> [audience](#output\_audience) | The configured audience for the client credentials |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The Auth0 client ID |
| <a name="output_client_name"></a> [client\_name](#output\_client\_name) | The name of the Auth0 client |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | The Auth0 client secret |
| <a name="output_curl_command"></a> [curl\_command](#output\_curl\_command) | Example curl command to test the client credentials flow |
| <a name="output_domain"></a> [domain](#output\_domain) | The Auth0 domain |
| <a name="output_token_endpoint"></a> [token\_endpoint](#output\_token\_endpoint) | The OAuth2 token endpoint URL |
<!-- END_TF_DOCS -->