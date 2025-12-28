# Exploring Terraform State in Azure

## Introduction

Terraform does not query Azure every time to understand what resources already exist.
Instead, it relies on a **state file** as the **single source of truth**.

The **Terraform state**:

* Maps Terraform resources to real Azure resources
* Tracks current configuration and metadata
* Enables Terraform to calculate **what to create, update, or destroy**

Mismanaging state can lead to:

* Duplicate resources
* Accidental deletions
* Production outages

In this lab, you’ll explore **how Terraform state works**, how it changes, and why it must be protected.

---

## What Is Terraform State?

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AlPfL5tZkTMamzfh0.jpg)

![Image](https://miro.medium.com/1%2AlmYNNT40GBPaVEL2K4zzNg.png)

![Image](https://brendanthompson.com/content/images/posts/2023/01/what-is-terraform-state/parts-of-terraform--state.png)

The state file:

* Is usually named `terraform.tfstate`
* Is stored locally by default
* Contains:

  * Resource IDs
  * Attributes
  * Dependencies
  * Sometimes sensitive values

---

## Lab Objective

In this lab, you will:

* Deploy multiple VNets and subnets
* Inspect the Terraform state file
* Modify infrastructure and observe state updates
* Simulate state loss
* Restore state using a backup
* Observe how Terraform removes resources using state

---

## Step 1: Create the Terraform Configuration

Create a file named **`main.tf`** inside the `terraformlab` directory.

### `main.tf`

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

# Virtual Network A
resource "azurerm_virtual_network" "vnet_a" {
  name                = "vnet-a-westus"
  location            = "westus"
  resource_group_name = "rg-terraform-state"
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet_a" {
  name                 = "subnet-a"
  resource_group_name  = "rg-terraform-state"
  virtual_network_name = azurerm_virtual_network.vnet_a.name
  address_prefixes     = ["10.10.1.0/24"]
}

# Virtual Network B
resource "azurerm_virtual_network" "vnet_b" {
  name                = "vnet-b-westus"
  location            = "westus"
  resource_group_name = "rg-terraform-state"
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "subnet_b" {
  name                 = "subnet-b"
  resource_group_name  = "rg-terraform-state"
  virtual_network_name = azurerm_virtual_network.vnet_b.name
  address_prefixes     = ["10.20.1.0/24"]
}
```

This configuration deploys:

* 2 Virtual Networks
* 2 Subnets

---

## Step 2: Initialize and Apply Terraform

```bash
terraform init
terraform apply
```

Confirm with **yes**.

At this stage:

* Azure resources are created
* `terraform.tfstate` is generated and populated

---

## Terraform Apply & State Creation

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AazlDiCZlFfytmHqEF3reyw.png)

![Image](https://www.easydeploy.io/blog/wp-content/uploads/2022/07/Terraform-State-File-EC2.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AazlDiCZlFfytmHqEF3reyw.png)

---

## Step 3: Inspect the Terraform State File

Open **`terraform.tfstate`** in your editor.

Inside the file, you’ll see:

* Resource logical names (e.g., `subnet_a`)
* Azure resource IDs
* Attributes like CIDR ranges

Example insight:

> Terraform links `subnet_a` in code → actual Azure subnet ID

⚠️ **Important Warning**
Never:

* Edit state manually
* Store state in public GitHub repos

State may contain **sensitive data**.

---

## Step 4: Modify Infrastructure and Observe State Change

Update **`subnet_a`** CIDR:

```hcl
address_prefixes = ["10.10.3.0/24"]
```

Save the file and run:

```bash
terraform apply
```

Terraform will:

* Detect configuration drift
* Update the subnet
* Update the state file automatically

---

## State Update Flow

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/666ca94313bc92617e6eb9fa_AD_4nXe-5_WQu-YNEB3tjjsejMPFliYTzRNjfX5D4sBknnJ9T-25KaQ1UAv3JsxDelee3icN2knxbdR7O6Upx--gqbvpij3hpWqgifxPez8_0ZtHflV45C1BsL3Wzs_tSLjn7WhK9JoiuY6EAd3gAtPfFU3-HaJ-.png)

![Image](https://opengraph.githubassets.com/3520802ea2b65cc288150b5996547b34bde355f60555b0ea292da0cf224d005c/hashicorp/terraform-provider-aws/issues/9042)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AxtIQAr7XF92MRf-HW8tD-Q.jpeg)

---

## Step 5: Simulate State File Loss

Delete the state file:

```bash
rm terraform.tfstate
```

Run:

```bash
terraform plan
```

### What Happens?

Terraform now believes:

> “No resources exist”

It plans to **recreate everything**.

This proves:

> **Terraform state is the source of truth, not Azure**

---

## Terraform Without State (Danger Scenario)

![Image](https://opengraph.githubassets.com/e87c8361489f387af4aeb91e99c9a3dea78e8820a72269c4b4481a4c414d1eff/hashicorp/terraform/issues/19747)

![Image](https://www.tothenew.com/blog/wp-ttn-blog/uploads/2025/05/Safely-Removing-Terraform-Managed-Resources-Without-Deletion-visual-selection-1.png)

![Image](https://iamachs.com/images/posts/azure-terraform/part-4/terraform-state-workflow.jpg)

---

## Step 6: Restore State from Backup

Terraform automatically creates backups.

Restore the state:

```bash
cp terraform.tfstate.backup terraform.tfstate
```

Run:

```bash
terraform plan
```

Now Terraform correctly detects:

* No changes required
* Infrastructure is already in sync

---

## Step 7: Remove a Resource from Configuration

Delete **`subnet_b`** from `main.tf`.

Save and run:

```bash
terraform plan
```

Terraform plans to:

* Destroy `subnet_b`
* Keep other resources unchanged

Apply the change:

```bash
terraform apply
```

`subnet_b` is removed from Azure and state.

---

## Terraform Declarative Model

![Image](https://miro.medium.com/1%2AD-5Fe8CnbToMz1piJMSX_w.png)

![Image](https://media.licdn.com/dms/image/v2/D5612AQFUz2sP2Xg_Lw/article-cover_image-shrink_600_2000/article-cover_image-shrink_600_2000/0/1713889473175?e=2147483647\&t=uaPdUIVqTcUKoLKkbyvPkK8ZYlwWZ5vL3hSxEx3TVNE\&v=beta)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AkZt3QaYaWM5tglNA)

---

## Key Takeaways

* Terraform is **declarative**
* Configuration defines **desired state**
* State tracks **actual state**
* Terraform compares both to decide actions

### Critical Rules

* ❌ Never manually edit state
* ❌ Never store state publicly
* ✅ Use remote state for teams
* ✅ Protect state with access controls

---

## Summary

In this lab, you:

* Deployed Azure resources with Terraform
* Explored the `terraform.tfstate` file
* Observed how state updates on changes
* Simulated state loss and recovery
* Learned how Terraform removes resources using state

Understanding Terraform state is **mandatory** before working with:

* Teams
* CI/CD pipelines
* Production environments

---
