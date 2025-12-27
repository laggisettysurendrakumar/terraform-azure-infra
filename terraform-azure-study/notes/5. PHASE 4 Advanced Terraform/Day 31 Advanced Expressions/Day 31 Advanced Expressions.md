# 🔵 Day 31 – Advanced Expressions

**(Complex Maps • Nested Objects • Real-World Patterns)**

Advanced expressions let Terraform handle:

* Enterprise-scale inputs
* Multiple environments & components
* Clean, data-driven infrastructure

---

## 🧠 Why Advanced Expressions Matter

Without advanced expressions:

* Too many variables
* Repeated code
* Hard-to-scale designs

With advanced expressions:

✔ One variable controls many resources

✔ Cleaner modules

✔ Fewer bugs

✔ Enterprise-ready Terraform

---

## 1️⃣ Complex Maps (FOUNDATION)

### 🔹 What Is a Complex Map?

A **map whose values are not simple strings**, but:

* Lists
* Maps
* Objects

---

### 🔹 Simple Map (Basic)

```hcl
vm_sizes = {
  dev  = "Standard_B2s"
  prod = "Standard_D2s_v3"
}
```

---

### 🔹 Complex Map Example

```hcl
variable "vm_config" {
  default = {
    dev = {
      size   = "Standard_B2s"
      count  = 1
      public = true
    }
    prod = {
      size   = "Standard_D4s_v3"
      count  = 3
      public = false
    }
  }
}
```

Here:

* Map key → environment
* Map value → configuration object

---

### 🔹 Accessing Values

```hcl
size  = var.vm_config["dev"].size
count = var.vm_config["dev"].count
```

---

### 🔹 Dynamic Environment Access

```hcl
locals {
  env = var.environment
}

size  = var.vm_config[local.env].size
count = var.vm_config[local.env].count
```

✔ One config

✔ Multiple environments

---

## 2️⃣ Nested Objects (CORE ADVANCED SKILL)

### 🔹 What Is a Nested Object?

An object that contains:

* Maps
* Lists
* Other objects

Used heavily in **modules and large projects**.

---

### 🔹 Example: Environment → Network → VM

```hcl
variable "environments" {
  default = {
    dev = {
      network = {
        vnet_cidr   = "10.0.0.0/16"
        subnet_cidr = "10.0.1.0/24"
      }
      vm = {
        size  = "Standard_B2s"
        count = 1
      }
    }
    prod = {
      network = {
        vnet_cidr   = "10.1.0.0/16"
        subnet_cidr = "10.1.1.0/24"
      }
      vm = {
        size  = "Standard_D4s_v3"
        count = 3
      }
    }
  }
}
```

---

### 🔹 Access Nested Values

```hcl
locals {
  env = var.environment
}

vnet_cidr   = var.environments[local.env].network.vnet_cidr
subnet_cidr = var.environments[local.env].network.subnet_cidr
vm_size     = var.environments[local.env].vm.size
```

---

## 🔍 Visual: Nested Object Structure

![Image](https://developer.hashicorp.com/_next/image?dpl=dpl_GobHkgKRgfw651r6XDhTB3t9RkQm\&q=75\&url=https%3A%2F%2Fcontent.hashicorp.com%2Fapi%2Fassets%3Fproduct%3Dtutorials%26version%3Dmain%26asset%3Dpublic%252Fimg%252Fterraform%252Frecommended-patterns%252Farch-diag-overview.png%26width%3D1763%26height%3D961\&w=3840)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1358/format%3Awebp/1%2AflwyfdzBHPYCJP7vCTDCHw.png)

![Image](https://jayendrapatil.com/wp-content/uploads/2020/11/Terraform_Workflow.png)

---

## 3️⃣ Using Complex Maps with `for_each`

### 🔹 Example: Multiple VMs with Different Configs

```hcl
variable "vm_definitions" {
  default = {
    web = {
      size = "Standard_B2s"
      port = 80
    }
    app = {
      size = "Standard_B2s"
      port = 8080
    }
    db = {
      size = "Standard_D2s_v3"
      port = 5432
    }
  }
}
```

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vm_definitions

  name = "vm-${each.key}"
  size = each.value.size
}
```

✔ Stable naming

✔ Clean scaling

---

## 4️⃣ Nested Objects + Dynamic Blocks (REAL WORLD)

### 🔹 NSG Rules from Nested Object

```hcl
variable "nsg_rules" {
  default = {
    web = {
      port     = 80
      priority = 100
    }
    ssh = {
      port     = 22
      priority = 110
    }
  }
}
```

```hcl
dynamic "security_rule" {
  for_each = var.nsg_rules
  content {
    name                       = each.key
    priority                   = each.value.priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = each.value.port
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
}
```

---

## 5️⃣ Type Constraints (IMPORTANT)

### 🔹 Why Type Constraints Matter

They:

* Prevent invalid inputs
* Catch errors early
* Improve module usability

---

### 🔹 Example with Object Type

```hcl
variable "vm_config" {
  type = map(object({
    size   = string
    count  = number
    public = bool
  }))
}
```

❌ Wrong input → Terraform fails early
✔ Safe modules

---

## 🔍 Visual: Type Safety with Objects

![Image](https://miro.medium.com/1%2A9pGY2Nc7TlGpkroUDkZYng.png)

![Image](https://imgopt.infoq.com/fit-in/3000x4000/filters%3Aquality%2885%29/filters%3Ano_upscale%28%29/news/2024/08/terraform-19/en/resources/1Screenshot%20from%202024-08-06%2000-54-11-1722902690900.png)

---

## 6️⃣ Real Enterprise Pattern (All Together)

```hcl
locals {
  env_config = var.environments[var.environment]
}

resource "azurerm_virtual_network" "vnet" {
  name          = "vnet-${var.environment}"
  address_space = [local.env_config.network.vnet_cidr]
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = local.env_config.vm.count
  size  = local.env_config.vm.size
}
```

👉 **One input controls entire environment**

---

## ❌ Common Mistakes (VERY IMPORTANT)

❌ Over-nesting (hard to read)

❌ No type constraints

❌ Mixing env logic everywhere

❌ Hardcoding fallback values

❌ Poor naming inside maps

---

## 🧠 Interview Questions (Day 31)

**Q: Why use complex maps instead of many variables?**
Cleaner, scalable, and easier to manage.

**Q: What is a nested object?**
An object containing other objects or maps.

**Q: How do you validate complex inputs?**
Using type constraints with `object()`.

**Q: Where are advanced expressions used most?**
Modules, multi-environment setups, dynamic resources.

---

## 🎯 You Are READY When You Can

✅ Read complex Terraform inputs confidently

✅ Design nested objects for environments

✅ Use `for_each` with complex maps

✅ Write clean, scalable modules

---
