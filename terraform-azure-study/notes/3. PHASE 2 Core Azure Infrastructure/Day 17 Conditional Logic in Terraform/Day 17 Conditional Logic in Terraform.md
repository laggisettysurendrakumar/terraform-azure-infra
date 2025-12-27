# 🟡 Day 17 – Conditional Logic in Terraform

**(Ternary Operator • Optional Resources)**

Conditional logic allows Terraform to:

* Enable/disable resources
* Change behavior per environment
* Avoid duplicate code
* Build feature toggles

---

## 🧠 Why Conditional Logic Matters

Without conditions:

* Separate Terraform code per env ❌
* Copy-paste everywhere ❌

With conditions:

* One codebase for all environments ✅
* Clean, controlled deployments ✅

---

## 1️⃣ Ternary Operator (`condition ? true : false`)

### 🔹 What Is a Ternary Operator?

A compact **if–else** expression.

### 🔹 Syntax

```hcl
condition ? true_value : false_value
```

---

### 🔹 Simple Example

```hcl
var.environment == "prod" ? "Standard_D2s_v3" : "Standard_B2s"
```

👉 If `prod` → big VM
👉 Else → small VM

---

### 🔹 Terraform Example (VM Size by Environment)

```hcl
size = var.environment == "prod"
  ? "Standard_D2s_v3"
  : "Standard_B2s"
```

✔ One VM resource

✔ Different sizes

✔ No duplication

---

### 🔹 Real-Life Analogy

* If it’s **raining** → take umbrella ☔
* Else → sunglasses 😎

---

## 2️⃣ Conditional Values (NOT JUST RESOURCES)

You can conditionally change:

* Names
* Tags
* Locations
* SKUs

---

### 🔹 Conditional Naming Example

```hcl
name = var.environment == "prod"
  ? "vm-prod-app"
  : "vm-dev-app"
```

---

### 🔹 Conditional Tags Example

```hcl
tags = {
  environment = var.environment
  critical    = var.environment == "prod" ? "yes" : "no"
}
```

---

## 3️⃣ Optional Resources (MOST IMPORTANT)

Terraform **does NOT** have `if` statements for resources.
Instead, we use:

* `count`
* `for_each`

---

## 4️⃣ Optional Resource Using `count`

### 🔹 Pattern (VERY COMMON)

```hcl
count = condition ? 1 : 0
```

---

### 🔹 Example: Optional Public IP

```hcl
variable "enable_public_ip" {
  type    = bool
  default = false
}

resource "azurerm_public_ip" "pip" {
  count = var.enable_public_ip ? 1 : 0

  name                = "pip-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
```

👉 If `true` → resource created
👉 If `false` → resource skipped

---

### 🔹 Accessing Count-Based Resource

```hcl
public_ip_address_id = var.enable_public_ip
  ? azurerm_public_ip.pip[0].id
  : null
```

⚠️ Index `[0]` exists **only when count = 1**

---

## 5️⃣ Optional Resource Using `for_each` (ADVANCED)

### 🔹 Pattern

```hcl
for_each = condition ? { key = "value" } : {}
```

---

### 🔹 Example: Optional NSG Rule

```hcl
variable "enable_http" {
  default = false
}

resource "azurerm_network_security_rule" "http" {
  for_each = var.enable_http ? { http = 80 } : {}

  name                        = "Allow-HTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
```

✔ Cleaner than `count`

✔ No index issues

✔ Preferred for optional named resources

---

## 6️⃣ Conditional Blocks Inside Resources

### 🔹 Example: Conditional Tags

```hcl
tags = merge(
  var.common_tags,
  var.environment == "prod" ? { critical = "true" } : {}
)
```

---

## 7️⃣ Environment-Based Feature Toggles (REAL PROJECT)

```hcl
variable "environment" {
  default = "dev"
}

variable "enable_monitoring" {
  default = true
}

resource "azurerm_log_analytics_workspace" "law" {
  count = var.environment == "prod" && var.enable_monitoring ? 1 : 0

  name                = "log-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
```

---

## 🔗 Combining Conditions + Functions (POWERFUL)

```hcl
size = lookup(
  var.vm_sizes,
  var.environment,
  var.environment == "prod" ? "Standard_D2s_v3" : "Standard_B2s"
)
```

---

## ❌ Common Mistakes (IMPORTANT)


❌ Using `if` like programming languages

❌ Forgetting `[0]` with `count`

❌ Returning wrong data type

❌ Overusing nested ternaries (hard to read)

---

## 🧠 Interview Questions (Day 17)

**Q: How do you create optional resources in Terraform?**
Using `count` or `for_each` with conditions.

**Q: Terraform if–else supported?**
❌ No. Only expressions.

**Q: Which is better: `count` or `for_each`?**
`for_each` for named resources.

**Q: Can we conditionally add tags?**
✅ Yes, using ternary or `merge()`.

---

## 🎯 You Are READY When You Can


✅ Use ternary expressions confidently

✅ Enable/disable resources safely

✅ Build env-based Terraform

✅ Explain conditional patterns clearly

---
