# 🟡 Day 18 – Terraform Code Refactoring

**(Clean Structure • Best Practices)**

Refactoring means **improving code without changing behavior**.
In Terraform, refactoring is about **readability, safety, scalability, and teamwork**.

---

## 🧠 Why Refactoring Matters in Terraform

Without refactoring:

* Hard to understand code ❌
* Risky changes ❌
* Difficult team collaboration ❌

With refactoring:

* Clean & readable code ✅
* Easy scaling & reuse ✅
* Fewer production issues ✅

---

## 1️⃣ Clean Project Structure (FOUNDATION)

### 🔹 Bad Structure (Beginner)

```text
main.tf
everything.tf
vm.tf
network.tf
random.tf
```

❌ No clarity

❌ Hard to maintain

---

### ✅ Good Structure (Single Environment)

```text
terraform-azure/
│
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── terraform.tfvars
```

✔ Clear separation

✔ Easy navigation

---

### ✅ Better Structure (Multi-File)

```text
terraform-azure/
│
├── providers.tf
├── versions.tf
├── network.tf
├── compute.tf
├── security.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

---

## 2️⃣ Naming Conventions (VERY IMPORTANT)

### 🔹 Resource Naming Pattern

```text
<type>-<app>-<env>
```

Example:

* `vnet-app-dev`
* `vm-web-prod`
* `nsg-app-test`

---

### 🔹 Terraform Resource Names (Internal)

```hcl
resource "azurerm_virtual_network" "vnet" {}
resource "azurerm_linux_virtual_machine" "vm" {}
```

✔ Short

✔ Logical

✔ Consistent

---

## 3️⃣ Variables Refactoring (NO HARDCODING)

### ❌ Bad Practice

```hcl
location = "East US"
size     = "Standard_B2s"
```

---

### ✅ Good Practice

```hcl
variable "location" {
  default = "East US"
}

variable "vm_size" {
  default = "Standard_B2s"
}
```

---

### 🔹 Use `terraform.tfvars`

```hcl
location = "East US"
vm_size  = "Standard_B2s"
```

✔ Env-specific

✔ Clean code

---

## 4️⃣ Use Locals for Repeated Values

### 🔹 What Are Locals?

`locals` store **computed or repeated values**.

---

### 🔹 Example

```hcl
locals {
  name_prefix = "app-dev"
}
```

Use it:

```hcl
name = "${local.name_prefix}-vm"
```

✔ DRY principle

✔ Single change point

---

## 5️⃣ Tagging Strategy (ENTERPRISE MUST)

### ❌ Bad

```hcl
tags = {
  owner = "teamA"
}
```

---

### ✅ Good (Refactored)

```hcl
variable "common_tags" {
  default = {
    project = "terraform"
    owner   = "devops"
  }
}
```

```hcl
tags = merge(
  var.common_tags,
  {
    environment = var.environment
  }
)
```

✔ Standard

✔ Auditable

✔ Cost tracking

---

## 6️⃣ Resource Dependency Management

### 🔹 Implicit Dependency (Preferred)

```hcl
subnet_id = azurerm_subnet.subnet.id
```

Terraform automatically understands order.

---

### 🔹 Explicit Dependency (Rare)

```hcl
depends_on = [azurerm_network_security_group.nsg]
```

Use **only if required**.

---

## 7️⃣ Formatting & Validation (MANDATORY)

### 🔹 Format Code

```bash
terraform fmt
```

---

### 🔹 Validate Syntax

```bash
terraform validate
```

✔ CI/CD friendly

✔ Prevents bad commits

---

## 8️⃣ Sensitive Data Handling (CRITICAL)

### ❌ Never Do This

```hcl
admin_password = "Password@123"
```

---

### ✅ Correct Way

```hcl
variable "admin_password" {
  sensitive = true
}
```

Use:

* Environment variables
* Azure Key Vault
* CI/CD secrets

---

## 9️⃣ State Safety Best Practices

✔ Remote backend

✔ State locking

✔ Never edit state manually

✔ Separate state per environment

---

## 🔟 Refactoring Example (Before → After)

### ❌ Before (Messy)

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name     = "vm1"
  location = "East US"
  size     = "Standard_B2s"
}
```

---

### ✅ After (Clean)

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name     = format("vm-%s-%s", var.app, var.environment)
  location = var.location
  size     = lookup(var.vm_sizes, var.environment)
  tags     = local.tags
}
```

---

## ❌ Common Refactoring Mistakes

❌ Over-engineering too early

❌ Breaking state unintentionally

❌ Renaming resources without `terraform state mv`

❌ Mixing env logic everywhere

---

## 🧠 Interview Questions (Day 18)

**Q: What is refactoring in Terraform?**
Improving code structure without changing behavior.

**Q: Why use locals?**
Avoid repetition and centralize logic.

**Q: Best practice for secrets?**
Never hardcode; use Key Vault or CI/CD secrets.

**Q: Why tagging matters?**
Cost tracking, governance, audits.

---

## 🎯 You Are READY When You Can

✅ Read Terraform code like English

✅ Refactor without breaking infra

✅ Follow best practices naturally

✅ Write production-grade Terraform

---
