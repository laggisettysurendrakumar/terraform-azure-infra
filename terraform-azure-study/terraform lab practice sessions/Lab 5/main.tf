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

# -------------------------------
# Virtual Network A
# -------------------------------
resource "azurerm_virtual_network" "vnet_a" {
  name                = "vnet-a-westus-001"
  location            = "westus"
  resource_group_name = "rg-terraform-state"
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet_a" {
  name                 = "subnet-a-westus-001"
  resource_group_name  = "rg-terraform-state"
  virtual_network_name = azurerm_virtual_network.vnet_a.name
  address_prefixes     = ["10.10.1.0/24"]
}

# -------------------------------
# Virtual Network B
# -------------------------------
resource "azurerm_virtual_network" "vnet_b" {
  name                = "vnet-b-westus-001"
  location            = "westus"
  resource_group_name = "rg-terraform-state"
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "subnet_b" {
  name                 = "subnet-b-westus-001"
  resource_group_name  = "rg-terraform-state"
  virtual_network_name = azurerm_virtual_network.vnet_b.name
  address_prefixes     = ["10.20.1.0/24"]
}
