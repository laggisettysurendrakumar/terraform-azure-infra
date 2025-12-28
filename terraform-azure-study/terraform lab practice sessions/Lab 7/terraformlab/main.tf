# Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

#Azure provider
provider "azurerm" {
  features {}
}

#Create Storage Account
module "storage_account" {
  source    = "./modules/storage-account"

  saname    = "sacal3574a741"
  rgname    = "cal-3574-a74"
  location  = "westus"
}

#Create Storage Account
module "storage_account2" {
  source    = "./modules/storage-account"

  saname    = "sacal3574a742"
  rgname    = "cal-3574-a74"
  location  = "westus"
}