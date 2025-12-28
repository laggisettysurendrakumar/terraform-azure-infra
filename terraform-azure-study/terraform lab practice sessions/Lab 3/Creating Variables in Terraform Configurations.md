## Creating Variables in Terraform Configurations (Azure)

---

## Introduction

In real-world Terraform projects, **hardcoding values** inside configuration files quickly becomes a problem. It makes the code:

* Difficult to reuse across environments (dev / test / prod)
* Harder to maintain
* Risky when sensitive values are involved

Terraform solves this using **variables**, which allow you to **parameterize** your infrastructure code.
Variables make Terraform configurations **flexible, reusable, and environment-agnostic**.

In this lab, you will use variables to deploy:

* A Virtual Network
* A Subnet
* A Network Interface
* A Virtual Machine

---

## Why Variables Matter in Terraform

![Image](https://www.devopsschool.com/blog/wp-content/uploads/2023/04/terraform-variable-types-1.png)

![Image](https://cdn.prod.website-files.com/67f9776b8553224cbb897cd7/685ae8ecb535cc0f796ce44f_autoscaling%20group2.webp)

![Image](https://brendanthompson.com/content/images/posts/2021/11/my-terraform-development-workflow/terraform-development-workflow.png)

Without variables:

* Each environment needs separate code

With variables:

* Same code → different environments
* Values supplied dynamically

---

## Step 1: Create the Variables File

Create a new file named **`variables.tf`** inside the `terraformlab` directory.

This file will hold **all reusable inputs** for the configuration.

---

## Step 2: Define Basic Infrastructure Variables

Add the following variable definitions to `variables.tf`:

```hcl
variable "location" {
  type        = string
  description = "Azure region for deployment"
  default     = "eastus2"
}

variable "vnet_cidr" {
  type        = list(string)
  description = "CIDR range for the Virtual Network"
  default     = ["10.50.0.0/16"]
}

variable "subnet_cidr" {
  type        = list(string)
  description = "CIDR range for the Subnet"
  default     = ["10.50.1.0/24"]
}
```

### What These Variables Do

* `location` → controls Azure region
* `vnet_cidr` → defines VNet address space
* `subnet_cidr` → defines Subnet address space

---

## Variable Types Overview

![Image](https://k21academy.com/wp-content/uploads/2024/04/Datatypes.webp)

![Image](https://i.sstatic.net/h7TFb.png)

![Image](https://k21academy.com/wp-content/uploads/2020/08/main.tf-file.png)

Terraform supports:

* `string`
* `number`
* `bool`
* `list`
* `map`
* `object`

---

## Step 3: Create the Main Terraform Configuration

Create a new file named **`main.tf`**.

### Terraform & Provider Configuration

```hcl
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
```

---

## Step 4: Create Network Resources Using Variables

### Virtual Network

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "xyz-vnet-${var.location}"
  location            = var.location
  resource_group_name = "rg-xyz-labs"
  address_space       = var.vnet_cidr
}
```

### Subnet (Implicit Dependency)

```hcl
resource "azurerm_subnet" "subnet" {
  name                 = "xyz-subnet-${var.location}"
  resource_group_name  = "rg-xyz-labs"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_cidr
}
```

---

## Implicit Dependency Flow

![Image](https://blog.jcorioland.io/images/terraform-implicit-explicit-dependencies-between-resources/graph-with-depends-on.jpg)

![Image](https://miro.medium.com/1%2AVMs5_1keJsBgdfRiIC_PTA.png)

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D500%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fl2535y1lh9lor9dyegrr.png)

Terraform automatically ensures:

```
Virtual Network → Subnet
```

---

## Step 5: Add Compute-Related Variables

Extend **`variables.tf`** with VM-specific variables:

```hcl
variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "admin_user" {
  type        = string
  description = "Admin username for VM"
}

variable "admin_password" {
  type        = string
  description = "Admin password for VM"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size"
  default     = "Standard_B1s"
}
```

---

## Step 6: Use Advanced Variable Types

### Map Variable (Region-Based Disk Selection)

```hcl
variable "disk_type_by_region" {
  type        = map(string)
  description = "Disk type per Azure region"

  default = {
    eastus2 = "Premium_LRS"
    centralus = "Standard_LRS"
  }
}
```

### Object Variable (OS Image)

```hcl
variable "os_image" {
  description = "Operating system image details"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
```

---

## Step 7: Create Network Interface

Add to **`main.tf`**:

```hcl
resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = "rg-xyz-labs"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

---

## Step 8: Create the Virtual Machine

```hcl
resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = "rg-xyz-labs"
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.vm_size

  storage_os_disk {
    name              = "osdisk-${var.vm_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = lookup(
      var.disk_type_by_region,
      var.location,
      "Standard_LRS"
    )
  }

  storage_image_reference {
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = var.admin_user
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
```

---

## VM Dependency Flow

![Image](https://blog.jcorioland.io/images/terraform-implicit-explicit-dependencies-between-resources/graph-with-depends-on.jpg)

![Image](https://azapril.dev/wp-content/uploads/2020/05/tf.png?w=640)

![Image](https://azure.github.io/Azure-Verified-Modules/images/usage/solution-development/avm-virtualmachine-example1-tf.png)

---

## Step 9: Provide Values Using `terraform.tfvars`

Create **`terraform.tfvars`**:

```hcl
vm_name        = "xyz-vm-01"
location       = "eastus2"
admin_user     = "xyzadmin"
admin_password = "StrongPassword@123"

os_image = {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
  version   = "latest"
}
```

Terraform automatically loads this file.

---

## Step 10: Create Output Values

Create **`outputs.tf`**:

```hcl
output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.nic.private_ip_address
}
```

---

## Output Flow

![Image](https://www.datocms-assets.com/2885/1611186902-output1.png)

![Image](https://www.devopsschool.com/blog/wp-content/uploads/2019/12/terraform-output-variable.jpg)

![Image](https://faultbucket.ca/wp-content/uploads/2020/11/plan2.png)

---

## Step 11: Deploy the Configuration

Run:

```bash
terraform init
terraform apply
```

Confirm with **yes**.

Terraform will:

* Create network resources
* Provision VM
* Display output values

---

## Summary

In this hands-on lab, you:

* Designed Terraform code using **variables**
* Used **string, list, map, and object** variable types
* Built reusable Azure infrastructure
* Created implicit dependencies automatically
* Supplied values using `terraform.tfvars`
* Exposed runtime data using outputs

This pattern is **production-ready** and forms the base for:

* Multi-environment deployments
* CI/CD pipelines
* Enterprise Terraform modules

---
