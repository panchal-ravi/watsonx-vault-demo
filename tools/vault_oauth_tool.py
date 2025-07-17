# test_tool.py
from ibm_watsonx_orchestrate.agent_builder.tools import tool, ToolPermission
from ibm_watsonx_orchestrate.run import connections
from ibm_watsonx_orchestrate.agent_builder.connections import (
    ConnectionType,
    ExpectedCredentials,
)
import hvac
import logging
from hvac.exceptions import VaultError
from typing import Optional, Dict, Any

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def initialize_client() -> Optional[hvac.Client]:
    """
    Sets up and initializes a thread-safe Vault client using HVAC.

    The Vault address is read from the VAULT_ADDR environment variable.
    This function should be called per request to ensure thread safety.

    Returns:
        An initialized hvac.Client instance, or None if the configuration is missing.
    """

    try:
        client = hvac.Client(url="http://VAULT_IP:8200")
        logging.info("HVAC client initialized successfully.")
        return client
    except Exception as e:
        logging.error(f"Failed to initialize HVAC client: {e}")
        return None


def authenticate_approle(
    client: hvac.Client, role_id: str, secret_id: str
) -> Optional[Dict[str, Any]]:
    """
    Authenticates to Vault using AppRole.

    Args:
        client: The hvac.Client instance.
        role_id: The AppRole role_id.
        secret_id: The AppRole secret_id.

    Returns:
        The client token if authentication is successful, None otherwise.
    """
    try:
        logging.info("Authenticating to Vault using AppRole...")
        response = client.auth.approle.login(
            role_id=role_id,
            secret_id=secret_id,
        )
        return response

    except VaultError as e:
        logging.error(f"Vault error during AppRole authentication: {e}")
        return None
    except Exception as e:
        logging.error(
            f"An unexpected error occurred during AppRole authentication: {e}"
        )
        return None


@tool(
    name="vault_oauth_tool",
    description="Interact with Vault to fetch secrets.",
    permission=ToolPermission.ADMIN,
    expected_credentials=[
        ExpectedCredentials(
            app_id="client_creds", type=ConnectionType.OAUTH2_CLIENT_CREDS
        )
    ],
)
def vault_oauth_tool() -> str:
    """
    This is a tool to interact with Vault to fetch secrets.
    :returns: message.
    """
    conn = connections.oauth2_client_creds("client_creds")
    access_token = conn.access_token

    # response = authenticate_approle(client, role_id, secret_id)
    # client_token = response["auth"]["client_token"]

    # if client_token:
    #     # Now that we are authenticated, we can perform other vault operations.
    #     # For now, just returning a success message.
    #     return f"Client: {client_token}"
    # else:
    #     return "Error: Failed to authenticate to Vault with AppRole."
    # return f"Role ID: {role_id}, Secret ID: {secret_id}"
    return f"Message: {access_token}"
