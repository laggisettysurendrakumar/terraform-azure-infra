# 📘 Passing Outputs Between Terraform Modules Using Terragrunt in Azure

## 📌 Overview

In large Terraform projects, managing all infrastructure in a single state file can become risky and hard to maintain. Some components, such as **Resource Groups and Networks**, change infrequently, while others like **Servers or Virtual Machines** change more often.

This lab demonstrates how **Terragrunt** can be used to:

* Split infrastructure into **multiple Terraform states**
* Define **dependencies** between components
* **Pass outputs** from one module to another
* Deploy infrastructure in the **correct order**

---

## 🎯 Learning Objectives

After completing this lab, you will be able to:

* Separate Terraform state by infrastructure component
* Use **Terragrunt dependency blocks**
* Pass outputs between Terraform modules
* Automatically manage deployment order
* Deploy a complete Azure environment with a single command

---

## 🧰 Prerequisites

Make sure the following tools are available:

* Azure CLI (`az`)
* Terraform
* Terragrunt
* Active Azure subscription (Lab or personal)
* Azure Storage Account for Terraform remote state

---

## 📁 Project Structure

```
terraformlab
├── terragrunt.hcl
├── rg
│   ├── terragrunt.hcl
│   └── main.tf
├── network
│   ├── terragrunt.hcl
│   └── main.tf
└── server
    ├── terragrunt.hcl
    └── main.tf
```

### Folder Responsibilities

| Folder    | Purpose                                   |
| --------- | ----------------------------------------- |
| `rg`      | Creates the Resource Group                |
| `network` | Creates Virtual Network and Subnet        |
| `server`  | Creates Virtual Machine                   |
| Root      | Shared provider and backend configuration |

Each folder maintains its **own Terraform state**.

---

## 🔧 Root Terragrunt Configuration

The root `terragrunt.hcl` keeps the configuration **DRY** and applies it to all child modules.

### `terraformlab/terragrunt.hcl`

```hcl
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
EOF
}
```

### Why This Is Used

* Automatically generates `provider.tf` in every module
* Keeps provider and backend configuration consistent
* Avoids duplication across folders

---

## 🧩 Resource Group Module (Base Component)

The **Resource Group** module has **no dependencies** and produces outputs.

### Example Outputs

```hcl
output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "rg_location" {
  value = azurerm_resource_group.rg.location
}
```

These outputs will be consumed by other modules.

---

## 🌐 Network Module – Consuming RG Outputs

The Network module depends on the Resource Group.

### `network/terragrunt.hcl`

```hcl
dependency "rg" {
  config_path = "../rg"
}

inputs = {
  rg_name     = dependency.rg.outputs.rg_name
  rg_location = dependency.rg.outputs.rg_location
}

include {
  path = find_in_parent_folders()
}
```

### What This Does

* Waits for Resource Group to be created
* Reads outputs from RG state
* Passes values as input variables to Terraform

---

## 🖥️ Server Module – Multiple Dependencies

The Server module depends on both **Resource Group** and **Network**.

### `server/terragrunt.hcl`

```hcl
dependency "rg" {
  config_path = "../rg"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  rg_name     = dependency.rg.outputs.rg_name
  rg_location = dependency.rg.outputs.rg_location
  subnet_id   = dependency.network.outputs.subnet_id
}

include {
  path = find_in_parent_folders()
}
```

### Why Multiple Dependencies?

A Virtual Machine requires:

* Resource Group name
* Location
* Subnet ID

Terragrunt ensures all dependencies are created **before** the server module runs.

---

## 🔐 Authenticate with Azure

Login to Azure before running Terragrunt:

```bash
az login
```

Confirm the correct subscription is selected.

---

## 🚀 Deploy All Components

From the root directory (`terraformlab`):

```bash
terragrunt run-all apply
```

### What Happens Internally

1. Resource Group is created first
2. Outputs from RG are read
3. Network is created using RG outputs
4. Subnet ID is captured
5. Server is deployed using RG and Network outputs
6. Separate state files are maintained

All components are deployed in the correct order automatically.

---

## 🛠️ Updating a Single Component

After the initial deployment:

* To modify only the server:

```bash
cd server
terragrunt apply
```

This avoids unnecessary changes to other components.

---

## 🧹 Destroying Infrastructure (Optional)

To destroy all components:

```bash
terragrunt run-all destroy
```

⚠️ **Warning**
Use this only in lab or test environments.
Do not run against real production systems.

---

## ✅ Summary

In this lab, you learned how to:

* Split infrastructure into **separate Terraform states**
* Use **Terragrunt dependency blocks**
* Pass outputs between Terraform modules
* Control deployment order automatically
* Deploy complex Azure infrastructure safely

This approach reflects **real-world enterprise Terraform + Terragrunt practices**.

---

