# Vault AppRole Authentication Test

This directory contains test scripts for HashiCorp Vault AppRole authentication.

## Files

- `test_approle.py` - Main VaultAppRoleAuth class implementation
- `example_usage.py` - Example usage demonstration
- `.env` - Environment variables configuration (not tracked in git)
- `requirements.txt` - Python dependencies

## Setup

1. **Install dependencies:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Configure environment variables:**
   
   Create a `.env` file with your Vault credentials:
   ```bash
   VAULT_ADDR=https://your-vault-instance.com:8200
   VAULT_NAMESPACE=admin/your-namespace
   VAULT_ROLE_ID=your-role-id-here
   VAULT_SECRET_ID=your-secret-id-here
   VAULT_VERIFY_SSL=true
   ```

   **Note**: The `.env` file is excluded from git for security. Update these values as needed.

## Usage

**Run the example (recommended):**
```bash
./venv/bin/python example_usage.py
```

**Run the test script directly:**
```bash
./venv/bin/python test_approle.py
```

### As a Library

```python
from test_approle import VaultAppRoleAuth

# Initialize
vault = VaultAppRoleAuth(
    vault_url="https://vault.company.com:8200",
    namespace="admin",
    role_id="your-role-id",
    secret_id="your-secret-id",
    verify_ssl=True
)

# Authenticate
if vault.authenticate():
    # Read a secret
    secret = vault.read_secret("myapp/config")
    
    # Write a secret
    vault.write_secret("myapp/data", {"key": "value"})
    
    # Renew token
    vault.renew_token()
```

## Features

- ✅ AppRole authentication with HashiCorp Vault
- ✅ Automatic detection of KV v1/v2 secret engines
- ✅ Multiple mount point support (kv/, secret/)
- ✅ Comprehensive error handling and logging
- ✅ Environment variable validation
- ✅ Token renewal functionality
- ✅ .env file support for easy configuration

## Security Notes

- Never commit actual credentials to version control
- The `.env` file is git-ignored for security
- Rotate credentials regularly, especially if they were exposed in code
- Use appropriate SSL verification in production (`VAULT_VERIFY_SSL=true`)

## Error Handling

The script handles common Vault errors:

- Invalid credentials
- Sealed Vault
- Network connectivity issues
- Permission denied
- Invalid paths
- Token expiration

## Logging

The script uses Python's logging module with INFO level by default. Logs include:

- Authentication status
- Token information (policies, TTL, renewable status)
- Secret operations (read/write)
- Error messages with context

## Example Output

```
2025-07-24 10:30:15,123 - INFO - Connecting to Vault at: https://vault.company.com:8200
2025-07-24 10:30:15,124 - INFO - Using namespace: admin
2025-07-24 10:30:15,125 - INFO - Authenticating with AppRole...
2025-07-24 10:30:15,890 - INFO - Successfully authenticated with Vault
2025-07-24 10:30:15,891 - INFO - Token policies: ['default', 'watsonx-policy']
2025-07-24 10:30:15,891 - INFO - Token TTL: 3600 seconds
2025-07-24 10:30:15,891 - INFO - Token renewable: True
```
