terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

# Configure Auth0 provider
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

# Create Auth0 application for WatsonX integration with Authorization Code flow
module "watsonx_auth0" {
  source = "../.."

  name        = "WatsonX Integration"
  description = "Auth0 application for WatsonX OAuth2 integration"
  
  # Configure for Authorization Code flow (for user authentication)
  app_type    = "regular_web_application"
  grant_types = ["authorization_code", "refresh_token"]
  
  # WatsonX callback URLs - replace with your actual WatsonX URLs
  callback_urls = [
    var.watsonx_callback_url
  ]
  
  logout_urls = [
    var.watsonx_logout_url
  ]
  
  # Optional: Configure API audience and scopes if WatsonX needs API access
  audience = var.api_audience
  scopes   = var.api_scopes
  
  auth0_domain = var.auth0_domain
}