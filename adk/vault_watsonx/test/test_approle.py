#!/usr/bin/env python3
"""
HashiCorp Vault AppRole Authentication Script

This script demonstrates how to authenticate with HashiCorp Vault using:
- Namespace
- AppRole ID
- Secret ID

Requirements:
- hvac library (pip install hvac)
- Valid Vault server with AppRole auth method enabled
"""

import os
import sys
import hvac
from typing import Optional, Dict, Any
import logging
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,  # Changed to DEBUG for more detailed logging
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class VaultAppRoleAuth:
    """HashiCorp Vault AppRole authentication client"""
    
    def __init__(
        self,
        vault_url: str,
        namespace: str,
        role_id: str,
        secret_id: str,
        verify_ssl: bool = True
    ):
        """
        Initialize Vault client with AppRole authentication
        
        Args:
            vault_url: Vault server URL (e.g., https://vault.example.com:8200)
            namespace: Vault namespace
            role_id: AppRole role ID
            secret_id: AppRole secret ID
            verify_ssl: Whether to verify SSL certificates
        """
        self.vault_url = vault_url
        self.namespace = namespace
        self.role_id = role_id
        self.secret_id = secret_id
        self.verify_ssl = verify_ssl
        self.client = None
        self.token = None
        
    def authenticate(self) -> bool:
        """
        Authenticate with Vault using AppRole
        
        Returns:
            bool: True if authentication successful, False otherwise
        """
        try:
            # Initialize Vault client
            self.client = hvac.Client(
                url=self.vault_url,
                verify=self.verify_ssl,
                namespace=self.namespace
            )
            
            # Authenticate using AppRole
            logger.info("Authenticating with AppRole...")
            auth_response = self.client.auth.approle.login(
                role_id=self.role_id,
                secret_id=self.secret_id
            )
            
            # Debug: Log the auth response
            logger.debug(f"Auth response: {auth_response}")
            
            # Extract token from response
            self.token = auth_response['auth']['client_token']
            
            # Set token for subsequent requests
            self.client.token = self.token
            
            # Verify authentication by checking token
            if self.client.is_authenticated():
                logger.info("Successfully authenticated with Vault")
                self._log_token_info()
                self._debug_available_mounts()
                return True
            else:
                logger.error("Authentication failed - token invalid")
                return False
                
        except hvac.exceptions.InvalidRequest as e:
            logger.error(f"Invalid request during authentication: {e}")
            return False
        except hvac.exceptions.Forbidden as e:
            logger.error(f"Forbidden - check AppRole permissions: {e}")
            return False
        except hvac.exceptions.VaultError as e:
            logger.error(f"Vault error during authentication: {e}")
            return False
        except Exception as e:
            logger.error(f"Unexpected error during authentication: {e}")
            return False
    
    def _log_token_info(self):
        """Log information about the current token"""
        try:
            token_info = self.client.auth.token.lookup_self()
            logger.info(f"Token policies: {token_info['data'].get('policies', [])}")
            logger.info(f"Token TTL: {token_info['data'].get('ttl', 'N/A')} seconds")
            logger.info(f"Token renewable: {token_info['data'].get('renewable', False)}")
        except Exception as e:
            logger.warning(f"Could not retrieve token info: {e}")
    
    def _debug_available_mounts(self):
        """Debug method to log available secret mounts"""
        try:
            mounts = self.client.sys.list_mounted_secrets_engines()
            logger.info("Available secret engines:")
            if isinstance(mounts, dict):
                for mount_path, mount_info in mounts.items():
                    if isinstance(mount_info, dict):
                        mount_type = mount_info.get('type', 'unknown')
                        logger.info(f"  - {mount_path} (type: {mount_type})")
                    else:
                        logger.info(f"  - {mount_path} (info: {mount_info})")
            else:
                logger.info(f"Mounts response: {mounts}")
        except Exception as e:
            logger.warning(f"Could not retrieve mounted secret engines: {e}")
            # Try to get some basic info about the token's capabilities
            try:
                capabilities = self.client.sys.get_capabilities('secret/')
                logger.info(f"Capabilities for 'secret/' path: {capabilities}")
            except Exception as cap_error:
                logger.warning(f"Could not check capabilities for 'secret/' path: {cap_error}")
    
    def read_secret(self, path: str) -> Optional[Dict[str, Any]]:
        """
        Read a secret from Vault
        
        Args:
            path: Secret path (e.g., 'myapp/config')
            
        Returns:
            Dict containing secret data or None if error
        """
        if not self.client or not self.client.is_authenticated():
            logger.error("Not authenticated with Vault")
            return None
            
        # Try different secret engine approaches
        attempts = [
            # KV v2 with kv/ mount
            lambda: self.client.secrets.kv.v2.read_secret_version(path=path, mount_point='kv'),
            # KV v2 with secret/ mount
            lambda: self.client.secrets.kv.v2.read_secret_version(path=path),
            # KV v1 with kv/ mount  
            lambda: self.client.secrets.kv.v1.read_secret(path=path, mount_point='kv'),
            # KV v1 with secret/ mount
            lambda: self.client.secrets.kv.v1.read_secret(path=path),
            # Direct read (for other engines)
            lambda: self.client.read(f"secret/{path}"),
        ]
        
        for i, attempt in enumerate(attempts):
            try:
                logger.info(f"Reading secret from path: {path} (attempt {i+1})")
                response = attempt()
                
                # Handle different response formats
                if response and 'data' in response:
                    if 'data' in response['data']:  # KV v2
                        logger.info(f"Successfully read secret using KV v2")
                        return response['data']['data']
                    else:  # KV v1 or other
                        logger.info(f"Successfully read secret using KV v1 or direct read")
                        return response['data']
                elif response:
                    logger.info(f"Successfully read secret (raw response)")
                    return response
                    
            except hvac.exceptions.InvalidPath:
                logger.debug(f"Path not found with attempt {i+1}")
                continue
            except hvac.exceptions.Forbidden as e:
                logger.debug(f"Permission denied with attempt {i+1}: {e}")
                continue
            except Exception as e:
                logger.debug(f"Error with attempt {i+1}: {e}")
                continue
        
        logger.error(f"Secret not found at path: {path} (tried all methods)")
        return None
    
    def write_secret(self, path: str, secret: Dict[str, Any]) -> bool:
        """
        Write a secret to Vault
        
        Args:
            path: Secret path (e.g., 'myapp/config')
            secret: Dictionary containing secret data
            
        Returns:
            bool: True if successful, False otherwise
        """
        if not self.client or not self.client.is_authenticated():
            logger.error("Not authenticated with Vault")
            return False
            
        # Try different secret engine approaches
        attempts = [
            # KV v2 with kv/ mount
            lambda: self.client.secrets.kv.v2.create_or_update_secret(path=path, secret=secret, mount_point='kv'),
            # KV v2 with secret/ mount
            lambda: self.client.secrets.kv.v2.create_or_update_secret(path=path, secret=secret),
            # KV v1 with kv/ mount
            lambda: self.client.secrets.kv.v1.create_or_update_secret(path=path, secret=secret, mount_point='kv'),
            # KV v1 with secret/ mount
            lambda: self.client.secrets.kv.v1.create_or_update_secret(path=path, secret=secret),
            # Direct write (for other engines)
            lambda: self.client.write(f"secret/{path}", **secret),
        ]
        
        for i, attempt in enumerate(attempts):
            try:
                logger.info(f"Writing secret to path: {path} (attempt {i+1})")
                attempt()
                logger.info(f"Secret written successfully using method {i+1}")
                return True
            except hvac.exceptions.Forbidden as e:
                logger.debug(f"Permission denied with attempt {i+1}: {e}")
                continue
            except Exception as e:
                logger.debug(f"Error with attempt {i+1}: {e}")
                continue
        
        logger.error(f"Failed to write secret to path: {path} (tried all methods)")
        return False
    
    def renew_token(self) -> bool:
        """
        Renew the current token
        
        Returns:
            bool: True if successful, False otherwise
        """
        if not self.client or not self.client.is_authenticated():
            logger.error("Not authenticated with Vault")
            return False
            
        try:
            logger.info("Renewing token...")
            self.client.auth.token.renew_self()
            logger.info("Token renewed successfully")
            return True
        except Exception as e:
            logger.error(f"Error renewing token: {e}")
            return False


