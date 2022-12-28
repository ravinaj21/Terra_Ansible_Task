terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  use_msi = true
  
  backend "azurerm" {
     storage_account_name = "terratask"
     container_name ="terracontainer"
     key ="infrax.tfstate"
     subscription_id ="eb610e94-b4e6-450e-863a-f5f04cba5f8d"
     tenant_id ="66a1b718-3e00-4617-a869-71aa190d2785"
  }
}

