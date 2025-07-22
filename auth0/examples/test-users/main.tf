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

# Create Auth0 application with test users
module "auth0_with_users" {
  source = "../.."

  name        = "Test Application with Users"
  description = "Auth0 application with test users for development"
  
  # Configure for Authorization Code flow
  app_type    = "regular_web_application"
  grant_types = ["authorization_code", "refresh_token"]
  
  callback_urls = ["http://localhost:3000/callback"]
  logout_urls   = ["http://localhost:3000/logout"]
  
  # Enable user creation
  create_users = true
  
  # Define test users using for_each friendly map structure
  users = {
    "test.user@example.com" = {
      password    = "${var.test_password}"
      name        = "watsonxuser1"
      given_name  = "Test"
      family_name = "User"
    }
    
    "admin@example.com" = {
      password    = "${var.test_password}"
      name        = "watsonxuser2"
      given_name  = "Admin"
      family_name = "User"
      nickname    = "admin"
    }
    
    "developer@example.com" = {
      password    = "${var.test_password}"
      name        = "watsonxuser3"
      given_name  = "Developer"
      family_name = "User"
    }
  }
  
  auth0_domain = var.auth0_domain
}