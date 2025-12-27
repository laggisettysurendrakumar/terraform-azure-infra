# 🔵 Day 33 – Scaling & Availability

This day answers a critical production question:
> ❓ *How do you keep applications running when Azure has failures?*


**(Availability Sets • Availability Zones)**

High availability is about **design**, not just creating VMs.
Azure provides **two core mechanisms** to protect workloads from failures:

1. **Availability Sets**
2. **Availability Zones**

---

## 🧠 Why Availability Matters

Without availability design:

* A single hardware failure can take down your app ❌
* Planned Azure maintenance can cause downtime ❌

With proper design:

✔ Fault isolation

✔ Maintenance resilience

✔ Higher SLA

✔ Production readiness

---

## 1️⃣ Availability Sets (DATACENTER-LEVEL PROTECTION)

### 🔹 What Is an Availability Set?

An **Availability Set** ensures that multiple VMs are placed on:

* **Different physical hardware**
* **Different power & network sources**

👉 Protects against **hardware failures and planned maintenance**
👉 Works **within a single Azure datacenter**

---

### 🔹 Key Concepts

| Concept            | Meaning                  |
| ------------------ | ------------------------ |
| Fault Domain (FD)  | Different physical racks |
| Update Domain (UD) | Maintenance groups       |

Azure ensures:

* Not all VMs go down together
* Updates happen **one domain at a time**

---

### 🔹 Real-Life Analogy

* Fault Domains → Different electrical circuits ⚡
* Update Domains → Servicing floors one by one 🛠

---

### 🔹 Terraform – Availability Set

```hcl
resource "azurerm_availability_set" "avset" {
  name                         = "avset-app"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}
```

---

### 🔹 Attach VM to Availability Set

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-app-1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"

  availability_set_id = azurerm_availability_set.avset.id
}
```

---

### 🔹 Important Rules (INTERVIEW POINT)

❗ VM **must be created inside** availability set
❗ You **cannot add an existing VM** later

---

### 🔹 When to Use Availability Sets

✔ Region does **not support zones**

✔ Legacy architectures

✔ Cost-sensitive workloads

---

## 🔍 Visual: Availability Set Placement

![Image](https://learn.microsoft.com/en-us/azure/virtual-machines/media/disks-high-availability/disks-availability-set.png)

![Image](https://www.c-sharpcorner.com/article/availability-set-fault-domains-and-update-domains-in-azure-virtual-machie/Images/Fault%20Domain-.jpg)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A7x7SmXVPuUZyP9GbOISZbA.png)

---

## 2️⃣ Availability Zones (REGION-LEVEL PROTECTION)

### 🔹 What Are Availability Zones?

**Availability Zones** are:

* Physically separate datacenters
* Within the **same Azure region**
* Each with independent:

  * Power
  * Cooling
  * Networking

👉 Protects against **entire datacenter failures**

---

### 🔹 Example Regions with Zones

* East US
* Central India
* West Europe

(Not all regions support zones)

---

### 🔹 Real-Life Analogy

* Zones → Different buildings in the same city 🏙
* One building fails → others continue

---

### 🔹 Terraform – Zonal VM

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-zone-1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  zone                = "1"
}
```

---

### 🔹 Multiple VMs Across Zones

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = {
    "1" = "vm-zone-1"
    "2" = "vm-zone-2"
    "3" = "vm-zone-3"
  }

  name  = each.value
  zone  = each.key
  size  = "Standard_B2s"
}
```

✔ Zone-level isolation

✔ High SLA

---

## 🔍 Visual: Availability Zones Architecture

![Image](https://agileit.com/_astro/az-graphic-two.C0qDynBR.png)

![Image](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/media/azure-landing-zone-architecture-diagram-hub-spoke.svg)

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2018/03/az-3-multi.png?fit=1230%2C899\&ssl=1)

---

## 3️⃣ Availability Sets vs Availability Zones (INTERVIEW GOLD)

| Feature               | Availability Set       | Availability Zones   |
| --------------------- | ---------------------- | -------------------- |
| Scope                 | Single datacenter      | Multiple datacenters |
| Failure Protection    | Hardware & maintenance | Datacenter failure   |
| SLA                   | Lower                  | Higher               |
| Complexity            | Simple                 | Medium               |
| Cost                  | Lower                  | Slightly higher      |
| Modern recommendation | ❌                      | ✅                    |

👉 **Use Zones whenever available**

---

## 4️⃣ Load Balancer + Availability (REAL ARCHITECTURE)

High availability **always pairs with Load Balancer**.

### 🔹 Common Pattern

```text
Users
  ↓
Public Load Balancer
  ↓
VMs in different Zones / Availability Set
```

✔ One VM down → traffic shifts automatically

---

## 5️⃣ What About Scaling?

Availability ≠ Scaling, but they work together.

* Availability → **stay up**
* Scaling → **handle more load**

Later (VM Scale Sets):

* Auto scale
* Zone-aware
* LB integrated

---

## 6️⃣ Design Decision Guide (VERY IMPORTANT)

### ✅ Use Availability Sets When:

* Zones not supported
* Simple HA needed
* Legacy workloads

### ✅ Use Availability Zones When:

* Production systems
* Mission-critical apps
* SLA matters
* Modern architecture

---

## ❌ Common Mistakes

❌ Assuming single VM is “highly available”

❌ Mixing zones incorrectly

❌ Forgetting Load Balancer

❌ Trying to move existing VM into availability set

❌ Using Availability Set when Zones are available

---

## 🧠 Interview Questions (Day 33)

**Q: Difference between Availability Set and Zone?**
Set protects within datacenter; Zone protects across datacenters.

**Q: Can you use both together?**
❌ No. Zones replace sets.

**Q: Which gives higher SLA?**
Availability Zones.

**Q: Is Load Balancer required?**
Yes, for real HA.

---

## 🎯 You Are READY When You Can

✅ Design HA architecture

✅ Choose between Set vs Zone

✅ Implement both using Terraform

✅ Explain availability clearly in interviews

---
