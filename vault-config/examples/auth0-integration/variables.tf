variable "auth0_domain" {
  description = "Auth0 domain (e.g., 'your-company.us.auth0.com')"
  type        = string
  # Example: "your-company.us.auth0.com"
}

variable "auth0_audience" {
  description = "Auth0 audience URL configured in your Auth0 application"
  type        = string
  # Example: "https://your-company.us.auth0.com/api/v2/"
}

variable "bound_subject" {
  description = "Subject claim from JWT token - for Auth0 client credentials this is typically {client_id}@clients"
  type        = string
  # Example: "abc123def456@clients" where abc123def456 is your Auth0 client ID
}

variable "auth0_client_id" {
  description = "Auth0 Client ID for reference (not used in Vault config but useful for documentation)"
  type        = string
  default     = ""
}

variable "auth0_client_secret" {
  description = "Auth0 Client Secret for reference (not used in Vault config but useful for documentation)"
  type        = string
  default     = ""
  sensitive   = true
}