# 🔵 Day 29 – Create Custom Modules

**(VNet Module • VM Module)**

Custom modules turn Terraform into **scalable infrastructure engineering**.
Today you’ll learn **how to design, structure, and consume** clean modules.

---

## 🎯 What You’ll Build Today

* A **VNet module** (network foundation)
* A **VM module** (compute layer)
* Clear **inputs/outputs**
* Safe **reuse across environments**

---

## 🧠 Module Design Principles (Before Coding)

✔ One responsibility per module

✔ No environment logic inside modules

✔ No backend config inside modules

✔ Inputs via variables, outputs via outputs

✔ Opinionated defaults, configurable overrides

---

## 📁 Recommended Repo Structure

```text
terraform-azure/
│
├── modules/
│   ├── vnet/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   └── vm/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
└── environments/
    ├── dev/
    └── prod/
```

---

## 🧩 Part A – VNet Module

### 1️⃣ What the VNet Module Creates

* Virtual Network
* Subnet(s)
* Network Security Group (NSG)
* NSG → Subnet association

---

### 2️⃣ `modules/vnet/variables.tf`

```hcl
variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "vnet_name"           { type = string }
variable "address_space"       { type = list(string) }

variable "subnet_name"         { type = string }
variable "subnet_prefixes"     { type = list(string) }

variable "nsg_name"            { type = string }
variable "allowed_ports" {
  type    = list(number)
  default = [22]
}
```

---

### 3️⃣ `modules/vnet/main.tf`

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefixes
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

dynamic "security_rule" {
  for_each = toset(var.allowed_ports)
  content {
    name                       = "allow-${security_rule.value}"
    priority                   = 100 + security_rule.key
    direction                  = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = tostring(security_rule.value)
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
}
```

```hcl
resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
```

---

### 4️⃣ `modules/vnet/outputs.tf`

```hcl
output "vnet_id"   { value = azurerm_virtual_network.vnet.id }
output "subnet_id" { value = azurerm_subnet.subnet.id }
output "nsg_id"    { value = azurerm_network_security_group.nsg.id }
```

---

### 🧠 Why This Design Works

* Ports are **configurable**
* NSG logic is **inside the module**
* Consumers only pass **inputs**, no internals

---

## 🧩 Part B – VM Module

### 5️⃣ What the VM Module Creates

* Public IP (optional-ready)
* NIC
* Linux VM
* OS disk

---

### 6️⃣ `modules/vm/variables.tf`

```hcl
variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "vm_name"             { type = string }
variable "vm_size"             { type = string }
variable "admin_username"      { type = string }
variable "ssh_public_key_path" { type = string }

variable "subnet_id"           { type = string }
variable "enable_public_ip" {
  type    = bool
  default = true
}
```

---

### 7️⃣ `modules/vm/main.tf`

```hcl
resource "azurerm_public_ip" "pip" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
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

### 8️⃣ `modules/vm/outputs.tf`

```hcl
output "vm_id"        { value = azurerm_linux_virtual_machine.vm.id }
output "private_ip"   { value = azurerm_network_interface.nic.private_ip_address }
output "public_ip" {
  value       = var.enable_public_ip ? azurerm_public_ip.pip[0].ip_address : null
  description = "Public IP if enabled"
}
```

---

## 🔍 Visual: Module Interaction Flow

![Image](https://brendanthompson.com/content/images/posts/2021/11/my-terraform-development-workflow/terraform-development-workflow.png)

![Image](https://azure.github.io/Azure-Verified-Modules/images/usage/solution-development/avm-virtualmachine-example1-tf.png)

![Image](https://www.edrandall.uk/posts/tf-modules-vars/terraform-modules-2.png)

---

## 🔗 Consuming the Modules (Environment)

### 9️⃣ `environments/dev/main.tf`

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-dev"
  location = var.location
}

module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = "vnet-dev"
  address_space       = ["10.0.0.0/16"]
  subnet_name         = "subnet-dev"
  subnet_prefixes     = ["10.0.1.0/24"]
  nsg_name            = "nsg-dev"
  allowed_ports       = [22, 80]
}

module "vm" {
  source                = "../../modules/vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  vm_name               = "vm-dev"
  vm_size               = "Standard_B2s"
  admin_username        = "azureuser"
  ssh_public_key_path   = "~/.ssh/id_rsa.pub"
  subnet_id             = module.vnet.subnet_id
  enable_public_ip      = true
}
```

---

## 🔍 Visual: Folder-Based Environments Using Modules

![Image](https://i0.wp.com/wahlnetwork.com/wp-content/uploads/2020/04/image-19.png?fit=1038%2C658\&ssl=1)

![Image](https://miro.medium.com/1%2A4hswCxEEkkZtU6-ddp_riA.png)

---

## ❌ Common Module Mistakes (Avoid These)

❌ Hardcoding environment names

❌ Putting backend inside modules

❌ Too many responsibilities in one module

❌ Exposing too many outputs

❌ Changing module interfaces frequently

---

## 🧠 Interview Questions (Day 29)

**Q: Why split VNet and VM into separate modules?**
Single responsibility, better reuse, safer changes.

**Q: Can modules manage backends?**
❌ No. Backends belong to root modules.

**Q: How do modules communicate?**
Via outputs and input variables.

**Q: How do you make modules environment-agnostic?**
No env logic inside modules; pass everything via variables.

---

## 🎯 You Are READY When You Can

✅ Design clean custom modules

✅ Pass data between modules

✅ Reuse modules across envs

✅ Explain module decisions confidently

---