def main():
    """Main function to demonstrate Vault AppRole authentication"""
    
    # Load environment variables from .env file (override existing system vars)
    load_dotenv(dotenv_path='.env', override=True)
    
    # Get configuration from environment variables
    vault_url = os.getenv('VAULT_ADDR', 'https://localhost:8200')
    namespace = os.getenv('VAULT_NAMESPACE', 'admin')
    role_id = os.getenv('VAULT_ROLE_ID')
    secret_id = os.getenv('VAULT_SECRET_ID')
    
    # Validate required environment variables
    if not role_id:
        logger.error("VAULT_ROLE_ID environment variable is required")
        sys.exit(1)
        
    if not secret_id:
        logger.error("VAULT_SECRET_ID environment variable is required")
        sys.exit(1)
    
    logger.info(f"Connecting to Vault at: {vault_url}")
    logger.info(f"Using namespace: {namespace}")
    
    # Initialize and authenticate
    vault_client = VaultAppRoleAuth(
        vault_url=vault_url,
        namespace=namespace,
        role_id=role_id,
        secret_id=secret_id,
        verify_ssl=False  # Set to True in production
    )
    
    if vault_client.authenticate():
        logger.info("Authentication successful!")
        
        # Example: Read a secret
        secret_data = vault_client.read_secret('myapp/config')
        if secret_data:
            logger.info(f"Retrieved secret: {list(secret_data.keys())}")
        
        # Example: Write a secret
        test_secret = {
            'username': 'testuser',
            'password': 'testpass',
            'created_at': '2025-07-24'
        }
        vault_client.write_secret('myapp/test', test_secret)
        
    else:
        logger.error("Authentication failed!")
        sys.exit(1)


if __name__ == '__main__':
    main()