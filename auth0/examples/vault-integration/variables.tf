variable "auth0_domain" {
  description = "Auth0 domain (e.g., 'your-domain.auth0.com')"
  type        = string
}

variable "auth0_client_id" {
  description = "Auth0 management API client ID"
  type        = string
}

variable "auth0_client_secret" {
  description = "Auth0 management API client secret"
  type        = string
  sensitive   = true
}

variable "application_name" {
  description = "Name of the Auth0 application"
  type        = string
  default     = "Vault JWT Auth Client"
}

variable "application_description" {
  description = "Description of the Auth0 application"
  type        = string
  default     = "Client credentials application for Hashicorp Vault JWT authentication"
}

variable "audience" {
  description = "Target audience for the client credentials tokens"
  type        = string
  default     = "https://vault.example.com/v1/auth/jwt"
}

variable "scopes" {
  description = "List of scopes to request for the client credentials"
  type        = list(string)
  default     = ["read:metrics", "read:vault"]
}