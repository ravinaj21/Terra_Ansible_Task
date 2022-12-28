terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "eb610e94-b4e6-450e-863a-f5f04cba5f8d"
  tenant_id       = "66a1b718-3e00-4617-a869-71aa190d2785"
  client_id       = "382d6be6-f8aa-4b7f-a463-6144621dae63"
  client_secret   = "2sU8Q~b--Y1gqO9BTWgqzq3RnpSyoGFjeMQdsbPI"
}
