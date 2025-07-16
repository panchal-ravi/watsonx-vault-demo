terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

# Test setup - configure Vault provider for testing
provider "vault" {
  # In real tests, this would be configured via environment variables
  # For testing purposes, we assume Vault is running locally or in CI
}