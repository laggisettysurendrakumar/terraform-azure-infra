# Using Loops in Terraform to Scale Azure Resources

Terraform loops help you write **clean, scalable, and reusable infrastructure code**. 
Instead of repeating similar resource blocks again and again, you can define them once and let Terraform handle repetition using loops such as `for_each`, `dynamic` blocks, and `count`.

In this guide, you will build a **Network Security Group (NSG) module** that:

* Uses **loops to generate multiple security rules**
* Scales the module itself using **count**
* Follows **DRY (Don’t Repeat Yourself)** principles

---

## 1️⃣ Why Loops Matter in Terraform

![Image](https://www.cloudbolt.io/wp-content/uploads/img1-1024x870-1.png)

![Image](https://www.danzabinski.com/tf-comparing-count-and-for_each/for_each-drives.PNG)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884289/notes-assets/images/Terragrunt-for-Beginners-The-DRY-Principle/dry-principle-configuration-inheritance-reuse.jpg)

Loops allow Terraform to:

* Reduce duplicate code
* Scale resources easily
* Handle variable-sized configurations
* Improve readability and maintenance

In Azure, this is especially useful for **NSG rules**, **VMs**, **subnets**, and **load balancer rules**, where repetition is common.

---

## 2️⃣ Module-Based Project Structure

![Image](https://media.beehiiv.com/cdn-cgi/image/fit%3Dscale-down%2Cformat%3Dauto%2Conerror%3Dredirect%2Cquality%3D80/uploads/asset/file/a70941e1-5fb2-4a29-a70b-a671150e9298/directory_2.png?t=1730702773)

![Image](https://miro.medium.com/1%2A5Te9ByjsPEkKHHgEiXxsLA.png)

![Image](https://media.licdn.com/dms/image/v2/D5622AQFdhUxGbRAFVA/feedshare-shrink_800/B56Zi_aglhG4Ag-/0/1755558058304?e=2147483647\&t=LSvo2XdBV-RwUHcHzvAWvmeftXSlu28psp-MEHrMQP4\&v=beta)

We’ll use a **local module** to deploy Network Security Groups.

### Folder layout:

```
terraformlab
 ├── main.tf
 └── modules
     └── nsg
         ├── main.tf
         └── variables.tf
```

This structure keeps infrastructure **organized and reusable**.

---

## 3️⃣ Defining Loop-Friendly Variables

![Image](https://vcloud-lab.com/files/images/05919143-f364-4875-ba78-24768df2ab44.png)

![Image](https://www.cherryservers.com/v3/img/containers/blog_content/2025-07-28/06.png/2530364ffaec27bacfcb51006d479f2e/06.png?id=1753703224)

![Image](https://www.devopsschool.com/blog/wp-content/uploads/2023/04/terraform-variable-types-1.png)

Create `modules/nsg/variables.tf`

```hcl
variable "nsg_rules" {
  description = "List of NSG security rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

variable "nsg_name" {
  type        = string
  description = "Name of the Network Security Group"
}

variable "resource_group" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region for NSG"
  default     = "eastus2"
}
```

### Why `list(object)`?

This allows multiple security rules to be defined **once** and looped over dynamically.

---

## 4️⃣ Creating Dynamic NSG Rules Using Loops

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2ASQepXMc5ssgKqCcIFF9ccQ.png)

![Image](https://i0.wp.com/www.ciraltos.com/wp-content/uploads/2022/01/Security-Rules.jpg?resize=706%2C1024\&ssl=1)

![Image](https://miro.medium.com/v2/resize%3Afit%3A2000/1%2AsCQP6zeuPgyi_Kke5rs0Vw.png)

Create `modules/nsg/main.tf`

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
```

### How This Works

* `dynamic` is used for repeatable nested blocks
* `for_each` loops through every rule object
* Terraform creates one `security_rule` per item

This avoids writing multiple hardcoded rule blocks.

---

## 5️⃣ Consuming the NSG Module (Single Instance)

![Image](https://azapril.dev/wp-content/uploads/2020/03/variables.png)

![Image](https://k21academy.com/wp-content/uploads/2020/08/Terraform-IaC_BlogImage.png)

![Image](https://i0.wp.com/www.ciraltos.com/wp-content/uploads/2022/01/Security-Rules.jpg?resize=706%2C1024\&ssl=1)

Create `terraformlab/main.tf`

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "nsg" {
  source = "./modules/nsg"

  nsg_name       = "web-nsg"
  resource_group = "rg-demo"
  location       = "westus"

  nsg_rules = [
    {
      name                       = "allow-http"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-ssh"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
```

Terraform will create **one NSG with two rules**.

---

## 6️⃣ Scaling the Module Using `count`

![Image](https://www.datocms-assets.com/2885/1598575018-count-blog-image1.png)

![Image](https://spaceliftio.wpcomstaging.com/wp-content/uploads/2022/02/Deploying-Multiple-Resources-with-Count.png)

![Image](https://infisical.com/static/images/terraform-modules-organization-scaling.png)

Now let’s **scale the module** itself.

### Updated `terraformlab/main.tf`

```hcl
module "nsg" {
  count  = 3
  source = "./modules/nsg"

  nsg_name       = "web-nsg-${count.index}"
  resource_group = "rg-demo"
  location       = "westus"

  nsg_rules = [
    {
      name                       = "allow-http"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-ssh"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
```

### Result

Terraform will deploy:

* `web-nsg-0`
* `web-nsg-1`
* `web-nsg-2`

Each NSG will contain **identical rules**, created via a dynamic loop.

---

## 7️⃣ Running Terraform

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/02/terraform-init-command-terminal-output.png?resize=400%2C242\&ssl=1)

![Image](https://gdservices.io/wp-content/uploads/2022/12/nsg1.jpg)

![Image](https://www.techielass.com/content/images/2023/01/terraform-flow.png)

Run the following:

```bash
az login
cd terraformlab
terraform init
terraform plan
terraform apply
```

Terraform will show:

* 3 NSGs created
* Each NSG has 2 security rules

---

## 8️⃣ Key Terraform Concepts Used

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2ASQepXMc5ssgKqCcIFF9ccQ.png)

![Image](https://media.licdn.com/dms/image/v2/D5622AQGPmRp8owiVqQ/feedshare-shrink_800/B56Zeqfe_2G0Ao-/0/1750912074256?e=2147483647\&t=ZHtNHkvG-9Hun_W4t3jTT0WwkBpODuv3gWr2qqA_fag\&v=beta)

![Image](https://www.cloudbolt.io/wp-content/uploads/img1-1024x870-1.png)

| Feature         | Purpose                    |
| --------------- | -------------------------- |
| `dynamic` block | Loop nested blocks         |
| `for_each`      | Iterate complex objects    |
| `count`         | Scale resources or modules |
| `count.index`   | Generate unique names      |
| Modules         | Code reusability           |

These patterns are **very common in real production Terraform code**.

---

## ✅ Summary

In this lab, you learned how to:

* Use **dynamic blocks** for NSG rules
* Loop over **list(object)** variables
* Scale infrastructure using **count**
* Deploy multiple Azure NSGs cleanly
* Follow **DRY and modular design**

This approach is widely used in:

* Enterprise Azure environments
* Multi-tier architectures
* CI/CD-driven Terraform deployments

---
