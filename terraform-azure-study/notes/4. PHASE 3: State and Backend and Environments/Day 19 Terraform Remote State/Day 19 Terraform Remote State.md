# 🟡 Day 19 – Terraform Remote State (Azure)

**(Azure Storage Backend • State Locking • Security)**

Terraform **state** is the single source of truth.
Remote state makes Terraform **team-safe, secure, and production-ready**.

---

## 🧠 Why Remote State Is Mandatory

### ❌ Local State Problems

* State stored on one laptop
* Lost when system crashes
* Team conflicts
* No locking → corruption

### ✅ Remote State Benefits

✔ Centralized state

✔ Team collaboration

✔ State locking

✔ Security & RBAC

✔ Disaster recovery

👉 **Local state is NOT acceptable in production**

---

## 1️⃣ Terraform State – Quick Refresher

### 🔹 What Is `terraform.tfstate`?

* JSON file that maps:

  * Terraform resources
  * Azure resources
* Used to:

  * Detect changes
  * Plan updates
  * Avoid duplicates

👉 Terraform **trusts state more than Azure**

---

### 🔹 State Lifecycle

```text
terraform apply
     ↓
State updated
     ↓
terraform plan
     ↓
State compared
```

---

## 2️⃣ Azure Storage Backend (CORE TOPIC)

### 🔹 What Is a Backend?

A **backend** defines:

* Where Terraform state is stored
* How it is locked
* How it is accessed

---

### 🔹 Why Azure Storage Backend?

Azure Blob Storage provides:
✔ Durability
✔ High availability
✔ Built-in locking
✔ RBAC support

👉 **Best backend for Azure Terraform**

---

## 3️⃣ Azure Storage Backend Architecture

```text
Terraform
   ↓
Azure Storage Account
   ↓
Blob Container
   ↓
terraform.tfstate
```

---

## 4️⃣ Create Backend Resources (One-Time)

### 🔹 Recommended Setup (Manual / Bootstrap)

Terraform **cannot manage its own backend initially**.

Create these **once**:

* Resource Group
* Storage Account
* Blob Container

---

### 🔹 Example (Azure CLI)

```bash
az group create \
  --name rg-terraform-state \
  --location eastus
```

```bash
az storage account create \
  --name stterraformstate01 \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS
```

```bash
az storage container create \
  --name tfstate \
  --account-name stterraformstate01
```

---

## 5️⃣ Configure Azure Storage Backend (Terraform)

### 🔹 Backend Configuration

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate01"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

---

### 🔹 What Each Field Means

| Field                | Purpose         |
| -------------------- | --------------- |
| resource_group_name  | RG of storage   |
| storage_account_name | Storage account |
| container_name       | Blob container  |
| key                  | State file name |

---

### 🔹 Initialize Backend

```bash
terraform init
```

Terraform will ask:

```
Do you want to migrate existing state?
```

👉 Answer **yes**

---

## 6️⃣ State Locking (CRITICAL)

### 🔹 What Is State Locking?

State locking prevents:

* Two people running `terraform apply` at the same time
* State corruption

---

### 🔹 How Azure Does Locking

* Uses **Blob Lease**
* Only **one operation** can hold the lock

---

### 🔹 What Happens During Lock

```text
User A → terraform apply → lock acquired
User B → terraform apply → ❌ locked
```

User B sees:

```
Error: state blob is already locked
```

✔ This is GOOD

✔ This protects infrastructure

---

### 🔹 Force Unlock (RARE)

```bash
terraform force-unlock <LOCK_ID>
```

⚠️ Use only if:

* Process crashed
* You are sure no one else is running Terraform

---

## 7️⃣ Remote State Security (MOST IMPORTANT)

---

## 🔐 7.1 Authentication (BEST PRACTICE)

Terraform authenticates using:

* Service Principal
* Azure AD
* RBAC

❌ No access keys in code

---

## 🔐 7.2 RBAC for Storage Access

### 🔹 Recommended Roles

| Role                          | Use                  |
| ----------------------------- | -------------------- |
| Storage Blob Data Contributor | Terraform read/write |
| Storage Blob Data Reader      | Read-only            |

---

### 🔹 Assign Role (Example)

```bash
az role assignment create \
  --assignee <CLIENT_ID> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/rg-terraform-state/providers/Microsoft.Storage/storageAccounts/stterraformstate01
```

---

## 🔐 7.3 Secure Backend Access

✔ Private container

✔ Azure AD auth

✔ No public access

✔ No hard-coded secrets

---

## 8️⃣ Multiple Environments – State Strategy

### 🔹 Best Practice: Separate State Per Environment

```text
tfstate/
├── dev.terraform.tfstate
├── test.terraform.tfstate
└── prod.terraform.tfstate
```

---

### 🔹 Example

```hcl
key = "prod.terraform.tfstate"
```

👉 Prevents:

* Dev destroying prod
* Accidental cross-env changes

---

## 9️⃣ Using Remote State Output (ADVANCED)

### 🔹 Read Outputs from Another State

```hcl
data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate01"
    container_name       = "tfstate"
    key                  = "network.terraform.tfstate"
  }
}
```

Use it:

```hcl
subnet_id = data.terraform_remote_state.network.outputs.subnet_id
```

✔ Enables multi-team Terraform

✔ Common in enterprises

---

## ❌ Common Mistakes (VERY IMPORTANT)

❌ Storing state locally in prod

❌ Using storage access keys

❌ Same state for all environments

❌ Deleting backend resources

❌ Manual state file edits

---

## 🧠 Interview Questions (Day 19)

**Q: Why remote state is required?**
For collaboration, locking, and security.

**Q: How does Terraform lock state in Azure?**
Using blob lease.

**Q: What happens if two applies run together?**
Second apply is blocked.

**Q: How do you secure Terraform state?**
Azure AD + RBAC + private storage.

---

## 🎯 You Are READY When You Can

✅ Configure Azure backend

✅ Migrate local → remote state

✅ Explain state locking clearly

✅ Secure state using RBAC

---
