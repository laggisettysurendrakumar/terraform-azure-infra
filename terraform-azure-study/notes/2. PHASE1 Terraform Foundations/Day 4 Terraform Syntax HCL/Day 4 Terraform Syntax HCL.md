# **Day 4 – Terraform Syntax (HCL)**

🎯 **Goal of Day-4**
By the end of this day, you will:

* Understand **HCL syntax**
* Confidently write **resources**
* Use **variables** correctly
* Expose values using **outputs**
* Follow **standard `.tf` file structure**

---

## **1️⃣ What is HCL? (Terraform Language)**

### 📌 Definition

Terraform uses **HCL (HashiCorp Configuration Language)**.

Key properties:

* Declarative
* Human-readable
* Designed for infrastructure

👉 You describe **WHAT** you want, not **HOW** to do it.

---

### 🔹 Basic HCL Syntax

```hcl
block_type "label1" "label2" {
  argument = value
}
```

Example:

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-demo"
  location = "Central India"
}
```

---

## **2️⃣ Resources (Core Building Block)** ⭐

### 📌 What is a Resource?

A **resource** represents **one real infrastructure object**.

Examples:

* Resource Group
* Virtual Network
* VM
* Storage Account

---

### 🔹 Resource Syntax

```hcl
resource "<PROVIDER>_<TYPE>" "<NAME>" {
  argument = value
}
```

---

### 🧪 Example: Azure Resource Group

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-day4"
  location = "Central India"
}
```

* `azurerm_resource_group` → resource type
* `rg` → logical name (used internally by Terraform)

---

### 🔗 Referencing Resources

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
```

👉 Terraform automatically understands **dependencies**.

---

### 🧠 Key Points


✔ One resource = one infra object

✔ Terraform builds dependency graph automatically

✔ Logical name ≠ Azure name

---

## **3️⃣ Variables (Make Code Reusable)** ⭐⭐

### 📌 Why Variables?

Without variables:

* Hardcoded values
* Difficult to reuse
* Not environment-friendly

Variables make Terraform:

✅ Reusable

✅ Flexible

✅ Environment-aware

---

### 🔹 Declare Variable (`variables.tf`)

```hcl
variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}
```

---

### 🔹 Use Variable in Resource

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-day4"
  location = var.location
}
```

---

### 🔹 Variable Without Default (Mandatory)

```hcl
variable "rg_name" {
  description = "Resource group name"
  type        = string
}
```

Terraform will ask for input at runtime.

---

### 🔹 Variable Types

```hcl
variable "vm_count" {
  type    = number
  default = 2
}

variable "tags" {
  type = map(string)
  default = {
    env  = "dev"
    team = "infra"
  }
}
```

---

### 🔹 Provide Values (terraform.tfvars)

```hcl
rg_name  = "rg-dev"
location = "East US"
```

---

### 🧠 Best Practice

* Never hardcode environment values
* Use `.tfvars` for Dev/Test/Prod

---

## **4️⃣ Outputs (Expose Useful Info)** ⭐⭐

### 📌 What are Outputs?

Outputs:

* Display values after `apply`
* Share data between modules
* Help in debugging

---

### 🔹 Output Syntax

```hcl
output "rg_name" {
  value = azurerm_resource_group.rg.name
}
```

---

### 🧪 Example Output

After `terraform apply`:

```text
rg_name = "rg-day4"
```

---

### 🔐 Sensitive Output

```hcl
output "client_secret" {
  value     = var.client_secret
  sensitive = true
}
```

➡️ Value hidden in CLI output.

---

### 🧠 Use Cases


✔ Display IP addresses

✔ Show resource IDs

✔ Pass values to modules

---

## **5️⃣ .tf File Structure (Industry Standard)** ⭐⭐⭐

### 📌 Recommended Structure

```text
terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── provider.tf
```

---

### 🔹 File Responsibilities

| File               | Purpose               |
| ------------------ | --------------------- |
| `main.tf`          | Resources             |
| `variables.tf`     | Variable declarations |
| `outputs.tf`       | Output values         |
| `terraform.tfvars` | Variable values       |
| `provider.tf`      | Provider config       |

👉 Terraform loads **all `.tf` files automatically**.

---

### 🧠 Important Rule

Terraform **does NOT care about file names**, only:

* `.tf` extension
* Valid syntax

File separation = **human readability**.

---

## **6️⃣ End-to-End Example (Day-4)**

### `provider.tf`

```hcl
provider "azurerm" {
  features {}
}
```

---

### `variables.tf`

```hcl
variable "rg_name" {
  type = string
}

variable "location" {
  type    = string
  default = "Central India"
}
```

---

### `main.tf`

```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}
```

---

### `outputs.tf`

```hcl
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
```

---

### `terraform.tfvars`

```hcl
rg_name = "rg-day4-demo"
```

---

### Commands

```bash
terraform init
terraform plan
terraform apply
```

---

## **7️⃣ Common Mistakes (Exam + Real World)** ⚠️


❌ Hardcoding values

❌ Secrets in `.tf` files

❌ No variable descriptions

❌ No outputs for important values

---

## **Day-4 Summary (Revision Ready)**


✔ Resources create infrastructure

✔ Variables make code reusable

✔ Outputs expose values

✔ `.tf` files are logically separated

✔ Terraform auto-loads all `.tf` files

---
