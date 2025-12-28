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
# Azure Container Registry
# -------------------------------
resource "azurerm_container_registry" "acr" {
  name                = "xyzacrregistry001"
  resource_group_name = "rg-terraform-labs"
  location            = "East US"
  sku                 = "Standard"
  admin_enabled       = false

  # Destroy-time provisioner (cleanup demo)
  provisioner "local-exec" {
    when = destroy
    command = <<EOT
      az acr repository delete \
        --name ${self.name} \
        --image hello-world:lab \
        --yes
    EOT
  }
}

# -------------------------------
# Import image using provisioner
# -------------------------------
resource "null_resource" "import_image" {

  provisioner "local-exec" {
    command = <<EOT
      az acr import \
        --name ${azurerm_container_registry.acr.name} \
        --source mcr.microsoft.com/hello-world \
        --image hello-world:lab
    EOT
  }
}
