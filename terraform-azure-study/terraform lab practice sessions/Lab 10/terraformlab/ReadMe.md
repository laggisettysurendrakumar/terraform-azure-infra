## 📁 Folder Structure

```
terraformlab
├── main.tf
└── modules
    └── app-service
        ├── main.tf
        └── variables.tf
```

---

## ✅ 1️⃣ Root File: `terraformlab/main.tf`

```hcl
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
```

---

## ✅ 2️⃣ Module File: `modules/app-service/main.tf`

```hcl
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
```

---

## ✅ 3️⃣ Module Variables: `modules/app-service/variables.tf`

```hcl
variable "plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "resource_group" {
  type        = string
  description = "Azure Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region for deployment (optional)"
  default     = ""
}
```

---

## ▶️ How to Run (Commands)

```bash
az login
cd terraformlab
terraform init
terraform apply
```

### Expected Result

* `asp-default-east` → **East US** (default)
* `asp-custom-west` → **West US** (explicit)

---

## 🎯 Key Concept Used (Interview Important)

```hcl
condition ? true_value : false_value
```

Example:

```hcl
location = var.location != "" ? var.location : "eastus"
```

This is **Terraform conditional logic (ternary operator)**.

---
