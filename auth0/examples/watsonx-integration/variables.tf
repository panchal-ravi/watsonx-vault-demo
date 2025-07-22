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

variable "watsonx_callback_url" {
  description = "WatsonX OAuth2 callback URL"
  type        = string
  default     = "https://your-watsonx-instance.com/oauth/callback"
}

variable "watsonx_logout_url" {
  description = "WatsonX logout URL"
  type        = string
  default     = "https://your-watsonx-instance.com/logout"
}

variable "api_audience" {
  description = "Optional API audience identifier for token validation"
  type        = string
  default     = ""
}

variable "api_scopes" {
  description = "Optional API scopes to grant to the application"
  type        = list(string)
  default     = []
}