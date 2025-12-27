# 🟡 Day 11 – Azure Windows Virtual Machine with Terraform

**(Windows VM • Admin Auth • OS Disk • NIC • RDP)**

Windows VM creation in Azure is **very common in enterprises** (legacy apps, .NET, IIS, Windows services).
Terraform handling is **slightly different from Linux**, especially around **authentication**.

---

## 🔗 What You Will Build Today (Windows)

A **Windows VM** with:

* Network Interface (NIC)
* Subnet + NSG
* Public IP
* Username + Password authentication
* OS Disk
* RDP access (3389)

---

## 1️⃣ Network Interface (NIC) – SAME AS LINUX

### 🔹 What is a NIC?

A **NIC** connects the Windows VM to:

* Subnet
* VNet
* NSG
* Public IP

👉 **Windows VM also cannot exist without NIC**

---

### 🔹 Terraform Example – NIC

```hcl
resource "azurerm_network_interface" "nic" {
  name                = "nic-windows-vm"
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

👉 Same NIC logic as Linux VM

---

## 2️⃣ Windows Virtual Machine

### 🔹 What is a Windows VM?

A **Windows VM** is a virtual server running:

* Windows Server 2019
* Windows Server 2022

Used for:

* IIS / ASP.NET apps
* Legacy enterprise apps
* Windows-based tooling
* Domain-joined servers

---

### 🔹 Core Components (Windows VM)

| Component | Purpose             |
| --------- | ------------------- |
| Size      | CPU & RAM           |
| Image     | Windows OS          |
| NIC       | Network             |
| OS Disk   | Boot disk           |
| Auth      | Username & Password |

---

### 🔹 Terraform Example – Windows VM

```hcl
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "windows-vm-dev"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"

  admin_username = "azureadmin"
  admin_password = "StrongPassword@123"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    name                 = "osdisk-windows-vm"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
```

---

### 🔹 IMPORTANT: Password Rules

Azure **requires strong password**:


✔ At least 12 characters

✔ Uppercase + lowercase

✔ Number

✔ Special character

❌ Weak passwords → Terraform apply fails

---

## 3️⃣ Authentication for Windows VM

### 🔹 How Windows VM Auth Works

Unlike Linux:

* ❌ SSH keys not default
* ✅ Username + Password
* Optional: Azure AD login (advanced)

---

### 🔹 RDP Access

Windows VM uses:

* **Port 3389**
* **Remote Desktop Protocol (RDP)**

👉 NSG **must allow port 3389**

---

### 🔹 NSG Rule – Allow RDP

```hcl
resource "azurerm_network_security_rule" "rdp" {
  name                        = "Allow-RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
```

---

### 🔹 Connect to Windows VM (RDP)

1. Copy **Public IP**
2. Open **Remote Desktop (mstsc)**
3. Enter:

   * Username: `azureadmin`
   * Password: (from Terraform)

---

### 🔹 Security Best Practices (Windows Auth)


✔ Restrict RDP source IP

✔ Use Bastion instead of Public IP (prod)

✔ Rotate passwords

✔ Avoid exposing 3389 publicly

---

## 4️⃣ OS Disk (Windows)

### 🔹 What is OS Disk?

The **OS Disk**:

* Stores Windows OS
* Required to boot VM
* Attached automatically

---

### 🔹 Terraform OS Disk Block

```hcl
os_disk {
  name                 = "osdisk-windows-vm"
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
}
```

---

### 🔹 Disk Types

| Type         | Use                 |
| ------------ | ------------------- |
| Standard_LRS | Dev / test          |
| Premium_LRS  | Production          |
| Ultra        | High IOPS workloads |

---

### 🔹 Real-Life Analogy

* **OS Disk** → Windows installed hard disk
* Without it → PC won’t start ❌

---

## 5️⃣ Linux VM vs Windows VM (VERY IMPORTANT)

| Feature      | Linux VM                      | Windows VM                      |
| ------------ | ----------------------------- | ------------------------------- |
| Resource     | azurerm_linux_virtual_machine | azurerm_windows_virtual_machine |
| Auth         | SSH keys                      | Username + Password             |
| Default Port | 22                            | 3389                            |
| Security     | Key-based                     | Password-based                  |
| Cost         | Lower                         | Higher                          |

👉 Interviewers LOVE this comparison

---

## 🔗 Full Connectivity Flow (Windows)

```text
Internet
   ↓
Public IP
   ↓
NSG (Allow 3389)
   ↓
NIC
   ↓
Subnet
   ↓
VNet
   ↓
Windows VM
   ↓
OS Disk
```

---

## ❌ Common Mistakes (Windows VM)


❌ Weak admin password

❌ Forgot NSG rule for 3389

❌ Exposing RDP to entire internet

❌ Using large VM sizes unnecessarily

❌ Storing password in plain text (prod)

---

## 🧠 Interview Questions (Windows VM)

**Q: Why Windows VM uses password auth?**
Because Windows relies on RDP and local admin authentication by default.

**Q: Is SSH possible on Windows VM?**
Yes, but not default (requires OpenSSH setup).

**Q: Is Public IP mandatory?**
❌ No. Use Bastion or private access in prod.

**Q: Which is more secure – Linux or Windows VM?**
Linux (SSH keys, smaller attack surface).

---

## 🎯 You Are READY When You Can


✅ Create Windows VM using Terraform

✅ Configure NIC & OS disk

✅ Connect using RDP

✅ Secure RDP access

✅ Explain Linux vs Windows VM differences

---

## 📌 What You Have Mastered (Day 11 Complete)


✔ Linux VM creation

✔ Windows VM creation

✔ NIC, OS disk, auth differences

✔ Real production patterns

---
