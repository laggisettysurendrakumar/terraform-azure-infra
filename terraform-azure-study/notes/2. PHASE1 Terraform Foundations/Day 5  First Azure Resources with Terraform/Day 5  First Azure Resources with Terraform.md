# **Day 5 – First Azure Resources with Terraform**

🎯 **Goal of Day-5**
By the end of this day, you will:

* Create your **first real Azure resources** using Terraform
* Understand **Resource Group** and **Storage Account** deeply
* Clearly understand how the **AzureRM provider** works

---

## **1️⃣ Understand AzureRM Provider (Foundation)** ⭐⭐⭐

### 📌 What is AzureRM Provider?

The **AzureRM provider** allows Terraform to interact with **Microsoft Azure** APIs.

Terraform itself cannot create Azure resources directly.
It uses the AzureRM provider as a **bridge**.

```text
Terraform Core → AzureRM Provider → Azure Resource Manager (ARM) → Azure
```

---

### 🔹 Why AzureRM Provider is Important

* Translates Terraform code into Azure API calls
* Handles authentication (Service Principal / CLI)
* Manages lifecycle of Azure resources

---

### 🔹 Provider Configuration (Basic)

```hcl
provider "azurerm" {
  features {}
}
```

📌 `features {}` is mandatory (even if empty).

---

### 🔐 Authentication Reminder

AzureRM provider automatically reads credentials from:

* Environment variables (`ARM_CLIENT_ID`, etc.)
* Azure CLI login

✅ This is why **Day-2 setup was required**.

---

## **2️⃣ Azure Resource Group (Concept + Practice)** ⭐⭐

### 📌 What is a Resource Group?

A **Resource Group (RG)** is a **logical container** for Azure resources.

Examples:

* Storage Accounts
* Virtual Machines
* VNets

---

### 🧠 Key Rules


✔ All Azure resources must belong to a resource group

✔ Resource Group defines **location (region)**

✔ Deleting RG deletes **everything inside**


---

### 🔹 Terraform Code: Resource Group

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-day5-demo"
  location = "Central India"
}
```

---

### 🧪 What Terraform Does

* Calls Azure ARM API
* Creates a resource group
* Stores its ID in state file

---

## **3️⃣ Azure Storage Account (Concept + Practice)** ⭐⭐⭐

### 📌 What is Azure Storage Account?

A **Storage Account** provides:

* Blob storage
* File shares
* Queues
* Tables

Used for:

* Terraform remote state
* App storage
* Backups

---

![Image](https://learn.microsoft.com/en-us/security/zero-trust/media/secure-storage/azure-infra-storage-network-2.svg?utm_source=chatgpt.com)

![Image](https://k21academy.com/wp-content/uploads/2020/10/Diagram-02-1024x531.png?utm_source=chatgpt.com)

![Image](https://1.bp.blogspot.com/-6sXQH9q-Eqw/X1zewfmDshI/AAAAAAAAcrI/bPwjfm5ePcc-X6azXJstT8P-vvBOnBkBACLcBGAsYHQ/s1004/1.png?utm_source=chatgpt.com)

---

### 🔹 Storage Account Naming Rules ⚠️

Azure enforces strict rules:

* Lowercase only
* 3–24 characters
* Globally unique
* No special characters

---

### 🔹 Terraform Code: Storage Account

```hcl
resource "azurerm_storage_account" "sa" {
  name                     = "day5storagedemo01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

---

### 🧠 Attribute Explanation

| Attribute                  | Meaning                      |
| -------------------------- | ---------------------------- |
| `name`                     | Globally unique storage name |
| `resource_group_name`      | Parent RG                    |
| `location`                 | Azure region                 |
| `account_tier`             | Standard / Premium           |
| `account_replication_type` | LRS / GRS / ZRS              |

---

### 🔗 Dependency Handling

Notice:

```hcl
resource_group_name = azurerm_resource_group.rg.name
```

➡️ Terraform automatically:

* Creates Resource Group first
* Then creates Storage Account

No manual dependency needed ✅

---

## **4️⃣ Complete Day-5 End-to-End Example** ⭐⭐⭐

### 📁 Project Structure

```text
day-05-first-azure-resource/
├── provider.tf
├── main.tf
├── outputs.tf
```

---

### 🔹 `provider.tf`

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}
```

---

### 🔹 `main.tf`

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-day5-demo"
  location = "Central India"
}

resource "azurerm_storage_account" "sa" {
  name                     = "day5storagedemo01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

---

### 🔹 `outputs.tf`

```hcl
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}
```

---

### 🔹 Run Commands

```bash
terraform init
terraform plan
terraform apply
```

✅ Resource Group & Storage Account created successfully 🎉

---

## **5️⃣ Verify in Azure Portal**

Steps:

1. Login to Azure Portal
2. Open **Resource Groups**
3. Select `rg-day5-demo`
4. Verify Storage Account exists

---

## **6️⃣ Common Errors & Fixes** ⚠️

### ❌ Storage name already exists


✔ Use unique name (add random suffix)

---

### ❌ Authentication failed


✔ Re-check Service Principal

✔ Ensure correct subscription is set

---

### ❌ Location mismatch


✔ Storage location must match RG location (recommended)

---

## **7️⃣ GitHub & OneNote Usage**

### 📘 GitHub

* Use this as `README.md`
* Keep one folder per day
* Commit `.terraform.lock.hcl`

### 📝 OneNote

* Section: **Terraform with Azure**
* Page: **Day-5 – First Azure Resource**
* Subpages:

  * AzureRM Provider
  * Resource Group
  * Storage Account

---

## **Day-5 Summary (Revision Ready)**


✔ AzureRM provider connects Terraform to Azure

✔ Resource Group is the base container

✔ Storage Account is globally unique

✔ Terraform manages dependencies automatically

✔ Real Azure resources created successfully

---

