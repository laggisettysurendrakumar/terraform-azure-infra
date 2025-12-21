provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-terraform-day2"
  location = "Central India"
}
