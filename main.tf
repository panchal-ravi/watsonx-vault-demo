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
    # export AUTH0_CLIENT_ID
    # export AUTH0_CLIENT_SECRET
    # export AUTH0_DOMAIN
    domain = var.auth0_domain
}

# Create Auth0 application with test users
module "auth0_with_users" {
  source = "./auth0"

  name        = "Test Application with Users"
  description = "Auth0 application with test users for development"
  
  # Configure for Authorization Code flow
  app_type    = "regular_web"
  grant_types = ["authorization_code", "refresh_token"]
  
  callback_urls = ["http://localhost:3000/callback"]
  logout_urls   = ["http://localhost:3000/logout"]
  
  # Enable user creation
  create_users = true
  
  # Define test users using for_each friendly map structure
  users = {
    "test.user@example.com" = {
      password    = "${var.test_password}"
      name        = "Test User"
      given_name  = "Test"
      family_name = "User"
    }
    
    "admin@example.com" = {
      password    = "${var.test_password}"
      name        = "Admin User"
      given_name  = "Admin"
      family_name = "User"
      nickname    = "admin"
    }
    
    "developer@example.com" = {
      password    = "${var.test_password}"
      name        = "Developer User"
      given_name  = "Developer"
      family_name = "User"
    }
  }
  
  auth0_domain = var.auth0_domain
}