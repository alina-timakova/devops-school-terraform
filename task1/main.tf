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

data "azurerm_virtual_network" "vnet" {
  name                = "epm-rdsp-westus-vnet"
  resource_group_name = "epm-rdsp"
}

data "azurerm_network_security_group" "nsg" {
  name                = "epm-rdsp-westus-sg"
  resource_group_name = "epm-rdsp"
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.vnet.id
}

output "virtual_network_subnets" {
  value = data.azurerm_virtual_network.vnet.subnets
}

output "nsg_id" {
  value = data.azurerm_network_security_group.nsg.id
}
