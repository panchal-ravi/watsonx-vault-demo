#!/usr/bin/env python3
"""
Example usage of the VaultAppRoleAuth class
"""

from test_approle import VaultAppRoleAuth
import os, hvac
from dotenv import load_dotenv

def example_usage():
    """Example of how to use the VaultAppRoleAuth class"""
    
    # Load environment variables from .env file (override existing system vars)
    load_dotenv(dotenv_path='.env', override=True)
    
    # Configuration - these should be set as environment variables
    vault_config = {
        'vault_url': os.getenv('VAULT_ADDR'),
        'namespace': os.getenv('VAULT_NAMESPACE'),
        'role_id': os.getenv('VAULT_ROLE_ID'),
        'secret_id': os.getenv('VAULT_SECRET_ID'),
        'verify_ssl': os.getenv('VAULT_VERIFY_SSL', 'true').lower() == 'true'
    }
    
    # Validate required environment variables
    required_vars = ['VAULT_ADDR', 'VAULT_NAMESPACE', 'VAULT_ROLE_ID', 'VAULT_SECRET_ID']
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"❌ Missing required environment variables: {', '.join(missing_vars)}")
        print("Please set the following environment variables:")
        for var in missing_vars:
            print(f"  export {var}=<your_value>")
        return False
    
    # Initialize the Vault client
    try:
        vault = VaultAppRoleAuth(**vault_config)
    except Exception as e:
        print(f"❌ Failed to initialize Vault client: {e}")
        return False
    
    # Authenticate
    try:
        if vault.authenticate():
            print("✅ Successfully authenticated with Vault!")
        else:
            print("❌ Failed to authenticate with Vault")
            return False
    except Exception as e:
        print(f"❌ Authentication error: {e}")
        return False
        
    # Example 1: Read a secret  
    secret_path = "watsonxdemo/config"  # Try reading the secret we just wrote
    try:
        secret_data = vault.read_secret(secret_path)
        if secret_data:
            print(f"📖 Retrieved secret from {secret_path}")
            # Don't print actual secret values in logs
            print(f"   Secret keys: {list(secret_data.keys())}")
        else:
            print(f"⚠️  No secret found at path: {secret_path}")
    except Exception as e:
        print(f"❌ Error reading secret from {secret_path}: {e}")
    
    # Example 2: Write a secret
    new_secret = {
        "api_key": "sk-1234567890abcdef",
        "endpoint": "https://api.watsonx.ai/v1",
        "model": "llama-2-70b-chat"
    }
    
    write_path = "watsonxdemo/config"
    try:
        if vault.write_secret(write_path, new_secret):
            print(f"✍️  Successfully wrote secret to {write_path}")
        else:
            print(f"⚠️  Failed to write secret to {write_path}")
    except Exception as e:
        print(f"❌ Error writing secret to {write_path}: {e}")
    
    # Example 3: Renew token if needed
    try:
        if vault.renew_token():
            print("🔄 Token renewed successfully")
        else:
            print("⚠️  Token renewal failed or not needed")
    except Exception as e:
        print(f"❌ Error renewing token: {e}")
    
    return True

if __name__ == '__main__':
    example_usage()
