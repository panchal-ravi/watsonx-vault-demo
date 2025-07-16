variable "auth0_domain" {
  description = "Auth0 domain for OIDC discovery URL (e.g., 'your-domain.us.auth0.com')"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.auth0_domain))
    error_message = "Auth0 domain must be a valid domain name."
  }
}

variable "auth0_audience" {
  description = "Auth0 audience for token validation (e.g., 'https://your-domain.us.auth0.com/api/v2/')"
  type        = string
  validation {
    condition     = can(regex("^https://", var.auth0_audience))
    error_message = "Auth0 audience must be a valid HTTPS URL."
  }
}

variable "bound_subject" {
  description = "Subject claim from JWT token for role binding"
  type        = string
}

variable "policy_name" {
  description = "Name of the Vault policy to create"
  type        = string
  default     = "metrics"
}

variable "role_name" {
  description = "Name of the JWT role to create"
  type        = string
  default     = "watsonx"
}

variable "jwt_auth_path" {
  description = "Path for JWT authentication method"
  type        = string
  default     = "jwt"
}

variable "policy_rules" {
  description = "Policy rules for the Vault policy"
  type        = string
  default     = <<EOF
path "sys/metrics*" {
  capabilities = ["read", "list"]
}
EOF
}

variable "user_claim" {
  description = "JWT claim to use as the user's identity"
  type        = string
  default     = "sub"
}

variable "role_type" {
  description = "Type of role (jwt or oidc)"
  type        = string
  default     = "jwt"
  validation {
    condition     = contains(["jwt", "oidc"], var.role_type)
    error_message = "Role type must be either 'jwt' or 'oidc'."
  }
}

variable "token_ttl" {
  description = "Default token TTL in seconds"
  type        = number
  default     = 3600
}

variable "token_max_ttl" {
  description = "Maximum token TTL in seconds"
  type        = number
  default     = 7200
}