# 🟡 Day 15 – Terraform Functions

**(`lookup` • `length` • `merge` • `format`)**

Terraform functions help you:

* Write **dynamic** code
* Avoid hard-coding
* Handle **real-world inputs**
* Build **reusable, production-grade** configurations

---

## 🧠 Why Terraform Functions Matter

Without functions:

* Code becomes repetitive
* Hard-coded values everywhere
* Poor reusability

With functions:

* One module → many environments
* Clean, flexible Terraform
* Safer automation

---

## 1️⃣ `lookup()` – Read Value from a Map (MOST USED)

### 🔹 What `lookup()` Does

Gets a value from a **map**, with an optional **default** if the key doesn’t exist.

### 🔹 Syntax

```hcl
lookup(map, key, default)
```

---

### 🔹 Simple Example

```hcl
variable "vm_sizes" {
  default = {
    dev  = "Standard_B2s"
    prod = "Standard_D2s_v3"
  }
}
```

```hcl
size = lookup(var.vm_sizes, "dev", "Standard_B1s")
```

👉 Result: `Standard_B2s`

---

### 🔹 Real Terraform Use Case (Environment-based VM Size)

```hcl
variable "environment" {
  default = "dev"
}

size = lookup(var.vm_sizes, var.environment, "Standard_B1s")
```


✔ Dev → small VM

✔ Prod → bigger VM

✔ Safe fallback

---

### 🔹 Why `lookup()` Is Important


✔ Prevents errors

✔ Supports multi-env design

✔ Cleaner than `var.map[key]`

---

## 2️⃣ `length()` – Count Items (Lists / Maps / Strings)

### 🔹 What `length()` Does

Returns the **number of elements**.

### 🔹 Syntax

```hcl
length(value)
```

---

### 🔹 Examples

#### List

```hcl
length(["a", "b", "c"])
```

➡ `3`

#### Map

```hcl
length({
  web = 1
  db  = 2
})
```

➡ `2`

---

### 🔹 Real Terraform Use Case (Conditional Resource Creation)

```hcl
count = length(var.subnet_ids)
```

Create resources **only if input exists**.

---

### 🔹 Common Scenario

```hcl
resource "azurerm_public_ip" "pip" {
  count = length(var.enable_public_ip) > 0 ? 1 : 0
}
```

---

### 🔹 Why `length()` Matters


✔ Enables conditions

✔ Works with `count` & `for_each`

✔ Prevents empty-input failures

---

## 3️⃣ `merge()` – Combine Maps (VERY IMPORTANT)

### 🔹 What `merge()` Does

Combines multiple maps into **one map**.

### 🔹 Syntax

```hcl
merge(map1, map2, ...)
```

---

### 🔹 Simple Example

```hcl
merge(
  { env = "dev" },
  { owner = "terraform" }
)
```

➡ Result:

```hcl
{
  env   = "dev"
  owner = "terraform"
}
```

---

### 🔹 Real Terraform Use Case (Tags – VERY COMMON)

```hcl
variable "common_tags" {
  default = {
    project = "terraform"
    owner   = "devops"
  }
}

variable "env_tags" {
  default = {
    environment = "dev"
  }
}
```

```hcl
tags = merge(var.common_tags, var.env_tags)
```


✔ Standard tags

✔ Environment-specific tags

✔ Clean & reusable

---

### 🔹 Overwrite Behavior (IMPORTANT)

```hcl
merge(
  { env = "dev" },
  { env = "prod" }
)
```

➡ Result: `env = "prod"`

👉 **Last map wins**

---

### 🔹 Why `merge()` Is Powerful


✔ Clean tagging strategy

✔ Avoid duplication

✔ Enterprise standard

---

## 4️⃣ `format()` – Build Strings Dynamically

### 🔹 What `format()` Does

Formats strings using placeholders.

### 🔹 Syntax

```hcl
format("text %s %d", string, number)
```

---

### 🔹 Simple Example

```hcl
format("vm-%s-%s", "web", "dev")
```

➡ `vm-web-dev`

---

### 🔹 Real Terraform Use Case (Resource Naming)

```hcl
name = format(
  "vm-%s-%s",
  var.application,
  var.environment
)
```


✔ Consistent naming

✔ No hard-coding

✔ Follows naming standards

---

### 🔹 Another Example (Storage Account Name)

```hcl
name = format(
  "st%s%s01",
  var.project,
  var.environment
)
```

---

### 🔹 Why `format()` Matters


✔ Enforces naming conventions

✔ Makes code readable

✔ Avoids string concatenation mess

---

## 🔗 Using Functions Together (REAL PROJECT EXAMPLE)

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name = format(
    "vm-%s-%s",
    var.app_name,
    var.environment
  )

  size = lookup(
    var.vm_sizes,
    var.environment,
    "Standard_B1s"
  )

  tags = merge(
    var.common_tags,
    {
      env = var.environment
    }
  )
}
```

👉 This is **production-grade Terraform**

---

## ❌ Common Mistakes (IMPORTANT)


❌ Using wrong data type (list vs map)

❌ Forgetting default in `lookup()`

❌ Overwriting tags unintentionally in `merge()`

❌ Hard-coding names instead of `format()`

---

## 🧠 Interview Questions (Day 15)

**Q: Why use `lookup()` instead of `var.map[key]`?**
Safer, avoids runtime errors.

**Q: Where is `merge()` commonly used?**
Tagging strategy.

**Q: What happens if keys conflict in `merge()`?**
Last map wins.

**Q: Why use `format()`?**
To enforce consistent naming.

---

## 🎯 You Are READY When You Can


✅ Use functions without Google

✅ Write env-based Terraform

✅ Build clean naming & tagging

✅ Explain why functions matter

---
