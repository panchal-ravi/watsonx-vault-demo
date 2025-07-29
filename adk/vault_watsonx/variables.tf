variable "tenant" {
  description = "The name of the tenant for which the AppRole is being created."
  type        = string
  default     = "watsonxdemo"
}

variable "namespace" {
  description = "The namespace in which the resources will be created."
  type        = string
  default     = "admin/hashi-redhat"  # Default namespace for the resources
}

variable "vault_cluster_addr" {
  default = ""
}

variable "oidc_discovery_url" {
  type        = string
  description = "The OIDC Discovery URL, without any .well-known component (base path)."
  default     = ""
}

variable "oidc_client_secret" {
  type        = string
  description = "Client Secret used for OIDC backends."
  default     = ""
}

variable "oidc_client_id" {
  type        = string
  description = "Client ID used for OIDC backends."
  default     = ""
}

variable "allowed_redirect_uris" {
  type        = list(any)
  description = "List of strings of allowed redirect URIs. Should be the two redirect URIs for Vault CLI and UI access."
}

variable "external_group_identifier" {
  type        = string
  description = "Unique identifier for the group in your AAD. AAD uses the object ID"
  default     = ""
}

# JWT Auth Variables
variable "path" {
  type        = string
  description = "Path to mount the JWT auth method"
  default     = "jwt"
}

variable "no_default_policy" {
  type        = bool
  description = "Whether to exclude default policy from tokens"
  default     = false
}

variable "oidc_scopes" {
  type        = list(string)
  description = "List of OIDC scopes"
  default     = ["openid"]
}

variable "enable_debug_log" {
  type        = bool
  description = "Enable verbose OIDC logging"
  default     = false
}

variable "token_ttl" {
  type        = number
  description = "Token TTL in seconds"
  default     = 3600
}

variable "token_max_ttl" {
  type        = number
  description = "Token max TTL in seconds"
  default     = 7200
}

# External Groups
variable "external_groups" {
  description = "Map of external groups to create."
  type        = map(object({
    group_name     = string
    type     = string
    policies = list(string)
    alias_name    = string
  }))
  default     = {}
}