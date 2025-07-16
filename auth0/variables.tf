variable "name" {
  description = "Name of the Auth0 application"
  type        = string
}

variable "description" {
  description = "Description of the Auth0 application"
  type        = string
  default     = ""
}

variable "audience" {
  description = "Target audience for the client credentials tokens"
  type        = string
  default     = ""
}

variable "scopes" {
  description = "List of scopes to request for the client credentials"
  type        = list(string)
  default     = []
}

variable "token_endpoint_auth_method" {
  description = "Authentication method for the token endpoint"
  type        = string
  default     = "client_secret_post"
  validation {
    condition = contains([
      "client_secret_basic",
      "client_secret_post",
      "private_key_jwt",
      "none"
    ], var.token_endpoint_auth_method)
    error_message = "Authentication method must be one of: client_secret_basic, client_secret_post, private_key_jwt, none."
  }
}

variable "auth0_domain" {
  description = "Auth0 domain (e.g., 'your-domain.auth0.com')"
  type        = string
}