# 📘 Creating DRY Terraform Environments with Terragrunt in Azure

## 📌 Overview

Managing multiple Terraform environments (Production, Development, QA) by copying and modifying `.tf` files often leads to duplication, configuration drift, and human error.
This lab demonstrates how to use **Terragrunt** to follow **DRY (Don’t Repeat Yourself)** principles and create new environments by changing **only environment-specific values**.

Using Terragrunt with:

* Remote Terraform modules
* Centralized YAML configuration
* Environment inheritance

you can spin up new environments **quickly, safely, and consistently**.

---

## 🎯 Learning Objectives

By completing this lab, you will learn how to:

* Apply DRY principles to Terraform environments
* Use **Terragrunt** to minimize Terraform code
* Centralize environment configuration using YAML
* Reuse versioned Terraform modules
* Create a new environment by modifying a single file
* Deploy infrastructure across components with one command

---

## 🧰 Prerequisites

Ensure the following tools are available:

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
├── environment_vars.yaml
├── production
│   ├── rg
│   ├── network
│   └── server
└── development
    ├── rg
    ├── network
    └── server
```

### Design Highlights

* Each component (`rg`, `network`, `server`) contains **only `terragrunt.hcl`**
* No environment-specific `.tf` files
* All environment customization lives in **`environment_vars.yaml`**
* Terraform logic is reused via **remote modules**

---

## ⚙️ Centralized Environment Configuration

The `environment_vars.yaml` file contains all values that differ between environments.

### Example: `environment_vars.yaml`

```yaml
server_name: appserver-prod
vnet_address: 10.0.0.0/16
snet_address: 10.0.0.0/24
```

Changing this file is enough to create a **new environment**.

---

## 🧩 Root Terragrunt Configuration

The root `terragrunt.hcl` reads the YAML file and exposes values as locals.

```hcl
locals {
  env_vars = yamldecode(file("environment_vars.yaml"))
}
```

### Why This Matters

* Environment values are defined once
* Child configurations reuse them automatically
* Terraform code remains extremely small

---

## 🌐 Using Remote Terraform Modules

Each component references a **versioned remote Terraform module**.

### Example: `network/terragrunt.hcl`

```hcl
terraform {
  source = "git::https://github.com/example/terraform-azure-modules.git//network?ref=v1.0.0"
}

dependency "rg" {
  config_path = "../rg"
}

locals {
  env_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
}

inputs = {
  rg_name      = dependency.rg.outputs.rg_name
  rg_location  = dependency.rg.outputs.rg_location
  vnet_address = local.env_vars.vnet_address
  snet_address = local.env_vars.snet_address
}

include {
  path = find_in_parent_folders()
}
```

### Benefits

* Terraform logic is reusable and versioned
* No `main.tf` or `variables.tf` per environment
* Clean and maintainable infrastructure code

---

## 🔐 Authenticate with Azure

Before deploying infrastructure, authenticate with Azure:

```bash
az login
```

Verify the correct subscription is selected.

---

## 🚀 Creating a New Environment

To create a **Development** environment from **Production**:

```bash
cd terraformlab
cp -a production development
```

This copies the DRY Terragrunt configuration without duplicating Terraform code.

---

## ✏️ Updating Environment Values Only

Modify `development/environment_vars.yaml`:

```bash
sed -i 's/appserver-prod/appserver-dev/g' development/environment_vars.yaml
sed -i 's+10.0.0.0/16+10.1.0.0/16+g' development/environment_vars.yaml
sed -i 's+10.0.0.0/24+10.1.0.0/24+g' development/environment_vars.yaml
```

No Terraform files are changed.

---

## 🏗️ Deploy the New Environment

Move into the new environment and apply:

```bash
cd development
terragrunt run-all apply
```

### What Terragrunt Does

* Downloads remote modules into `.terragrunt-cache`
* Applies components in correct dependency order
* Creates separate Terraform state files
* Deploys the full environment with one command

---

## 🧹 Cleaning Up (Optional)

To destroy the environment:

```bash
terragrunt run-all destroy
```

⚠️ **Warning**
Use this only in lab or test environments.
Do not run against real production systems.

---

## ✅ Summary

In this lab, you learned how to:

* Create DRY Terraform environments using Terragrunt
* Centralize environment configuration in YAML
* Reuse versioned Terraform modules
* Spin up new environments by editing a single file
* Avoid Terraform code duplication and drift

This approach reflects **real-world enterprise Terraform + Terragrunt best practices**.

---
