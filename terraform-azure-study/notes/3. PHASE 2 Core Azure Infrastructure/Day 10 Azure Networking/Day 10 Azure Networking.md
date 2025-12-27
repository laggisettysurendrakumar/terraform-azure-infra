# 🟡 Day 10 – Azure Networking (Terraform Focus)

Azure Networking is **FOUNDATIONAL**.
If networking is weak, **VMs won’t work, apps won’t connect, security breaks**.

Today you will master:

* **VNet**
* **Subnet**
* **NSG**
* **Public IP**

---

## 1️⃣ Virtual Network (VNet)

### 🔹 What is a VNet?

A **Virtual Network (VNet)** is a **private network in Azure**, similar to:

* Your **home Wi-Fi network**
* But inside Azure

It allows Azure resources to:

* Communicate privately
* Be isolated from the internet
* Be controlled via security rules

---

### 🔹 Key Properties of VNet

| Property      | Meaning                        |
| ------------- | ------------------------------ |
| Address Space | IP range for the network       |
| Subnets       | Smaller networks inside VNet   |
| Region        | VNet lives in one Azure region |

---

### 🔹 Real-Life Analogy

* **VNet** → Apartment Building
* **Address space** → Total land area
* **Subnets** → Individual floors

---

### 🔹 Terraform Example – VNet

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
```

👉 `10.0.0.0/16` means:

* Total IPs ≈ **65,536**
* Used by all subnets inside this VNet

---

### 🔹 Best Practices (VNet)


✔ Use non-overlapping IP ranges

✔ Plan IP space early

✔ One VNet per environment (dev/test/prod)

---

## 2️⃣ Subnet

### 🔹 What is a Subnet?

A **Subnet** is a **logical division inside a VNet**.

Azure resources (VMs, Load Balancers, etc.) **must live inside a subnet**.

---

### 🔹 Why Subnets Exist

* Security isolation
* Better organization
* Apply different NSG rules

---

### 🔹 Real-Life Analogy

* **VNet** → Apartment building
* **Subnet** → Individual floors
* **VMs** → Flats on that floor

---

### 🔹 Terraform Example – Subnet

```hcl
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

👉 `10.0.1.0/24` means:

* **256 IPs**
* Suitable for small workloads

---

### 🔹 Subnet Design Example

| Subnet     | Purpose     |
| ---------- | ----------- |
| subnet-web | Web servers |
| subnet-app | App servers |
| subnet-db  | Database    |

---

### 🔹 Best Practices (Subnet)


✔ Separate tiers (web/app/db)

✔ Smaller CIDR blocks

✔ Never put everything in one subnet

---

## 3️⃣ Network Security Group (NSG)

### 🔹 What is an NSG?

An **NSG (Network Security Group)** is a **virtual firewall** that controls:

* **Inbound traffic**
* **Outbound traffic**

Rules are based on:

* Source
* Destination
* Port
* Protocol

---

### 🔹 NSG Rule Evaluation

Rules are processed by:

1. **Priority (lowest number first)**
2. First match wins

---

### 🔹 Real-Life Analogy

* **NSG** → Security guard
* **Rules** → Entry checklist
* **Ports** → Doors

---

### 🔹 Terraform Example – NSG

```hcl
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
```

---

### 🔹 NSG Rule – Allow SSH

```hcl
resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
```

---

### 🔹 Where Can NSG Be Attached?

| Attachment | Use                 |
| ---------- | ------------------- |
| Subnet     | Applies to all VMs  |
| NIC        | VM-specific control |

👉 **Best practice:** Attach NSG to **Subnet**

---

### 🔹 Best Practices (NSG)


✔ Deny everything by default

✔ Allow only required ports

✔ Never expose DB ports publicly

✔ Use meaningful priorities

---

## 4️⃣ Public IP

### 🔹 What is a Public IP?

A **Public IP** allows Azure resources to:

* Be reachable from the internet

Without a Public IP:

* VM is **private**
* Only accessible inside VNet

---

### 🔹 Types of Public IP

| Type    | Use                    |
| ------- | ---------------------- |
| Static  | Fixed IP (recommended) |
| Dynamic | Changes on restart     |

---

### 🔹 Terraform Example – Public IP

```hcl
resource "azurerm_public_ip" "pip" {
  name                = "pip-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}
```

---

### 🔹 Real-Life Analogy

* **Public IP** → House address
* Without it → house exists but no one can reach it

---

### 🔹 Best Practices (Public IP)


✔ Use only when required

✔ Prefer Load Balancer over VM IP

✔ Avoid Public IP on databases

---

## 🔗 How Everything Connects (MOST IMPORTANT)

```text
Internet
   ↓
Public IP
   ↓
NSG (Security Rules)
   ↓
Subnet
   ↓
VNet
   ↓
VM
```

👉 **If one layer is wrong → connectivity fails**

---

## 🧠 Common Interview Questions

**Q: Can a VM exist without a subnet?**
❌ No. VM must be in a subnet.

**Q: Difference between VNet and Subnet?**
VNet is the network; Subnet is a segment inside it.

**Q: NSG vs Firewall?**
NSG is basic L4 filtering; Firewall is advanced L7.

**Q: Public IP mandatory for VM?**
❌ No. Only needed for internet access.

---

## 🎯 You Are READY When You Can


✅ Create VNet & Subnet with Terraform

✅ Attach NSG correctly

✅ Secure VM networking

✅ Debug connectivity issues

---
