# Terraform block for module
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

# Azure App Service Plan with conditional logic
resource "azurerm_app_service_plan" "asp" {
  name                = var.plan_name
  resource_group_name = var.resource_group

  # Conditional expression:
  # If location is provided → use it
  # Else → default to eastus
  location = var.location != "" ? var.location : "eastus"

  kind     = "Linux"
  reserved = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}
