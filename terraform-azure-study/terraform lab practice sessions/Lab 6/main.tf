terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-remote-state"
    storage_account_name = "satfstatelabs001"
    container_name       = "tfstate"
    key                  = "dev/network.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-remote-westus"
  location            = "westus"
  resource_group_name = "rg-terraform-remote-state"
  address_space       = ["10.30.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-remote-westus"
  resource_group_name  = "rg-terraform-remote-state"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.1.0/24"]
}
