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

variable "test_password" {
  description = "The password for test users"
  type        = string
  default     = "TempPassword123!"
}