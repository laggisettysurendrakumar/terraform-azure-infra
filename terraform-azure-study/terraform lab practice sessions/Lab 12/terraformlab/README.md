# 📘 Managing Terraform Remote State in Azure Using Terragrunt

## 📌 Overview

This lab demonstrates how to use **Terragrunt** to manage **Terraform remote state** in Azure while following **DRY (Don’t Repeat Yourself)** principles.
Instead of repeating backend configuration in every Terraform environment, Terragrunt allows defining it **once** and reusing it across multiple environments such as **Dev, QA, and Prod**.

---

## 🎯 Learning Objectives

By completing this lab, you will learn how to:

* Use **Terragrunt** as a wrapper around Terraform
* Centralize **Azure remote state configuration**
* Deploy Terraform infrastructure across **multiple environments**
* Automatically generate **environment-specific state files**
* Apply and destroy infrastructure using a **single command**

---

## 🧰 Prerequisites

Ensure the following tools are installed and configured:

* Azure CLI (`az`)
* Terraform
* Terragrunt
* Active Azure subscription with:

  * Resource Group
  * Storage Account
  * Blob Container for Terraform state

---

## 📁 Project Structure

```
terraformlab
├── terragrunt.hcl
├── dev
│   ├── terragrunt.hcl
│   └── main.tf
├── qa
│   ├── terragrunt.hcl
│   └── main.tf
└── prod
    ├── terragrunt.hcl
    └── main.tf
```

### Structure Explanation

* **Root `terragrunt.hcl`**

  * Contains shared remote state configuration
* **Environment folders (dev / qa / prod)**

  * Contain Terraform code
  * Inherit backend configuration from root

---

## 🔐 Step 1: Authenticate with Azure

Login to Azure using the CLI:

```bash
az login
```

Follow the instructions in the browser to authenticate and confirm subscription access.

---

## ⚙️ Step 2: Root Terragrunt Remote State Configuration

Open `terraformlab/terragrunt.hcl`:

```hcl
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateaccount123"
    container_name       = "calab"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}
```

### Key Points

* Remote state is defined **once**
* `${path_relative_to_include()}` automatically creates:

  * `dev/terraform.tfstate`
  * `qa/terraform.tfstate`
  * `prod/terraform.tfstate`

---

## 🧩 Step 3: Environment-Level Terragrunt Configuration

Each environment contains a minimal `terragrunt.hcl` file.

Example (`dev/terragrunt.hcl`):

```hcl
include {
  path = find_in_parent_folders()
}
```

This tells Terragrunt to:

* Load configuration from the parent directory
* Reuse the shared remote state settings

---

## 🏗️ Step 4: Terraform Configuration per Environment

Each environment has its own `main.tf`.

Example (`dev/main.tf`):

```hcl
terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = "dev-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = "eastus"
  resource_group_name = "rg-dev"
}
```

⚠️ The backend block is intentionally empty — Terragrunt injects backend configuration at runtime.

---

## 🚀 Step 5: Deploy All Environments

From the root directory (`terraformlab`), run:

```bash
terragrunt run-all apply
```

### What This Does

* Detects all child folders containing `terragrunt.hcl`
* Runs `terraform init` and `terraform apply` for each environment
* Uses separate remote state files automatically

---

## 📦 Remote State Layout in Azure Storage

After deployment, the blob container will contain:

```
calab/
 ├── dev/terraform.tfstate
 ├── qa/terraform.tfstate
 └── prod/terraform.tfstate
```

Each environment has:

* Its own isolated state
* Shared backend configuration
* No duplicated code

---

## 🧹 Step 6: Destroy All Resources (Optional)

To destroy all environments:

```bash
terragrunt run-all destroy
```

⚠️ **Warning**
This command should be used only in **labs, test, or QA environments**.
Avoid using it in real production systems.

---

## ✅ Summary

In this lab, you successfully:

* Implemented **DRY remote state management**
* Used **Terragrunt with Terraform in Azure**
* Deployed infrastructure across multiple environments
* Simplified backend configuration maintenance
* Applied and destroyed infrastructure using a single command

This approach is widely used in **enterprise-grade Terraform projects**.

---
