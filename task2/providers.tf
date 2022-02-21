terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.33.0"
    }
  }
}

provider "azurerm" {
  features {}
}

