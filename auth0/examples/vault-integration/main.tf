terraform {
  required_version = ">= 1.0"

  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

# Configure the Auth0 provider
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

# Create an Auth0 client credentials application for Vault integration
module "auth0_client_credentials" {
  source = "../.."

  name                        = var.application_name
  description                 = var.application_description
  auth0_domain               = var.auth0_domain
  audience                   = var.audience
  scopes                     = var.scopes
  token_endpoint_auth_method = "client_secret_post"
}