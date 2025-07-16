# Auth0 Integration Example

This example demonstrates how to configure Vault JWT authentication for integration with Auth0 client credentials flow.

## Prerequisites

1. **Auth0 Application**: Create a Machine-to-Machine application in Auth0 configured for `client_credentials` grant type
2. **Vault Access**: Running Vault instance with appropriate permissions
3. **Environment Variables**: Set the following environment variables:
   ```bash
   export VAULT_ADDR="https://your-vault-instance.com"
   export VAULT_TOKEN="your-vault-token"
   ```

## Configuration

1. **Update variables**: Edit `terraform.tfvars` or provide variables during `terraform apply`:
   ```hcl
   auth0_domain      = "your-company.us.auth0.com"
   auth0_audience    = "https://your-company.us.auth0.com/api/v2/"
   bound_subject     = "abc123def456@clients"  # Your Auth0 client ID + @clients
   auth0_client_id   = "abc123def456"
   auth0_client_secret = "your-client-secret"
   ```

2. **Deploy the module**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Usage

### Complete Workflow

1. **Get JWT token from Auth0**:
   ```bash
   JWT_TOKEN=$(curl --request POST \
     --url https://your-company.us.auth0.com/oauth/token \
     --header 'content-type: application/json' \
     --data '{
       "client_id": "abc123def456",
       "client_secret": "your-client-secret",
       "audience": "https://your-company.us.auth0.com/api/v2/",
       "grant_type": "client_credentials"
     }' | jq -r '.access_token')
   ```

2. **Authenticate with Vault**:
   ```bash
   vault write auth/jwt/login \
     role=watsonx-service \
     jwt=$JWT_TOKEN
   ```

3. **Access protected resources**:
   ```bash
   # Access metrics
   vault read sys/metrics
   
   # Access health status
   vault read sys/health
   
   # Access version info
   vault read sys/version
   ```

### Testing the Integration

Use the provided output commands for easy testing:

```bash
# Get the OAuth2 flow example
terraform output oauth2_flow_example

# Get the complete workflow example
terraform output complete_workflow_example
```

## Security Notes

- The `bound_subject` must match exactly the subject claim in your JWT token
- For Auth0 client credentials, the subject is typically `{client_id}@clients`
- Token TTL is set to 1 hour with a maximum of 2 hours
- The policy grants minimal required permissions for metrics access

## Troubleshooting

1. **Authentication fails**: Verify that `bound_subject` matches the JWT token's subject claim
2. **Token validation fails**: Ensure Auth0 domain and audience are correctly configured
3. **Policy access denied**: Check that the policy includes the required paths for your use case

## Outputs

After deployment, you can view the configuration details:

```bash
terraform output jwt_auth_path
terraform output policy_name
terraform output role_name
terraform output oidc_discovery_url
terraform output login_command
```