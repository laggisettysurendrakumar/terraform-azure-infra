# 🟡 Day 12 – Terraform Data Sources (Azure Focus)

Data Sources allow Terraform to **READ existing Azure resources** instead of creating new ones.
This is how Terraform integrates with **real production environments**.

---

## 1️⃣ What Are Data Sources?

### 🔹 Definition

A **data source** lets Terraform:

* Fetch information about **existing Azure resources**
* Use those values in new Terraform code

👉 Terraform **does NOT manage** these resources

👉 Terraform **only reads** them

---

### 🔹 Why Data Sources Matter

Without data sources:

* You duplicate resources
* You hard-code values
* You break existing infra

With data sources:

* Reuse existing infra
* Safely integrate Terraform
* Support large organizations

---

### 🔹 Real-Life Analogy

* **Resource block** → Build a new house 🏗
* **Data block** → Read details of an existing house 🏠

---

## 2️⃣ Resource vs Data Source (MUST KNOW)

| Feature              | resource | data      |
| -------------------- | -------- | --------- |
| Creates infra        | ✅        | ❌         |
| Modifies infra       | ✅        | ❌         |
| Reads existing infra | ❌        | ✅         |
| Appears in state     | ✅        | Read-only |

---

## 3️⃣ Data Block Syntax

### 🔹 General Syntax

```hcl
data "<PROVIDER>_<RESOURCE_TYPE>" "<NAME>" {
  # filters / identifiers
}
```

Example:

```hcl
data "azurerm_resource_group" "existing_rg" {
  name = "rg-existing"
}
```

---

## 4️⃣ Reading Existing Azure Resources (Examples)

---

### 🔹 Example 1: Existing Resource Group

```hcl
data "azurerm_resource_group" "rg" {
  name = "rg-prod"
}
```

Use it:

```hcl
location = data.azurerm_resource_group.rg.location
```

👉 No duplication, safe reuse

---

### 🔹 Example 2: Existing Virtual Network

```hcl
data "azurerm_virtual_network" "vnet" {
  name                = "vnet-prod"
  resource_group_name = "rg-network"
}
```

Use it:

```hcl
subnet_id = data.azurerm_virtual_network.vnet.id
```

---

### 🔹 Example 3: Existing Subnet

```hcl
data "azurerm_subnet" "subnet" {
  name                 = "subnet-web"
  virtual_network_name = "vnet-prod"
  resource_group_name  = "rg-network"
}
```

Used when:

* Network team owns VNet
* App team creates VM

---

### 🔹 Example 4: Existing Network Security Group

```hcl
data "azurerm_network_security_group" "nsg" {
  name                = "nsg-web"
  resource_group_name = "rg-network"
}
```

---

## 5️⃣ Using Data Sources with New Resources (REAL SCENARIO)

### 🔹 Scenario

* Network already exists
* You only create VM

---

### 🔹 Terraform Example

```hcl
resource "azurerm_network_interface" "nic" {
  name                = "nic-app-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

👉 This is **enterprise-grade Terraform**

---

## 6️⃣ Data Sources Are Read-Only (IMPORTANT)

❌ You **cannot**:

* Modify
* Delete
* Recreate

Terraform will fail if you try.

---

## 7️⃣ Common Data Sources in Azure Terraform

| Data Source                    | Use                           |
| ------------------------------ | ----------------------------- |
| azurerm_resource_group         | Read RG                       |
| azurerm_virtual_network        | Read VNet                     |
| azurerm_subnet                 | Read subnet                   |
| azurerm_network_security_group | Read NSG                      |
| azurerm_public_ip              | Read IP                       |
| azurerm_key_vault              | Read secrets                  |
| azurerm_client_config          | Current subscription & tenant |

---

## 8️⃣ Using azurerm_client_config (VERY USEFUL)

```hcl
data "azurerm_client_config" "current" {}
```

Use it:

```hcl
tenant_id = data.azurerm_client_config.current.tenant_id
```

Used for:

* Key Vault
* RBAC
* Subscription-aware code

---

## 9️⃣ Data Sources + Count / for_each

### 🔹 Example

```hcl
data "azurerm_subnet" "subnets" {
  for_each             = toset(["subnet-web", "subnet-app"])
  name                 = each.value
  virtual_network_name = "vnet-prod"
  resource_group_name  = "rg-network"
}
```

---

## 🔗 How Data Sources Fit in Real Terraform

```text
Existing Infra (Portal / Other Team)
          ↓
      Data Sources
          ↓
     New Resources
```

---

## ❌ Common Mistakes (VERY IMPORTANT)


❌ Trying to modify data source

❌ Wrong resource name

❌ Wrong resource group

❌ Assuming Terraform created it

❌ Hardcoding IDs instead of data sources

---

## 🧠 Interview Questions (Day 12)

**Q: Difference between resource and data source?**
Resource creates infra, data source reads infra.

**Q: Can data sources modify Azure resources?**
❌ No.

**Q: Why are data sources important?**
To integrate Terraform with existing infrastructure safely.

**Q: When should you use data sources?**
When resources already exist.

---

## 🎯 You Are READY When You Can


✅ Read existing Azure resources

✅ Combine data sources with new resources

✅ Avoid duplication

✅ Write production-grade Terraform

---
