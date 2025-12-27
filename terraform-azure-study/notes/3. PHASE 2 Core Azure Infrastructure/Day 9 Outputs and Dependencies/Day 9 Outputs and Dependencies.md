## 📘 Day 9 – Outputs & Dependencies (Terraform)

Day 9 focuses on **how Terraform exposes information after deployment** and **how it understands resource creation order**. Mastering this day helps you write **clean, modular, and error-free infrastructure**.

---

## 🔹 1. Output Values

Output values allow Terraform to **display information** after `terraform apply` and **share data between modules**.

### ✅ Why Outputs Are Important

* Show important info (IP, URL, IDs)
* Pass values to **child / parent modules**
* Debug and verify infrastructure
* Integrate with CI/CD pipelines

---

### 📌 Basic Output Example

```hcl
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}
```

After apply:

```bash
resource_group_name = rg-demo-prod
```

---

### 🔍 Output Attributes

| Attribute     | Meaning              |
| ------------- | -------------------- |
| `value`       | Expression to expose |
| `description` | Explanation          |
| `sensitive`   | Hide output value    |

---

### 🔐 Sensitive Outputs

```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```

Terraform will mask the value:

```bash
db_password = (sensitive)
```

⚠️ **Important:** Sensitive outputs are **still stored in state**.

---

## 🔹 2. Common Output Examples (Real World)

### 🔸 Public IP Address

```hcl
output "vm_public_ip" {
  value = azurerm_public_ip.vm.ip_address
}
```

### 🔸 Application URL

```hcl
output "app_url" {
  value = "https://${azurerm_public_ip.vm.ip_address}"
}
```

---

## 🔹 3. Using Outputs Across Modules

### 📌 Child Module (`modules/network/outputs.tf`)

```hcl
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
```

### 📌 Parent Module (`main.tf`)

```hcl
module "network" {
  source = "./modules/network"
}

resource "azurerm_subnet" "subnet" {
  virtual_network_name = module.network.vnet_id
}
```

👉 Outputs act as **return values** of modules.

---

## 🔹 4. Dependencies in Terraform

Dependencies define **resource creation order**.

Terraform builds a **dependency graph** automatically.

---

## 🔹 5. Implicit Dependencies (Most Common)

Terraform detects dependencies **automatically** when one resource references another.

### 📌 Example: Implicit Dependency

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-demo"
  location = "East US"
}

resource "azurerm_storage_account" "sa" {
  name                     = "stgdemotf123"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}
```

✅ Storage Account is created **after** Resource Group
🚫 No need to define dependency manually

---

## 🔹 6. Explicit Dependencies (`depends_on`)

Used when Terraform **cannot detect** the dependency.

### 📌 When to Use `depends_on`

* Provisioners
* Null resources
* Role assignments
* Policies
* External scripts

---

### 📌 Example: Explicit Dependency

```hcl
resource "azurerm_role_assignment" "ra" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.principal_id

  depends_on = [
    azurerm_storage_account.sa
  ]
}
```

🧠 Even if no attribute is referenced, Terraform waits.

---

## 🔹 7. Bad vs Good Dependency Practice

### ❌ Bad (Unnecessary `depends_on`)

```hcl
resource "azurerm_storage_container" "container" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.sa.name

  depends_on = [
    azurerm_storage_account.sa
  ]
}
```

👉 Terraform already knows the dependency.

---

### ✅ Good (Let Terraform Decide)

```hcl
resource "azurerm_storage_container" "container" {
  name                 = "data"
  storage_account_name = azurerm_storage_account.sa.name
}
```

---

## 🔹 8. Outputs + Dependencies Together

Outputs can also **create dependencies across modules**.

### 📌 Example

```hcl
module "network" {
  source = "./modules/network"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-demo"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = module.network.subnet_id
}
```

👉 NIC depends on subnet output → **implicit dependency**

---

## 🔹 9. Dependency Graph Visualization

```bash
terraform graph | dot -Tpng > graph.png
```

This shows:

* Resource order
* Parallel execution
* Bottlenecks

---

## 🔹 10. Interview Questions ⭐

**Q1:** What are Terraform outputs used for?
👉 Display values & share data across modules.

**Q2:** Difference between implicit and explicit dependency?
👉 Implicit is automatic via references; explicit uses `depends_on`.

**Q3:** When should `depends_on` be avoided?
👉 When Terraform already understands dependency.

**Q4:** Are outputs stored in state?
👉 ✅ Yes.

---

## ✅ Day 9 Outcome

By the end of Day 9, you will:

* Use outputs effectively
* Share data between modules
* Understand Terraform’s dependency graph
* Avoid common dependency mistakes
* Write production-ready Terraform code

---
