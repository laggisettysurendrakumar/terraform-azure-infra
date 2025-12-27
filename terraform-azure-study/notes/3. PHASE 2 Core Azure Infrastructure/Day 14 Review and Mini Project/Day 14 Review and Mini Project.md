# 🟡 Day 14 – Review + Mini Project

**Project: VNet + Subnet + NSG + Linux VM (Terraform)**

---

## 🎯 Goal of This Mini Project

By the end of this project, you will be able to:

* Design Azure networking correctly
* Secure traffic using NSG
* Create a Linux VM with SSH access
* Understand how all components connect
* Debug common Terraform & Azure issues

👉 This is **interview-level + real-world ready**

---

## 🧠 Architecture (What You’re Building)

```text
Internet
   ↓
Public IP
   ↓
NSG (Allow SSH)
   ↓
Subnet
   ↓
VNet
   ↓
NIC
   ↓
Linux VM
   ↓
OS Disk
```

---

## 📁 Recommended Project Structure

```text
terraform-azure-mini-project/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── terraform.tfvars
```

---

## 1️⃣ Review: Components & Responsibilities

| Component | Responsibility         |
| --------- | ---------------------- |
| VNet      | Private Azure network  |
| Subnet    | Segment inside VNet    |
| NSG       | Firewall rules         |
| Public IP | Internet access        |
| NIC       | Connects VM to network |
| Linux VM  | Compute resource       |

---

## 2️⃣ Provider Configuration (`providers.tf`)

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

---

## 3️⃣ Resource Group (`main.tf`)

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-mini-project"
  location = "East US"
}
```

---

## 4️⃣ Virtual Network

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dev"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
```

### 🧠 Why `/16`?

* Large enough for future growth
* Industry-standard for environments

---

## 5️⃣ Subnet

```hcl
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

### 🧠 Why `/24`?

* ~256 IPs
* Perfect for a single tier

---

## 6️⃣ Network Security Group (NSG)

### 🔹 Create NSG

```hcl
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
```

---

### 🔹 Allow SSH (Port 22)

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

### 🔹 Associate NSG to Subnet (BEST PRACTICE)

```hcl
resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
```

---

## 7️⃣ Public IP

```hcl
resource "azurerm_public_ip" "pip" {
  name                = "pip-linux-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}
```

---

## 8️⃣ Network Interface (NIC)

```hcl
resource "azurerm_network_interface" "nic" {
  name                = "nic-linux-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
```

---

## 9️⃣ Linux Virtual Machine

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "linux-vm-dev"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-linux-vm"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
```

---

## 🔐 SSH Access Test

```bash
ssh azureuser@<PUBLIC_IP>
```

✅ If login works → **project successful**

---

## 10️⃣ Outputs (`outputs.tf`)

```hcl
output "vm_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}
```

---

## 🚀 How to Run This Project

```bash
terraform init
terraform plan
terraform apply
```

---

## ❌ Common Errors & Fixes

| Issue          | Cause               | Fix              |
| -------------- | ------------------- | ---------------- |
| SSH timeout    | NSG missing port 22 | Add SSH rule     |
| VM unreachable | No Public IP        | Attach Public IP |
| Auth failed    | Wrong SSH key       | Verify key path  |
| Apply fails    | Name conflicts      | Use unique names |

---

## 🧠 Interview Questions from This Project

**Q: Why attach NSG to subnet instead of NIC?**
Centralized security, easier management.

**Q: Can VM exist without NIC?**
❌ No.

**Q: Why disable password authentication?**
Security best practice.

**Q: What happens if NSG rule priority conflicts?**
Lower number wins.

---

## 🎯 You Are READY When


✅ You can build this without copy-paste

✅ You understand each resource’s role

✅ You can debug SSH & networking issues

✅ You can explain architecture clearly

---

## 📌 What You’ve Completed (Phase 2 Halfway)


✔ Azure Networking

✔ Linux VM

✔ Secure access

✔ Real Terraform project

---

