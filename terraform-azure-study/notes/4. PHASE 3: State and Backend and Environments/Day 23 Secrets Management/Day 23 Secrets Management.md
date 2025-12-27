# 🟡 Day 23 – Secrets Management

**(Azure Key Vault • Avoid Hard-Coded Secrets)**

Secrets management answers three questions:

* **Where are secrets stored?**
* **Who can access them?**
* **How are they rotated & audited?**

---

## 🧠 What Is a Secret?

A **secret** is any sensitive value, such as:

* Passwords (DB / VM)
* API keys
* Client secrets (Service Principal)
* Certificates
* Connection strings

👉 **If it grants access, it’s a secret.**

---

## 1️⃣ Why Hard-Coding Secrets Is Dangerous

### ❌ What NOT to Do

```hcl
admin_password = "Password@123"
client_secret  = "abcd-1234"
```

### 🚨 Risks

* Leaked via Git
* Exposed in logs
* Visible in state files
* Impossible to rotate safely

👉 **One leaked secret = compromised cloud**

---

## 2️⃣ Azure Key Vault – The Right Way

### 🔹 What Is Azure Key Vault?

**Azure Key Vault** is a secure service to store:

* Secrets
* Keys
* Certificates

Features:
✔ Encryption at rest

✔ Azure AD authentication

✔ RBAC / access policies

✔ Auditing & rotation

---

### 🔹 Real-Life Analogy

* **Key Vault** → Bank locker 🔐
* **Secrets** → Gold & documents
* Only authorized people can open it

---

## 🔍 Visual: Azure Key Vault Concept

![Image](https://learn.microsoft.com/en-us/azure/key-vault/media/key-vault-whatis/azurekeyvault_overview.png)

![Image](https://learn.microsoft.com/en-us/azure/key-vault/media/authentication/authentication-flow.png)

![Image](https://miro.medium.com/0%2AS4bSrSzV66HEcKXG.png)

---

## 3️⃣ Create Azure Key Vault (Terraform)

### 🔹 Terraform – Key Vault

```hcl
resource "azurerm_key_vault" "kv" {
  name                = "kv-terraform-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled  = true
}
```

✔ Soft delete protects from accidental deletion

✔ Purge protection is **recommended for prod**

---

## 4️⃣ Store Secrets in Key Vault

### 🔹 Terraform – Store a Secret

```hcl
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  value        = var.vm_admin_password
  key_vault_id = azurerm_key_vault.kv.id
}
```

⚠️ Secret value comes from **variable**, not code

---

### 🔹 Variable Marked as Sensitive

```hcl
variable "vm_admin_password" {
  type      = string
  sensitive = true
}
```

---

## 5️⃣ Read Secrets from Key Vault (MOST IMPORTANT)

### 🔹 Terraform Data Source – Read Secret

```hcl
data "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  key_vault_id = azurerm_key_vault.kv.id
}
```

---

### 🔹 Use It in a Resource

```hcl
admin_password = data.azurerm_key_vault_secret.vm_password.value
```

✔ Secret never hard-coded

✔ Centralized management

✔ Easy rotation

---

## 🔍 Visual: Terraform ↔ Key Vault Flow

![Image](https://miro.medium.com/0%2AS4bSrSzV66HEcKXG.png)

![Image](https://opengraph.githubassets.com/04bbc8df4d389d30a3ec3702af8c11e0be1cdd50d80547fa4752ebfc8af9ff28/getindata/terraform-azurerm-keyvault-secret-data-source)

![Image](https://skundunotes.com/wp-content/uploads/2023/04/74-image-1.png)

---

## 6️⃣ Access Control – Who Can Read Secrets?

### 🔹 Best Practice: Azure AD + RBAC

Assign **minimum required role**.

#### Common Roles

| Role                    | Purpose      |
| ----------------------- | ------------ |
| Key Vault Secrets User  | Read secrets |
| Key Vault Administrator | Full control |

---

### 🔹 Assign Role (Example)

```bash
az role assignment create \
  --assignee <CLIENT_ID> \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/<RG>/providers/Microsoft.KeyVault/vaults/kv-terraform-dev
```

👉 Terraform Service Principal needs **read**, not admin.

---

## 7️⃣ Terraform State & Secrets (CRITICAL)

### ⚠️ Important Truth

Even if you use Key Vault:

* **Secret values may appear in Terraform state**

---

### 🔹 How to Reduce Risk

✔ Use **remote state** (Azure Storage)

✔ Secure state with **RBAC**

✔ Restrict who can read state

✔ Separate prod state

👉 **Never commit state files**

---

## 8️⃣ CI/CD + Key Vault (REAL WORLD)

### 🔹 Common Pattern

1. Secrets stored in Key Vault
2. CI/CD identity (SP / Managed Identity)
3. Terraform reads secrets at runtime

---

### 🔹 Even Better (Advanced)

* Use **Managed Identity**
* No secrets at all
* Azure handles identity

---

## 9️⃣ Recommended Secrets Strategy (SUMMARY)

| Area           | Recommendation   |
| -------------- | ---------------- |
| Storage        | Azure Key Vault  |
| Access         | Azure AD + RBAC  |
| Terraform vars | Sensitive        |
| State          | Remote backend   |
| CI/CD          | Managed Identity |

---

## ❌ Common Mistakes (VERY IMPORTANT)

❌ Hard-coding secrets

❌ Committing `.tfvars` with passwords

❌ Giving Key Vault admin to Terraform

❌ No rotation policy

❌ Public Key Vault access

---

## 🧠 Interview Questions (Day 23)

**Q: Why not store secrets in Git?**
Because Git is not a secure secret store.

**Q: How does Terraform read secrets securely?**
Using Azure Key Vault data sources.

**Q: Do secrets appear in Terraform state?**
Yes—state must be secured.

**Q: Best practice for prod secrets?**
Key Vault + RBAC + Managed Identity.

---

## 🎯 You Are READY When You Can

✅ Store secrets securely in Key Vault

✅ Read secrets via Terraform

✅ Avoid hard-coding completely

✅ Explain secret security clearly

---
