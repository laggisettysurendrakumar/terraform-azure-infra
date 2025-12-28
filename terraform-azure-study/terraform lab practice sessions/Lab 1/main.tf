terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "training_vnet" {
  name                = "xyz-vnet-eastus"
  location            = "East US"
  resource_group_name = "rg-xyz-training"
  address_space       = ["10.20.0.0/16"]
}
