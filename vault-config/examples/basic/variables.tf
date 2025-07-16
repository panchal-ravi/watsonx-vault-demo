variable "auth0_domain" {
  description = "Auth0 domain (e.g., 'your-domain.us.auth0.com')"
  type        = string
  default     = "your-domain.us.auth0.com"
}

variable "auth0_audience" {
  description = "Auth0 audience URL"
  type        = string
  default     = "https://your-domain.us.auth0.com/api/v2/"
}

variable "bound_subject" {
  description = "Subject claim from JWT token (typically client_id@clients for Auth0)"
  type        = string
  default     = "your-client-id@clients"
}