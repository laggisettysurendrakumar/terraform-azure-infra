# 🔵 Day 36 – Security Best Practices

**(Least Privilege • State Encryption • Access Controls)**

Security in Terraform is not one feature.
It’s a **design mindset** applied across:

* Identity
* State
* Pipelines
* Environments

---

## 🧠 Why Security Is CRITICAL in Terraform

Terraform controls:

* Networks
* VMs
* Secrets
* Firewalls
* IAM

👉 **If Terraform is compromised, the entire cloud is compromised.**

---

## 1️⃣ Least Privilege (MOST IMPORTANT PRINCIPLE)

### 🔹 What Is Least Privilege?

> Give **only the minimum permissions** required to do the job—nothing more.

---

### ❌ Bad Practice (Very Common)

* Terraform Service Principal = **Owner**
* CI/CD identity = **Full access**
* Everyone can read state

🚨 This is how real breaches happen.

---

### ✅ Good Practice (Enterprise Standard)

* Terraform identity = **Contributor**
* State access = **Read/Write only**
* Secrets access = **Read only**

---

### 🔹 Terraform Identity (Recommended)

For Terraform (local or CI/CD):

* **Service Principal**
* Role: **Contributor**
* Scope: **Subscription or specific RG**

```bash
az role assignment create \
  --assignee <SP_CLIENT_ID> \
  --role Contributor \
  --scope /subscriptions/<SUB_ID>
```

✔ Can create resources

❌ Cannot manage RBAC itself

---

### 🔹 Why NOT Owner?

Owner can:

* Assign roles
* Change permissions
* Escalate access

👉 Violates least privilege
👉 High security risk

---

### 🔹 Real-Life Analogy

* Least privilege → Hotel room key 🏨
* Owner → Master key 🔑

You don’t give the **master key** to everyone.

---

## 🔍 Visual: Least Privilege Concept

![Image](https://www.datocms-assets.com/75231/1730228262-polp-triangle.png?fm=webp)

![Image](https://learn.microsoft.com/en-us/azure/role-based-access-control/media/best-practices/rbac-least-privilege.png)

![Image](https://www.einfochips.com/wp-content/uploads/2025/12/Figure-1-Terraform-Workflow-scaled.webp)

---

## 2️⃣ Terraform State Encryption (CRITICAL)

### 🔹 Why State Is Sensitive

Terraform state may contain:

* Resource IDs
* IP addresses
* Usernames
* **Secrets (even if using Key Vault)**

👉 **State = sensitive asset**

---

## 3️⃣ Use Remote State with Encryption

### 🔹 Azure Storage Backend (Recommended)

Azure Storage provides:

✔ Encryption at rest (default)

✔ TLS in transit

✔ RBAC integration

✔ State locking

---

### 🔹 Secure Backend Configuration

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate01"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

Azure automatically:

* Encrypts blobs at rest
* Secures data in transit

---

### 🔹 Extra Security (Recommended for Prod)

* Use **private endpoint** for storage
* Disable public access
* Restrict network rules

---

## 🔍 Visual: Secure Terraform State Flow

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AazlDiCZlFfytmHqEF3reyw.png)

![Image](https://mycloudrevolution.com/2025/01/06/terraform-azurerm-backend/images/azurerm-diagram_hu_9f138f3115d297ac.png)

![Image](https://cdn.prod.website-files.com/67f9776b8553224cbb897cd7/685b31f5d347ad9d00729598_1_H8G_fsjjRNSahLxrWDXibg.webp)

---

## 4️⃣ Protecting Access to Terraform State

### 🔹 Who Should Access State?

| Identity        | Access           |
| --------------- | ---------------- |
| Terraform CI/CD | Read + Write     |
| Infra team      | Read             |
| Developers      | No direct access |
| Public          | ❌ Never          |

---

### 🔹 Azure RBAC on Storage Account

Assign roles carefully:

* **Storage Blob Data Contributor** → Terraform pipeline
* **Storage Blob Data Reader** → Auditors

❌ Never use account keys in pipelines

---

## 5️⃣ Access Controls Across the Stack

Security must be applied at **multiple layers**:

---

### 🔹 1. Git Access Control

✔ Protected branches

✔ PR reviews required

✔ No direct push to `main`

✔ Code owners

---

### 🔹 2. CI/CD Access Control

✔ Separate pipelines per env

✔ Manual approval for prod

✔ Restricted secret access

---

### 🔹 3. Azure Access Control (RBAC)

✔ Different SP per environment

✔ Separate subscriptions (ideal)

✔ No shared credentials

---

## 🔍 Visual: End-to-End Access Control

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AYHkd1JVSmY_iXvgc4WT96Q.png)

![Image](https://entail.jit.io/en-assets/jit/fit-in/440x248/65420bd11eb0104326052fdd_Infrastructure20as20Code20IaC-1701070279875.png)

![Image](https://www.datocms-assets.com/2885/1681399105-image-1-n-tier-architecture.png)

---

## 6️⃣ Environment Isolation (SECURITY + SAFETY)

### 🔹 Why Isolation Matters

Without isolation:

* Dev mistake can destroy prod
* Shared state causes corruption

---

### ✅ Proper Isolation Strategy

* Separate folders
* Separate state files
* Separate Service Principals
* Separate approvals

```text
dev  → sp-dev  → dev.tfstate
test → sp-test → test.tfstate
prod → sp-prod → prod.tfstate
```

---

## 7️⃣ Secrets Handling (Quick Recap)

✔ Secrets in Azure Key Vault

✔ Terraform reads via data sources

✔ No secrets in Git

✔ No secrets in `.tfvars` committed

👉 State still needs protection!

---

## ❌ Common Security Mistakes (VERY IMPORTANT)

❌ Using Owner role for Terraform

❌ Local state files in prod

❌ Committing `.tfvars` with secrets

❌ Shared SP across environments

❌ No pipeline approvals

---

## 🧠 Interview Questions (Day 36)

**Q: What is least privilege in Terraform context?**
Giving Terraform only the permissions it needs—nothing more.

**Q: Why is Terraform state sensitive?**
It can contain secrets and infrastructure metadata.

**Q: How do you secure Terraform state?**
Remote backend + encryption + RBAC.

**Q: Should Terraform have Owner access?**
No. Contributor is recommended.

---

## 🎯 You Are READY When You Can

✅ Design Terraform with least privilege

✅ Secure state properly

✅ Control access across Git, CI/CD, and Azure

✅ Explain security decisions confidently

---
