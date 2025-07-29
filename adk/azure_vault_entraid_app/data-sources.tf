data "azuread_client_config" "current" {}

data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "primary" {}

data "azuread_domains" "current" {
  only_initial = true
}