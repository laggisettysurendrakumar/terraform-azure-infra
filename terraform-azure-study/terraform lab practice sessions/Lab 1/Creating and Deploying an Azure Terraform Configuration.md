# Creating and Deploying an Azure Terraform Configuration

## Introduction

Terraform allows you to define, deploy, and manage cloud infrastructure using **configuration files with a `.tf` extension**. 
These files are written in **HCL (HashiCorp Configuration Language)**, which is designed to be:

* Easy for humans to read and understand
* Easy for machines to parse and execute
* Clear enough to act as **living documentation**

Terraform configurations are built using **blocks**, which are conceptually similar to JSON objects.

### General Terraform Block Structure

```hcl
<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  <ARGUMENT> = <VALUE>
}
```

* **Block type** → What kind of object this is (terraform, provider, resource)
* **First label** → Resource type or category
* **Second label** → Logical name used internally by Terraform
* **Arguments** → Key–value pairs defining configuration

---

## Lab Objective

In this practice lab, you will:

* Create a Terraform configuration file
* Configure the Azure provider
* Deploy a **Virtual Network (VNet)** to Azure
* Preview changes using `terraform plan`
* Deploy using `terraform apply`
* Clean up resources using `terraform destroy`

---

## Step 1: Create the Terraform Configuration File

Create a new file named **`main.tf`** inside the `terraformlab` directory.

> Naming the primary file `main.tf` is a common Terraform convention.
> Terraform automatically loads **all `.tf` files** in a directory.

---

## Step 2: Configure Terraform and the Provider

Add the following **Terraform settings block** to `main.tf`:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}
```

### Why This Block Matters

* Defines **which provider** Terraform should use
* Pins the **provider version** to avoid breaking changes
* Ensures consistent behavior across environments

> Cloud providers update frequently.
> Locking provider versions prevents unexpected failures.

---

## Terraform Provider Configuration

Now add the Azure provider block:

```hcl
provider "azurerm" {
  features {}
}
```

### Explanation

* Tells Terraform **how to communicate with Azure**
* Uses **Azure CLI authentication**
* The `features {}` block is required even if empty

---

## Provider Authentication Flow (Visual)

![Image](https://learn.microsoft.com/en-us/samples/azure-samples/alz-terraform-sub-vending-demo-with-terraform-cloud-and-github/alz-terraform-sub-vending/media/overview.png)

![Image](https://stacksimplify.com/course-images/azure-terraform-workflow-2.png)

![Image](https://www.azurecitadel.com/terraform/fundamentals/images/provider.tf.png)

---

## Step 3: Define an Azure Virtual Network Resource

Now define a **Virtual Network** using a different example than the original content:

```hcl
resource "azurerm_virtual_network" "training_vnet" {
  name                = "xyz-vnet-eastus"
  location            = "East US"
  resource_group_name = "rg-xyz-training"
  address_space       = ["10.20.0.0/16"]
}
```

### Resource Block Breakdown

* **resource** → Declares a managed infrastructure object
* **azurerm_virtual_network** → Resource type
* **training_vnet** → Logical name used internally
* **arguments** → Define VNet properties

---

## Azure Virtual Network Concept (Visual)

![Image](https://learn.microsoft.com/en-us/azure/well-architected/service-guides/_images/v-net.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AmPd4WZM70Wg2n2SR_-Z65g.png)

![Image](https://azure-training.com/wp-content/uploads/2019/01/vnetoverview.png)

---

## Step 4: Review the Complete `main.tf` File

Your full Terraform configuration should now look like this:

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

resource "azurerm_virtual_network" "training_vnet" {
  name                = "xyz-vnet-eastus"
  location            = "East US"
  resource_group_name = "rg-xyz-training"
  address_space       = ["10.20.0.0/16"]
}
```

This configuration is now **ready for deployment**.

---

## Step 5: Authenticate with Azure

Open a terminal and run:

```bash
az login
```

* Follow the browser-based authentication
* Sign in using the provided lab credentials
* Confirm access to the correct subscription

---

## Azure CLI Login Flow (Visual)

![Image](https://jeffreyappel.nl/wp-content/uploads/2025/02/image-8-1024x534.png)

![Image](https://miro.medium.com/1%2Axnfd8qx7SGIfz7lsSimQRQ.png)

![Image](https://i.sstatic.net/HmE1W.png)

---

## Step 6: Initialize Terraform

Navigate to the lab directory:

```bash
cd terraformlab
```

Initialize Terraform:

```bash
terraform init
```

### What Happens During `terraform init`

* Downloads the Azure provider
* Prepares the working directory
* Creates `.terraform` metadata

---

## Terraform Initialization Flow (Visual)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AXpTIu-NgHP0TQykU.png)

![Image](https://cms.cloudoptimo.com/uploads/terraform_eaa800441c.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2ALTAX33WfPvJmIvl8SxbCzw.png)

---

## Step 7: Preview Changes with `terraform plan`

Run:

```bash
terraform plan
```

### Purpose of `terraform plan`

* Shows what Terraform **will create**
* Makes **no actual changes**
* Helps prevent accidental deployments

---

## Terraform Plan Output (Visual)

![Image](https://spaceliftio.wpcomstaging.com/wp-content/uploads/2022/09/tf_plan_initial_output_1.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20230606114940/Terraform-flow-chartr-%282%29.webp)

![Image](https://developer.harness.io/assets/images/run-a-terraform-plan-with-the-terraform-plan-step-09-033e186ab921bccc4d23a279edf84d42.png)

---

## Step 8: Deploy the Infrastructure

Apply the configuration:

```bash
terraform apply
```

Type **`yes`** when prompted.

Terraform now:

* Creates the Virtual Network
* Displays a deployment summary

---

## Terraform Apply Flow (Visual)

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/11/hashicorp-terraform-workflow-learn-build5nines.jpg?amp%3Bssl=1\&fit=1200%2C675)

![Image](https://brendanthompson.com/content/images/posts/2021/11/my-terraform-development-workflow/terraform-development-workflow.png)

![Image](https://k21academy.com/wp-content/uploads/2020/12/terraformm-apply.jpg)

---

## Step 9: Destroy the Infrastructure

To clean up resources:

```bash
terraform destroy
```

Confirm with **`yes`**.

Terraform safely removes:

* The Virtual Network
* All managed resources in the configuration

---

## Terraform Destroy Flow (Visual)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2Ael-spbCECAOdp06Iiun-ug.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20230606114940/Terraform-flow-chartr-%282%29.webp)

![Image](https://i.sstatic.net/yxp0N.png)

---

## Summary

In this lab, you successfully:

* Created a Terraform configuration using HCL
* Configured the Azure provider with version pinning
* Deployed an Azure Virtual Network
* Used `terraform plan` to preview changes
* Applied infrastructure using `terraform apply`
* Removed resources safely using `terraform destroy`

This lab forms the **foundation for all advanced Terraform concepts**, including:

* Dependencies
* State management
* Modules
* CI/CD pipelines

---
