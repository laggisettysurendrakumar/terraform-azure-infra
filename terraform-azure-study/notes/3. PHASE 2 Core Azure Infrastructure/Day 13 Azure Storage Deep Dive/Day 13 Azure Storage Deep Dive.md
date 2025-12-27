# 🟡 Day 13 – Azure Storage Deep Dive (Terraform Focus)

Today you will master:

* **Blob Containers**
* **Secure Access**
* **Real-world Use Cases**
* **Terraform best practices**

---

## 1️⃣ Azure Storage – Big Picture

### 🔹 What is Azure Storage?

Azure Storage is a **highly available, durable cloud storage service** used to store:

* Files
* Application data
* Logs
* Backups
* Terraform state files

---

### 🔹 Storage Account Types (High Level)

| Service      | Purpose                                    |
| ------------ | ------------------------------------------ |
| Blob Storage | Unstructured data (files, images, backups) |
| File Share   | File system (lift & shift)                 |
| Queue        | Messaging                                  |
| Table        | NoSQL key-value                            |

👉 **Today’s focus: Blob Storage**

---

### 🔹 Real-Life Analogy

* **Storage Account** → Warehouse
* **Blob Container** → Shelves
* **Blobs** → Boxes/files

---

## 2️⃣ Storage Account (Foundation)

### 🔹 What is a Storage Account?

A **Storage Account** is the **top-level container** for all Azure storage services.

---

### 🔹 Key Properties

| Property     | Meaning            |
| ------------ | ------------------ |
| account_tier | Standard / Premium |
| replication  | LRS / GRS / ZRS    |
| access_tier  | Hot / Cool         |

---

### 🔹 Terraform Example – Storage Account

```hcl
resource "azurerm_storage_account" "sa" {
  name                     = "stterraformdev01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

---

### 🔹 Replication Options (Interview Favorite)

| Type | Meaning          |
| ---- | ---------------- |
| LRS  | Same datacenter  |
| ZRS  | Multiple zones   |
| GRS  | Different region |

👉 **LRS** → Dev
👉 **ZRS / GRS** → Prod

---

## 3️⃣ Blob Containers (CORE TOPIC)

### 🔹 What is a Blob Container?

A **Blob Container** is a **logical grouping of blobs** inside a Storage Account.

Used to store:

* Files
* Images
* Logs
* Terraform state
* Backups

---

### 🔹 Terraform Example – Blob Container

```hcl
resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}
```

---

### 🔹 Container Access Levels

| Level     | Meaning                   |
| --------- | ------------------------- |
| private   | Only authorized access    |
| blob      | Public read for blobs     |
| container | Public read for container |

👉 **Best practice:** Always use `private`

---

### 🔹 Real-Life Analogy

* **Container** → Folder
* **Blob** → File

---

## 4️⃣ Secure Access (MOST IMPORTANT)

Security is **THE MOST IMPORTANT** part of Azure Storage.

---

## 🔐 4.1 Access Keys (Basic but Risky)

### 🔹 What are Access Keys?

Storage account provides:

* **Primary key**
* **Secondary key**

Anyone with the key = **full access**

❌ Not recommended for production

---

### 🔹 Terraform Example (Key-based – NOT recommended)

```hcl
backend "azurerm" {
  storage_account_name = "stterraformdev01"
  container_name       = "tfstate"
  key                  = "terraform.tfstate"
}
```

---

## 🔐 4.2 Shared Access Signature (SAS)

### 🔹 What is SAS?

A **temporary access token** with:

* Expiry time
* Limited permissions

Better than access keys, but still risky if leaked.

---

### 🔹 When to Use SAS?


✔ Short-term access

✔ Automation scripts

❌ Not ideal for Terraform long-term state

---

## 🔐 4.3 Azure AD + RBAC (BEST PRACTICE)

### 🔹 Best & Secure Method

Use:

* Azure AD identity
* RBAC roles
* No keys, no secrets

---

### 🔹 Recommended Roles

| Role                          | Use              |
| ----------------------------- | ---------------- |
| Storage Blob Data Contributor | Read/write blobs |
| Storage Blob Data Reader      | Read only        |

---

### 🔹 Assign Role (Example)

```bash
az role assignment create \
  --assignee <CLIENT_ID> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/<RG>/providers/Microsoft.Storage/storageAccounts/<SA_NAME>
```

👉 **This is production-grade security**

---

## 5️⃣ Terraform Remote State (REAL USE CASE)

### 🔹 Why Use Azure Storage for Terraform State?

Terraform state must be:

* Centralized
* Secure
* Locked
* Recoverable

Azure Blob Storage provides:

✔ State locking

✔ RBAC

✔ Durability

---

### 🔹 Backend Configuration Example

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "stterraformprod01"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

---

### 🔹 Why This Matters

Without remote state:

❌ Team conflicts

❌ State loss

❌ Broken infra

---

## 6️⃣ Common Azure Storage Use Cases

### 🔹 Application Use Cases

| Use Case    | Example       |
| ----------- | ------------- |
| App uploads | Images, PDFs  |
| Logs        | App / VM logs |
| Backups     | DB backups    |
| CI/CD       | Artifacts     |
| Terraform   | Remote state  |

---

### 🔹 Enterprise Scenario

* One storage account
* Multiple containers:

  * `tfstate`
  * `app-logs`
  * `backups`

---

## 7️⃣ Best Practices (MUST FOLLOW)


✔ Use private containers

✔ Enable RBAC (no keys)

✔ Separate storage per environment

✔ Use GRS/ZRS for prod

✔ Never commit access keys

✔ Rotate secrets if used

---

## ❌ Common Mistakes (VERY IMPORTANT)


❌ Public containers

❌ Using access keys everywhere

❌ Same storage for dev & prod

❌ Deleting storage with tfstate

❌ Hardcoding credentials

---

## 🧠 Interview Questions (Day 13)

**Q: Why Azure Blob Storage for Terraform state?**
Because it provides durability, locking, and RBAC.

**Q: Difference between container and blob?**
Container is a folder, blob is a file.

**Q: Best way to secure storage access?**
Azure AD + RBAC.

**Q: LRS vs GRS?**
LRS is local, GRS replicates to another region.

---

## 🎯 You Are READY When You Can


✅ Create Storage Account & Container

✅ Secure storage using RBAC

✅ Use storage for Terraform remote state

✅ Explain storage security clearly

---

