# 🔵 Day 28 – Terraform Modules (Intro)

**(What Are Modules • Module Structure • Real Usage)**

Terraform modules are the **foundation of clean, reusable, production Terraform code**.

---

## 🧠 What Is a Terraform Module?

A **module** is:

* A **collection of Terraform files**
* Grouped to perform **one logical task**
* Reusable across environments & projects

👉 **Any folder with `.tf` files is a module**

---

### 🔹 Types of Modules

| Type          | Description                    |
| ------------- | ------------------------------ |
| Root module   | The main working directory     |
| Child module  | Reusable module called by root |
| Remote module | Module from Git / Registry     |

---

### 🔹 Real-Life Analogy

* **Module** → Blueprint 🧩
* **Using module** → Building many houses with same blueprint 🏠

---

## 1️⃣ Why Modules Are CRITICAL

Without modules:

* Duplicate code
* Hard to maintain
* Changes require editing everywhere

With modules:
✔ Write once, reuse everywhere

✔ Easy updates

✔ Cleaner reviews

✔ Enterprise standard

👉 **No serious Terraform project avoids modules**

---

## 2️⃣ Root Module vs Child Module

### 🔹 Root Module

* The folder where you run:

```bash
terraform init
terraform plan
terraform apply
```

Example:

```text
environments/dev/
```

---

### 🔹 Child Module

* Reusable code
* Called by root module
* Never run directly

Example:

```text
modules/network/
modules/compute/
```

---

## 3️⃣ Basic Module Structure (STANDARD)

Every module should have **at least these three files**:

```text
modules/network/
├── main.tf        # resources
├── variables.tf   # inputs
└── outputs.tf     # outputs
```

Optional (recommended later):

* `locals.tf`
* `README.md`

---

## 4️⃣ Simple Module Example – Network Module

### 🔹 `modules/network/main.tf`

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefix
}
```

---

### 🔹 `modules/network/variables.tf`

```hcl
variable "vnet_name" {}
variable "subnet_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "address_space" {}
variable "subnet_prefix" {}
```

---

### 🔹 `modules/network/outputs.tf`

```hcl
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
```

👉 This module:

* Creates network
* Exposes subnet ID
* Can be reused anywhere

---

## 5️⃣ Calling a Module (ROOT MODULE)

### 🔹 Root `main.tf`

```hcl
module "network" {
  source              = "../../modules/network"
  vnet_name           = "vnet-dev"
  subnet_name         = "subnet-dev"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  subnet_prefix       = ["10.0.1.0/24"]
}
```

---

### 🔹 Using Module Output

```hcl
subnet_id = module.network.subnet_id
```

✔ Clean

✔ Explicit

✔ Safe

---

## 🔍 Visual: How Modules Work

![Image](https://miro.medium.com/0%2AbJzMGdZBo0zKfbvQ)

![Image](https://jeffbrown.tech/wp-content/uploads/2021/11/image-1.png)

![Image](https://brendanthompson.com/content/images/posts/2021/11/my-terraform-development-workflow/terraform-development-workflow.png)

---

## 6️⃣ Module Inputs & Outputs (CONTRACT)

Think of a module as a **function**:

```text
Inputs  → Module Logic → Outputs
```

| Part   | Terraform |
| ------ | --------- |
| Input  | variables |
| Logic  | resources |
| Output | outputs   |

---

## 7️⃣ Good Module Design Rules (MUST FOLLOW)

✔ One responsibility per module

✔ No hard-coded environment values

✔ Use variables for all inputs

✔ Output only what is needed

✔ No backend config inside modules

---

## 8️⃣ Common Beginner Mistakes (IMPORTANT)

❌ Putting backend inside module

❌ Hardcoding resource group names

❌ Very large “god modules”

❌ No outputs

❌ Module depending on environment logic

---

## 9️⃣ When NOT to Create a Module

Do NOT create module when:

* Resource is used only once
* You’re still prototyping
* Code will be deleted soon

👉 Modules are for **reuse**, not everything.

---

## 🧠 Interview Questions (Day 28)

**Q: What is a Terraform module?**
A reusable collection of Terraform configuration files.

**Q: Difference between root and child module?**
Root is where Terraform runs; child is reused code.

**Q: What files are mandatory in a module?**
`main.tf`, `variables.tf`, `outputs.tf`.

**Q: Can modules have providers/backends?**
Providers yes, backends ❌ (should not).

---

## 🎯 You Are READY When You Can

✅ Explain modules clearly

✅ Create a reusable module

✅ Pass inputs & read outputs

✅ Refactor code into modules

---

