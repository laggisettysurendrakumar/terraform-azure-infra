terraform {
  required_providers {
    azurerm = {
      source  = "XYZCompany/azurerm"
      version = "2.40.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# -------------------------------
# Virtual Network
# -------------------------------
resource "azurerm_virtual_network" "demo_vnet" {
  name                = "vnet-demo-eastus"
  address_space       = ["10.10.0.0/16"]
  location            = "eastus"
  resource_group_name = "rg-demo-001"
}

# -------------------------------
# Subnet (Implicit Dependency)
# -------------------------------
resource "azurerm_subnet" "demo_subnet" {
  name                 = "subnet-demo-eastus"
  resource_group_name  = "rg-demo-001"
  virtual_network_name = azurerm_virtual_network.demo_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
