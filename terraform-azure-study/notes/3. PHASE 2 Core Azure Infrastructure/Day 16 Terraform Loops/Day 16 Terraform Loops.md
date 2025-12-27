# 🟡 Day 16 – Terraform Loops

**(`count` • `for_each` • Dynamic Blocks)**

Loops allow Terraform to:

* Create **multiple resources** cleanly
* Avoid copy-paste
* Handle **real-world inputs**
* Build **reusable modules**

---

## 🧠 Why Loops Matter in Terraform

Without loops:

* Repeated code
* Hard to scale
* Error-prone

With loops:

* One block → many resources
* Clean & maintainable
* Production-ready IaC

---

## 1️⃣ `count` – Simple Repetition

### 🔹 What `count` Does

`count` creates **N copies** of a resource using a number.

---

### 🔹 Syntax

```hcl
count = <number>
```

---

### 🔹 Simple Example

```hcl
resource "azurerm_public_ip" "pip" {
  count = 2
  name  = "pip-${count.index}"
}
```

👉 Creates:

* `pip-0`
* `pip-1`

---

### 🔹 `count.index`

* Starts from **0**
* Used to generate unique names

---

### 🔹 Real Terraform Use Case

```hcl
variable "vm_count" {
  default = 3
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = var.vm_count
  name  = "vm-${count.index}"
}
```

✔ Quick scaling

✔ Good for identical resources

---

### 🔹 Conditional Resource Creation (VERY COMMON)

```hcl
count = var.enable_public_ip ? 1 : 0
```

👉 Create resource **only if enabled**

---

### 🔹 Limitations of `count`


❌ Index-based (fragile)

❌ Deleting one resource shifts indexes

❌ Not good for named resources

---

## 2️⃣ `for_each` – Preferred & Safer

### 🔹 What `for_each` Does

Creates resources based on:

* **List**
* **Set**
* **Map**

Each resource gets a **stable key**.

---

### 🔹 Syntax

```hcl
for_each = <collection>
```

---

### 🔹 Simple List Example

```hcl
variable "subnets" {
  default = ["web", "app", "db"]
}

resource "azurerm_subnet" "subnet" {
  for_each = toset(var.subnets)
  name     = "subnet-${each.key}"
}
```

👉 Creates:

* subnet-web
* subnet-app
* subnet-db

---

### 🔹 Map Example (MOST COMMON)

```hcl
variable "vm_sizes" {
  default = {
    web = "Standard_B2s"
    app = "Standard_B2s"
    db  = "Standard_D2s_v3"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vm_sizes
  name     = "vm-${each.key}"
  size     = each.value
}
```


✔ Stable naming

✔ Easy updates

✔ Best practice

---

### 🔹 `each.key` vs `each.value`

| Expression   | Meaning             |
| ------------ | ------------------- |
| `each.key`   | Map key / set value |
| `each.value` | Map value           |

---

### 🔹 Why `for_each` Is Better Than `count`


✔ Stable resource identity

✔ Safer updates

✔ Cleaner diffs

✔ Enterprise standard

---

## 3️⃣ Dynamic Blocks – Loop Inside a Resource

### 🔹 What Are Dynamic Blocks?

Dynamic blocks generate **nested blocks** dynamically.

Used when:

* A resource needs repeated sub-blocks
* Number of blocks varies

---

### 🔹 Syntax

```hcl
dynamic "<block_name>" {
  for_each = <collection>
  content {
    ...
  }
}
```

---

### 🔹 Real Terraform Example (NSG Rules)

```hcl
variable "nsg_rules" {
  default = [
    {
      name     = "ssh"
      port     = 22
      priority = 100
    },
    {
      name     = "http"
      port     = 80
      priority = 110
    }
  ]
}
```

```hcl
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
```

👉 One variable controls **multiple rules**

---

### 🔹 Another Example (Multiple Data Disks)

```hcl
variable "data_disks" {
  default = [10, 20, 50]
}
```

```hcl
dynamic "data_disk" {
  for_each = var.data_disks
  content {
    lun                  = data_disk.key
    disk_size_gb         = data_disk.value
    storage_account_type = "Standard_LRS"
  }
}
```

---

## 🔗 When to Use What (CRITICAL)

| Scenario             | Use        |
| -------------------- | ---------- |
| Fixed number         | `count`    |
| Named resources      | `for_each` |
| Nested blocks        | `dynamic`  |
| Conditional resource | `count`    |
| Tags / maps          | `for_each` |

---

## ❌ Common Mistakes (IMPORTANT)


❌ Using `count` with maps

❌ Switching from `count` → `for_each` without state migration

❌ Forgetting `toset()` for lists

❌ Over-complex dynamic blocks

---

## 🧠 Interview Questions (Day 16)

**Q: Difference between `count` and `for_each`?**
`count` uses indexes; `for_each` uses keys.

**Q: Which is safer and why?**
`for_each`, because keys are stable.

**Q: What are dynamic blocks used for?**
To create repeated nested blocks.

**Q: Can we use both together?**
Yes, in different resources.

---

## 🎯 You Are READY When You Can

✅ Create multiple resources cleanly

✅ Choose between `count` & `for_each`

✅ Write dynamic blocks confidently

✅ Debug loop-related errors

---
