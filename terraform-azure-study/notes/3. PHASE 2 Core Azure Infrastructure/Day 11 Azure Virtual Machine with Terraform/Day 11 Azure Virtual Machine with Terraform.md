# 🟡 Day 11 – Azure Virtual Machine with Terraform

**(Linux VM • SSH Auth • OS Disk • NIC)**

Azure VM creation is where **networking + compute + security** come together.
If you understand this day well, **80% of Azure Terraform interviews are covered**.

---

## 🔗 What You Will Build Today

A **Linux VM** with:

* Network Interface (NIC)
* Subnet + NSG
* Public IP
* SSH key authentication
* OS Disk

---

## 1️⃣ Network Interface (NIC) – START HERE

### 🔹 What is a NIC?

A **Network Interface (NIC)** connects a VM to:

* Subnet
* VNet
* NSG
* Public IP

👉 **A VM cannot exist without a NIC**

---

### 🔹 Real-Life Analogy

* **VM** → Laptop
* **NIC** → Wi-Fi / Ethernet card
* No NIC → No network access ❌

---

### 🔹 Terraform Example – NIC

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

### 🔹 NIC Best Practices


✔ One NIC per VM (start simple)

✔ Attach NSG at **subnet level**, not NIC

✔ Avoid multiple public IPs

---

## 2️⃣ Linux Virtual Machine

### 🔹 What is a Linux VM?

A **Linux VM** is a virtual server running:

* Ubuntu
* RHEL
* CentOS
* Debian

Used for:

* Web servers
* APIs
* Terraform labs
* DevOps workloads

---

### 🔹 VM Core Components

| Component | Purpose   |
| --------- | --------- |
| Size      | CPU & RAM |
| Image     | OS        |
| NIC       | Network   |
| OS Disk   | Boot disk |
| Auth      | SSH keys  |

---

### 🔹 Terraform Example – Linux VM

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

### 🔹 VM Size Explanation

| Size   | Use           |
| ------ | ------------- |
| B1s    | Small testing |
| B2s    | Dev / Labs    |
| D2s_v3 | Production    |

👉 Start small → scale later

---

## 3️⃣ SSH Key Authentication (VERY IMPORTANT)

### 🔹 Why SSH Keys?

❌ Password login:

* Weak
* Hackable
* Not allowed in prod

✅ SSH keys:

* Secure
* Automated
* Industry standard

---

### 🔹 Generate SSH Key (Local)

```bash
ssh-keygen -t rsa -b 4096
```

Files created:

* `id_rsa` → private key (DO NOT SHARE)
* `id_rsa.pub` → public key (safe)

---

### 🔹 How SSH Works (Simple)

* Azure stores **public key**
* You connect using **private key**
* Keys match → access granted 🔐

---

### 🔹 Connect to VM

```bash
ssh azureuser@<PUBLIC_IP>
```

---

### 🔹 SSH Best Practices


✔ Disable password auth

✔ Never commit private keys

✔ Use separate keys per project

---

## 4️⃣ OS Disk

### 🔹 What is OS Disk?

The **OS Disk**:

* Stores Linux OS
* Required for boot
* Automatically attached to VM

---

### 🔹 OS Disk Options

| Option       | Meaning              |
| ------------ | -------------------- |
| Standard_LRS | Cheap, dev           |
| Premium_LRS  | High performance     |
| Caching      | ReadWrite / ReadOnly |

---

### 🔹 Terraform OS Disk Block

```hcl
os_disk {
  name                 = "osdisk-linux-vm"
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
}
```

---

### 🔹 Real-Life Analogy

* **OS Disk** → Laptop hard disk
* Without it → Laptop won’t boot ❌

---

### 🔹 OS Disk Best Practices


✔ Use Standard for dev

✔ Premium for prod

✔ Never delete disk accidentally

---

## 5️⃣ How All Components Connect (CRITICAL)

```text
Internet
   ↓
Public IP
   ↓
NIC
   ↓
Subnet
   ↓
VNet
   ↓
Linux VM
   ↓
OS Disk
```

👉 If **NIC or SSH** is wrong → VM unreachable
👉 If **disk** is wrong → VM won’t boot

---

## ❌ Common Mistakes (VERY IMPORTANT)


❌ Forgot SSH port (22) in NSG

❌ Password authentication enabled

❌ Wrong subnet ID

❌ No public IP but trying SSH

❌ Using huge VM sizes unnecessarily

---

## 🧠 Interview Questions (Day 11)

**Q: Can a VM exist without NIC?**
❌ No

**Q: Why SSH keys instead of password?**
Security + automation

**Q: Difference between OS disk & data disk?**
OS disk boots OS; data disk stores application data

**Q: Is Public IP mandatory?**
❌ No (only for internet access)

---

## 🎯 You Are READY When You Can


✅ Create Linux VM using Terraform

✅ Connect via SSH key

✅ Understand NIC, OS disk, networking flow

✅ Debug VM access issues

---
