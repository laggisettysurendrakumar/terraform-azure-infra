# 🟡 Day 22 – Environment Design Patterns

**(Folder-Based Environments • Workspace-Based Approach)**

This day helps you answer one of the **most common senior-level interview questions**:

> *“How do you manage dev / test / prod environments in Terraform?”*

Environment design decides:

* How safe your production is
* How teams collaborate
* How easy scaling & audits become

There are **two main patterns** in Terraform:

1. **Folder-based environments**
2. **Workspace-based environments**

---

## 🧠 What Is an Environment in Terraform?

An **environment** usually means:

* Separate infrastructure
* Separate state
* Separate lifecycle

Examples:

* **dev** – experimentation
* **test** – validation
* **prod** – real users

---

## 1️⃣ Folder-Based Environments (ENTERPRISE STANDARD)

### 🔹 What Is Folder-Based Design?

Each environment has:

* Its **own folder**
* Its **own backend**
* Its **own variables**
* Its **own state**

👉 **Strong isolation**

---

### 🔹 Typical Folder Structure

```text
terraform-azure/
│
├── modules/
│   ├── network/
│   ├── compute/
│   └── security/
│
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   │
│   ├── test/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   │
│   └── prod/
│       ├── main.tf
│       ├── backend.tf
│       └── terraform.tfvars
```

---

### 🔹 How It Works

* Same **modules**
* Different **inputs**
* Different **state files**
* Different **Azure resources**

---

### 🔹 Example: `backend.tf` (per environment)

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-prod"
    storage_account_name = "sttfstateprod01"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

---

### 🔹 Example: `terraform.tfvars`

```hcl
environment = "prod"
vm_size     = "Standard_D2s_v3"
```

---

### 🔹 Why Enterprises Prefer This

✔ Strong isolation

✔ Clear ownership

✔ Easy audits

✔ CI/CD friendly

✔ Safer for production

---

### 🔹 Real-Life Analogy

* **Folder-based envs** → Separate bank accounts
* Dev mistake **cannot touch prod money** 💰

---

## 🔍 Visual: Folder-Based Environment Design

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AOkoKHrdRWVEUbwFJqQexlA.png)

![Image](https://media.licdn.com/dms/image/v2/D4E12AQHMvna4fV6GBw/article-cover_image-shrink_720_1280/B4EZXiKC5sHUAI-/0/1743256047243?e=2147483647\&t=2r0YeoRGJmu5VaT4pbTPMu-SrpUNA9mp03xiFgiQIzY\&v=beta)

![Image](https://www.datocms-assets.com/2885/1583259995-terraform-modules.svg)

---

## 2️⃣ Workspace-Based Approach (SIMPLE BUT LIMITED)

### 🔹 What Is Workspace-Based Design?

* One codebase
* Multiple **Terraform workspaces**
* Each workspace = separate state

---

### 🔹 Example

```bash
terraform workspace new dev
terraform workspace new test
terraform workspace new prod
```

---

### 🔹 Structure (Single Folder)

```text
terraform-azure/
├── main.tf
├── variables.tf
├── outputs.tf
└── backend.tf
```

States:

* dev
* test
* prod

---

### 🔹 Using Workspace in Code

```hcl
locals {
  env = terraform.workspace
}

resource "azurerm_linux_virtual_machine" "vm" {
  name = "vm-${local.env}"
  size = local.env == "prod" ? "Standard_D2s_v3" : "Standard_B2s"
}
```

---

### 🔹 Advantages

✔ Very fast setup

✔ Minimal duplication

✔ Good for PoC & learning

---

### 🔹 Real-Life Analogy

* **Workspaces** → Multiple users on same laptop
* One wrong command → affects wrong user ⚠️

---

## 🔍 Visual: Workspace-Based Design

![Image](https://k21academy.com/wp-content/uploads/2023/07/TF-WorkSpace-1024x487.webp)

![Image](https://media2.dev.to/dynamic/image/width%3D800%2Cheight%3D%2Cfit%3Dscale-down%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fa4drggfyv9rfnzptjiez.webp)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AJZV49LQUvk73CYqwcsqMGA.png)

---

## 3️⃣ Key Comparison (INTERVIEW GOLD)

| Aspect         | Folder-Based  | Workspace-Based |
| -------------- | ------------- | --------------- |
| Isolation      | ⭐⭐⭐⭐⭐         | ⭐⭐              |
| Safety         | ⭐⭐⭐⭐⭐         | ⭐⭐              |
| Complexity     | Medium        | Low             |
| CI/CD          | Excellent     | Limited         |
| Large teams    | ✅ Yes         | ❌ Risky         |
| Prod usage     | ✅ Recommended | ❌ Avoid         |
| Learning / PoC | ⚠️ Heavy      | ✅ Best          |

---

## 4️⃣ When to Use Which (VERY IMPORTANT)

### ✅ Use Folder-Based When:

* Production systems
* Multiple teams
* Compliance required
* Different infra per env
* Long-term projects

👉 **Default enterprise choice**

---

### ✅ Use Workspaces When:

* Learning Terraform
* Small team
* Same infra shape
* Short-lived environments
* Sandboxes

---

### ❌ Avoid Workspaces When:

* Large teams
* Strict prod controls
* Different infra per env
* Multiple CI/CD pipelines

---

## 5️⃣ Hybrid Pattern (Advanced but Real)

Some teams use:

* **Folders for prod vs non-prod**
* **Workspaces inside non-prod**

```text
environments/
├── non-prod/
│   └── (workspaces: dev, test)
└── prod/
```

⚠️ Use only if team is experienced

---

## ❌ Common Design Mistakes

❌ Using workspaces for production

❌ Same backend for all envs

❌ No clear ownership

❌ Mixing folder + workspace randomly

❌ No naming standards

---

## 🧠 Interview Questions (Day 22)

**Q: Best Terraform environment pattern for enterprise?**
Folder-based environments.

**Q: Why not workspaces for prod?**
Higher risk of human error, weaker isolation.

**Q: Can both be used together?**
Yes, but carefully and rarely.

**Q: How do you prevent dev from affecting prod?**
Separate folders + separate backends + RBAC.

---

## 🎯 You Are READY When You Can

✅ Design dev / test / prod safely

✅ Explain both patterns clearly

✅ Choose correct pattern for scenario

✅ Justify decisions in interviews

---
