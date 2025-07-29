variable "password" {
  description = "Password for the Azure AD application users"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.password) >= 8 && can(regex("[A-Z]", var.password)) && can(regex("[a-z]", var.password)) && can(regex("[0-9]", var.password)) && can(regex("[!@#$%^&*]", var.password))
    error_message = "Password must be at least 8 characters long and contain uppercase, lowercase, numbers, and special characters."
  }
}