# 🔵 Day 26–27 – Capstone Project

## 📌 Multi-Environment Azure Setup with Remote State

---

## 🎯 Project Objective

Build **Dev / Test / Prod environments** with:

* **Clean folder-based structure**
* **Reusable Terraform modules**
* **Azure Storage remote backend**
* **Strong isolation between environments**
* **Safe, repeatable deployments**

👉 This is **resume-worthy** and **interview-defining**.

---

## 🧠 What You Will Prove by Completing This

By the end, you can confidently say:

✅ I can design production Terraform architecture

✅ I can manage multiple environments safely

✅ I understand remote state & locking deeply

✅ I can recover, scale, and refactor Terraform code

---

## 🏗️ High-Level Architecture

Each environment (dev / test / prod) will have:

* Resource Group
* Virtual Network
* Subnet
* NSG
* Linux VM
* Remote Terraform state

All environments:

* Share **same modules**
* Use **different variables**
* Have **separate state files**

---

## 🔍 Visual: Multi-Environment Terraform Architecture

![Image](https://miro.medium.com/0%2AD6TQgxD0xMTE-G4t.png)

![Image](https://blog.rufer.be/wp-content/uploads/2023/11/az-devops-environments.png)

![Image](https://miro.medium.com/1%2Aq2enyfjQ5Y_qYER6hhA6IA.png)

---

## 📁 Final Folder Structure (ENTERPRISE STANDARD)

```text
terraform-azure-capstone/
│
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── compute/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   │
│   ├── test/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   │
│   └── prod/
│       ├── main.tf
│       ├── backend.tf
│       └── terraform.tfvars
│
├── providers.tf
├── versions.tf
└── README.md
```

✔ Clear separation

✔ Safe production design

✔ CI/CD friendly

---

## 🧩 Day 26 – Build Reusable Modules

---

## 1️⃣ Network Module (`modules/network`)

### 🔹 What This Module Creates

* Virtual Network
* Subnet
* Network Security Group

---

### 🔹 `modules/network/main.tf`

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
  address_prefixes     = var.subnet_prefix
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
}
```

---

### 🔹 Outputs

```hcl
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
```

---

## 2️⃣ Compute Module (`modules/compute`)

### 🔹 What This Module Creates

* Linux VM
* NIC
* Public IP

---

### 🔹 `modules/compute/main.tf`

```hcl
resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
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
    public_key = file(var.ssh_key_path)
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

## 🧠 Day 27 – Environment Configuration

---

## 3️⃣ Remote Backend per Environment

### 🔹 `environments/dev/backend.tf`

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate01"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

Each environment has:

* **Different key**
* **Same storage account**
* **Separate state**

---

## 🔍 Visual: Remote State Isolation

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AazlDiCZlFfytmHqEF3reyw.png)

![Image](https://iamachs.com/images/posts/azure-terraform/part-4/terraform-state-workflow.jpg)

---

## 4️⃣ Environment Main File (`environments/dev/main.tf`)

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-dev"
  location = var.location
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = "vnet-dev"
  subnet_name         = "subnet-dev"
  nsg_name            = "nsg-dev"
  address_space       = ["10.0.0.0/16"]
  subnet_prefix       = ["10.0.1.0/24"]
}

module "compute" {
  source              = "../../modules/compute"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  subnet_id           = module.network.subnet_id
  vm_name             = "vm-dev"
  vm_size             = var.vm_size
  admin_username      = "azureuser"
  ssh_key_path        = "~/.ssh/id_rsa.pub"
}
```

---

## 5️⃣ Environment Variables (`terraform.tfvars`)

### 🔹 Dev

```hcl
location = "East US"
vm_size  = "Standard_B2s"
```

### 🔹 Prod

```hcl
location = "East US"
vm_size  = "Standard_D2s_v3"
```

✔ Same code

✔ Different behavior

---

## 🚀 How to Run the Project

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

Repeat for:

* `test`
* `prod`

---

## 🔐 Safety & Best Practices Applied

✔ Folder-based isolation

✔ Remote backend with locking

✔ No hard-coded secrets

✔ Reusable modules

✔ Clean naming & tagging

---

## ❌ Common Mistakes to Avoid

❌ Same backend key for all envs

❌ Editing prod from dev folder

❌ Hardcoding VM sizes

❌ No module usage

❌ No state separation

---

## 🧠 Interview Questions (Capstone Level)

**Q: How do you manage multiple environments in Terraform?**
Folder-based environments with separate backends and shared modules.

**Q: Why remote state is mandatory here?**
To ensure locking, security, and team collaboration.

**Q: Can dev destroy prod?**
No—separate folders + separate state.

**Q: Why modules?**
Reusability, consistency, and maintainability.

---

## 🎯 You Have Reached ADVANCED LEVEL 🎉

You can now:

✅ Design enterprise Terraform architecture

✅ Manage multi-env safely

✅ Debug & recover infra

✅ Explain Terraform end-to-end

---
