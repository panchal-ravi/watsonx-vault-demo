terraform {
  required_version = ">= 1.0"

  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

# Configure the Auth0 provider for testing
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

variable "auth0_domain" {
  description = "Auth0 domain for testing"
  type        = string
}

variable "auth0_client_id" {
  description = "Auth0 management API client ID for testing"
  type        = string
}

variable "auth0_client_secret" {
  description = "Auth0 management API client secret for testing"
  type        = string
  sensitive   = true
}