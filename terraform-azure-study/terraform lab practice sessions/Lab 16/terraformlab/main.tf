################################
# Terraform & Backend
################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "cal-1244-e87"
    storage_account_name  = "sacalabtest234"
    container_name        = "tfstate"
    key                   = "vm/terraform.tfstate"
  }
}

################################
# Azure Provider
################################
provider "azurerm" {
  features {}
}

################################
# Existing Lab Resource Group
################################
data "azurerm_resource_group" "lab" {
  name = var.resource_group_name
}

################################
# Virtual Network
################################
resource "azurerm_virtual_network" "vnet" {
  name                = "vm-vnet"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.lab.name
  address_space       = ["10.0.0.0/16"]
}

################################
# Subnet
################################
resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = data.azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

################################
# Network Interface
################################
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

################################
# Linux Virtual Machine (Password Auth)
################################
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.lab.name
  size                = "Standard_B1s"

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
    caching              = "ReadWrite"
  }

  source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts"
  version   = "latest"
}
}
