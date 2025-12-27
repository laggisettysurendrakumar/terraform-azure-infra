## 📘 Day 8 – Variables & `tfvars` (Terraform)

Terraform variables make your infrastructure **reusable, flexible, and secure**. This day is all about **how data flows into Terraform configurations** and how to **protect sensitive values**.

---

## 🔹 1. Input Variables

Input variables let you **parameterize** your Terraform code instead of hard-coding values.

### ✅ Why Input Variables?

* Reuse the same code for **dev / test / prod**
* Avoid duplication
* Make infrastructure configurable
* Improve readability

---

### 📌 Basic Variable Declaration

```hcl
variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}
```

### 🔍 Key Attributes

| Attribute     | Purpose                                             |
| ------------- | --------------------------------------------------- |
| `description` | Explains the variable                               |
| `type`        | Data type (string, number, bool, list, map, object) |
| `default`     | Optional default value                              |
| `sensitive`   | Hides value in logs/output                          |

---

### 📌 Using a Variable

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-demo"
  location = var.location
}
```

---

## 🔹 2. Variable Types (with Examples)

### 🔸 String

```hcl
variable "env" {
  type    = string
  default = "dev"
}
```

### 🔸 Number

```hcl
variable "instance_count" {
  type    = number
  default = 2
}
```

### 🔸 Boolean

```hcl
variable "enable_backup" {
  type    = bool
  default = true
}
```

### 🔸 List

```hcl
variable "subnets" {
  type    = list(string)
  default = ["subnet1", "subnet2"]
}
```

### 🔸 Map

```hcl
variable "tags" {
  type = map(string)
  default = {
    env  = "dev"
    team = "platform"
  }
}
```

---

## 🔹 3. `terraform.tfvars`

`terraform.tfvars` is used to **pass values to variables** without editing `.tf` files.

### 📌 Example: `variables.tf`

```hcl
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}
```

### 📌 Example: `terraform.tfvars`

```hcl
resource_group_name = "rg-prod"
location            = "Central India"
```

Terraform automatically loads:

* `terraform.tfvars`
* `*.auto.tfvars`

✅ Best practice: **never hardcode environment-specific values**

---

### 🧠 Variable Loading Order (Priority)

1. `-var` CLI flag
2. `-var-file`
3. `*.auto.tfvars`
4. `terraform.tfvars`
5. `default` values

---

## 🔹 4. Sensitive Variables

Sensitive variables are used for:

* Passwords
* Client secrets
* Tokens
* Connection strings

### 📌 Declaring Sensitive Variable

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

### 📌 Using Sensitive Variables

```hcl
resource "azurerm_sql_server" "sql" {
  name                         = "sqlserverdemo"
  administrator_login          = "adminuser"
  administrator_login_password = var.db_password
}
```

🔐 Terraform will:

* Mask values in CLI output
* Prevent accidental exposure in logs

---

### ⚠️ Important Note (Very Critical)

> **Sensitive values are STILL stored in `terraform.tfstate`**

To protect secrets:

* 🔒 Store state in **remote backend** (Azure Storage, Terraform Cloud)
* 🔐 Enable **state encryption**
* 🗝️ Use **Key Vault / Secrets Manager**

---

## 🔹 5. Passing Variables (All Methods)

### 🔸 CLI

```bash
terraform apply -var="env=prod"
```

### 🔸 Variable File

```bash
terraform apply -var-file="prod.tfvars"
```

### 🔸 Environment Variables

```bash
export TF_VAR_location="East US"
```

---

## 🔹 6. Real-World Example (Azure)

### 📌 `variables.tf`

```hcl
variable "rg_name" {
  type = string
}

variable "location" {
  type    = string
  default = "East US"
}

variable "tags" {
  type = map(string)
}
```

### 📌 `terraform.tfvars`

```hcl
rg_name = "rg-demo-prod"

tags = {
  env     = "prod"
  owner  = "devops"
}
```

### 📌 `main.tf`

```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}
```

---

## 🔹 7. Best Practices ⭐

✔ Always define variables in `variables.tf`
✔ Use `terraform.tfvars` for environment data
✔ Mark secrets as `sensitive = true`
✔ Never commit secrets to Git
✔ Use Key Vault + Remote State
✔ Validate inputs using `type` and `validation`

---

## 🔹 8. Common Interview Questions

**Q1:** Difference between `default` and `tfvars`?
👉 Default is optional fallback; `tfvars` overrides values per environment.

**Q2:** Does `sensitive = true` encrypt data?
👉 ❌ No. It only hides output. State still stores it.

**Q3:** What happens if a variable has no value?
👉 Terraform prompts during `apply`.

---

## ✅ Day 8 Outcome

By the end of Day 8, you will:

* Fully understand **Terraform variables**
* Know how `tfvars` works in real projects
* Secure secrets properly
* Write clean, reusable Terraform code

---
