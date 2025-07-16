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
  default     = "Basic Client Credentials App"
}

variable "application_description" {
  description = "Description of the Auth0 application"
  type        = string
  default     = "A basic client credentials application for machine-to-machine authentication"
}