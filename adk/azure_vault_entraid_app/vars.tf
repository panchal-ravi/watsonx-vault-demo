variable "vault_ui_redirect_address" {
  type        = string
  default     = "https://tf-aap-public-vault-76d1afab.7739a0fc.z1.hashicorp.cloud:8200"
  description = "DNS hostname or IP address of Vault's UI."
  
  validation {
    condition     = can(regex("^https://[a-zA-Z0-9.-]+:[0-9]+$", var.vault_ui_redirect_address))
    error_message = "vault_ui_redirect_address must be a valid HTTPS URL with port number."
  }
}

variable "vault_cli_redirect_address" {
  type        = string
  default     = "https://tf-aap-public-vault-76d1afab.7739a0fc.z1.hashicorp.cloud:8250"
  description = "DNS hostname or IP address of Vault's CLI."
  
  validation {
    condition     = can(regex("^https://[a-zA-Z0-9.-]+:[0-9]+$", var.vault_cli_redirect_address))
    error_message = "vault_cli_redirect_address must be a valid HTTPS URL with port number."
  }
}

variable "app_owners" {
  type        = list(string)
  default     = null
  description = "A set of object IDs of principals that will be granted ownership of the application."
}
