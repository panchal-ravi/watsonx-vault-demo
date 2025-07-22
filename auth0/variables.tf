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

variable "app_type" {
  description = "Type of Auth0 application"
  type        = string
  default     = "non_interactive"
  validation {
    condition = contains([
      "non_interactive",
      "regular_web_application",
      "spa",
      "native"
    ], var.app_type)
    error_message = "App type must be one of: non_interactive, regular_web_application, spa, native."
  }
}

variable "callback_urls" {
  description = "List of allowed callback URLs for the application"
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the application"
  type        = list(string)
  default     = []
}

variable "grant_types" {
  description = "List of grant types for the application"
  type        = list(string)
  default     = ["client_credentials"]
  validation {
    condition = alltrue([
      for grant in var.grant_types : contains([
        "authorization_code",
        "client_credentials",
        "implicit",
        "password",
        "refresh_token"
      ], grant)
    ])
    error_message = "Grant types must be from: authorization_code, client_credentials, implicit, password, refresh_token."
  }
}

variable "create_users" {
  description = "Whether to create test users in Auth0"
  type        = bool
  default     = false
}

variable "users" {
  description = "Map of test users to create (key = email)"
  type = map(object({
    password    = string
    name        = optional(string)
    nickname    = optional(string)
    given_name  = optional(string)
    family_name = optional(string)
  }))
  default = {}
}