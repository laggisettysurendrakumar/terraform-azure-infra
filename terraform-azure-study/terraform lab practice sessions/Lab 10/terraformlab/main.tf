# Terraform configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

# Azure Provider
provider "azurerm" {
  features {}
}

# App Service Plan - DEFAULT LOCATION (uses conditional fallback)
module "app_service_default_region" {
  source         = "./modules/app-service"
  plan_name      = "asp-default-east"
  resource_group = "rg-demo"
}

# App Service Plan - CUSTOM LOCATION
module "app_service_custom_region" {
  source         = "./modules/app-service"
  plan_name      = "asp-custom-west"
  resource_group = "rg-demo"
  location       = "westus"
}
