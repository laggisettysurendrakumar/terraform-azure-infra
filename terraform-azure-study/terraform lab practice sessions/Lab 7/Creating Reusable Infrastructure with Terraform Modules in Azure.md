# Creating Reusable Infrastructure with Terraform Modules in Azure

## Introduction

As Terraform projects grow, writing the same resource definitions again and again quickly becomes inefficient. Terraform solves this problem using **modules**.

A **module** is a reusable, self-contained Terraform configuration that represents a logical unit of infrastructure.

For example:

* A module for **Storage Accounts**
* A module for **Virtual Machines**
* A module for **Networking**

These modules can be reused like **building blocks** across multiple environments such as **dev, test, and prod**.

In this lab, you will:

* Create a **custom Terraform module**
* Use the module multiple times
* Deploy multiple Azure Storage Accounts using a single module

---

## Why Terraform Modules Matter

![Image](https://www.datocms-assets.com/2885/1583259995-terraform-modules.svg)

![Image](https://i0.wp.com/thomasthornton.cloud/wp-content/uploads/2022/06/reusable-terraform-modules-terraform-full.jpg?fit=691%2C571\&ssl=1)

![Image](https://miro.medium.com/0%2AwwmllWIGPoYEvm7u.jpg)

### Benefits of Modules

* ✅ Code reuse
* ✅ Consistent infrastructure
* ✅ Easier maintenance
* ✅ Cleaner Terraform configurations
* ✅ Team-friendly structure

---

## Lab Objective

In this lab, you will:

* Create a reusable **Storage Account module**
* Parameterize it using variables
* Expose outputs from the module
* Call the module multiple times from a root configuration

---

## Step 1: Create Module Folder Structure

Inside your `terraformlab` directory, create the following structure:

```
terraformlab/
│── main.tf
└── modules/
    └── storage-account/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

This follows Terraform **best-practice module layout**.

---

## Terraform Module Structure Explained

![Image](https://media.beehiiv.com/cdn-cgi/image/fit%3Dscale-down%2Cformat%3Dauto%2Conerror%3Dredirect%2Cquality%3D80/uploads/asset/file/a70941e1-5fb2-4a29-a70b-a671150e9298/directory_2.png?t=1730702773)

![Image](https://www.cloudbolt.io/wp-content/uploads/terraform-best-practicies-1024x654-1.png)

![Image](https://developer.hashicorp.com/_next/image?dpl=dpl_49a7Hu4U32nF9WMVkTW1abTQpNAa\&q=75\&url=https%3A%2F%2Fcontent.hashicorp.com%2Fapi%2Fassets%3Fproduct%3Dtutorials%26version%3Dmain%26asset%3Dpublic%252Fimg%252Fterraform%252Frecommended-patterns%252Farch-diag-overview.png%26width%3D1763%26height%3D961\&w=3840)

---

## Step 2: Define the Module – `main.tf`

Create **`modules/storage-account/main.tf`**

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### What This Does

* Defines a **Storage Account**
* Uses **variables instead of hardcoded values**
* Keeps the module environment-agnostic

---

## Step 3: Define Module Inputs – `variables.tf`

Create **`modules/storage-account/variables.tf`**

```hcl
variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the storage account"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westus"
}
```

### Why Variables Are Important

* Allow customization per environment
* Prevent duplication
* Make the module reusable

---

## Module Input Flow

![Image](https://k21academy.com/wp-content/uploads/2020/08/Terraform-IaC_BlogImage.png)

![Image](https://jayendrapatil.com/wp-content/uploads/2020/11/Terraform_Workflow.png)

![Image](https://i0.wp.com/wahlnetwork.com/wp-content/uploads/2020/04/image-19.png?fit=1038%2C658\&ssl=1)

---

## Step 4: Define Module Outputs – `outputs.tf`

Create **`modules/storage-account/outputs.tf`**

```hcl
output "storage_account_primary_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}
```

### Why Outputs Matter

* Share values with the root module
* Enable chaining resources
* Support advanced architectures

---

## Terraform Module Output Flow

![Image](https://www.datocms-assets.com/2885/1611186902-output1.png)

![Image](https://www.cloudbolt.io/wp-content/uploads/img3-1024x902-1.png)

![Image](https://devtodevops.com/_devtodevops/Terraform-Use-Output-from-Another-Module.BMrn2Rjt.png)

---

## Step 5: Create Root Terraform Configuration

Now create **`main.tf`** in the **root `terraformlab` directory**.

```hcl
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

# Storage Account - Dev
module "storage_dev" {
  source               = "./modules/storage-account"
  storage_account_name = "xyzstdev001"
  resource_group_name  = "rg-terraform-modules"
  location             = "westus"
}

# Storage Account - Test
module "storage_test" {
  source               = "./modules/storage-account"
  storage_account_name = "xyzsttest001"
  resource_group_name  = "rg-terraform-modules"
  location             = "westus"
}
```

---

## How Module Reuse Works

![Image](https://i0.wp.com/thomasthornton.cloud/wp-content/uploads/2022/06/reusable-terraform-modules-terraform-full.jpg?fit=691%2C571\&ssl=1)

![Image](https://miro.medium.com/0%2APgKqKDKz8vQ5xhPs.png)

![Image](https://developer.hashicorp.com/_next/image?dpl=dpl_GobHkgKRgfw651r6XDhTB3t9RkQm\&q=75\&url=https%3A%2F%2Fcontent.hashicorp.com%2Fapi%2Fassets%3Fproduct%3Dtutorials%26version%3Dmain%26asset%3Dpublic%252Fimg%252Fterraform%252Frecommended-patterns%252Farch-diag-overview.png%26width%3D1763%26height%3D961\&w=3840)

Terraform:

* Loads the module once
* Applies it **multiple times**
* Creates **separate resources** for each call

---

## Step 6: Initialize Terraform

From the `terraformlab` directory:

```bash
terraform init
```

Terraform will:

* Download Azure provider
* Initialize the local module
* Prepare the working directory

---

## Terraform Init with Modules

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/02/terraform-init-command-terminal-output.png?resize=400%2C242\&ssl=1)

![Image](https://azapril.dev/wp-content/uploads/2020/03/module.png?w=1024)

![Image](https://opengraph.githubassets.com/9a69d00b7adda29c109f75f4ff5a0d7269386d0b413cbbe67a37be1984243241/hashicorp/terraform/issues/30011)

---

## Step 7: Apply the Configuration

Run:

```bash
terraform apply
```

Confirm with **yes**.

Terraform will:

* Call the module twice
* Create **two Storage Accounts**
* Use the same module code

---

## Deployment Result (Visual)

![Image](https://learn.microsoft.com/en-us/azure/storage/common/media/classic-account-migration-process/storage-architecture-diagram.png)

![Image](https://i0.wp.com/thomasthornton.cloud/wp-content/uploads/2023/10/image.png?fit=574%2C527\&ssl=1)

![Image](https://i.sstatic.net/HUkbq.png)

---

## Key Concepts to Remember

* Terraform modules are **just Terraform code**
* Modules:

  * Accept **inputs**
  * Produce **outputs**
* Same module → multiple environments
* Root configuration orchestrates modules

---

## Best Practices for Terraform Modules

* Keep modules **small and focused**
* Avoid environment-specific values inside modules
* Use variables for flexibility
* Version modules when shared via Git or Registry
* Never hardcode secrets

---

## Summary

In this lab, you:

* Created a reusable Terraform module
* Parameterized it using variables
* Exposed outputs securely
* Reused the module to deploy multiple Azure Storage Accounts
* Learned how modules improve scalability and maintainability

Terraform modules are a **foundational skill** for:

* Enterprise Terraform
* Team collaboration
* CI/CD pipelines
* Multi-environment infrastructure

---
