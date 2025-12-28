# Creating Terraform Configurations with **Implicit Dependencies** in Azure

## Introduction

When you run Terraform, it doesn’t randomly create resources. Terraform builds a **dependency graph** to decide **which resource should be created first and which should wait**.

Terraform understands this order in two main ways:

* **Implicit dependencies** (recommended)
* Explicit dependencies (`depends_on` – covered later)

In this lab, you’ll learn how **implicit dependencies work**, why missing them causes failures, and how Terraform automatically fixes the order once resources reference each other correctly.

---

## What Are Implicit Dependencies?

An **implicit dependency** is created automatically when one resource **uses an attribute of another resource**.

Example:

* A **Subnet** must be created *inside* a **Virtual Network**
* If the subnet configuration **references the VNet**, Terraform knows the VNet must exist first

If you don’t reference it, Terraform assumes both can be created **at the same time**, which can break deployments.

---

## Lab Scenario Overview

You will create:

* An **Azure Virtual Network**
* An **Azure Subnet**

First, you’ll **intentionally avoid dependencies** to see the failure.
Then, you’ll **fix the configuration** using an implicit dependency.

---

## Step 1: Create the Terraform Configuration

Create a new file called **`main.tf`** inside your working directory.

### Initial Configuration (No Dependency)

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

resource "azurerm_virtual_network" "demo_vnet" {
  name                = "vnet-demo-eastus"
  address_space       = ["10.10.0.0/16"]
  location            = "eastus"
  resource_group_name = "rg-demo-001"
}

resource "azurerm_subnet" "demo_subnet" {
  name                 = "subnet-demo-eastus"
  resource_group_name  = "rg-demo-001"
  virtual_network_name = "vnet-demo-eastus"
  address_prefixes     = ["10.10.1.0/24"]
}
```

At first glance, this looks correct — but **Terraform does not know** that the subnet depends on the VNet.

---

## Step 2: Initialize and Apply Terraform

Run the following commands:

```bash
terraform init
terraform apply
```

You will notice an **error during deployment**.

### Why This Fails

Terraform attempts to:

* Create the **Virtual Network**
* Create the **Subnet**
  ➡ **At the same time**

Azure rejects the subnet creation because the Virtual Network **is not fully available yet**.

---

## Visualizing the Problem with `terraform graph`

Run:

```bash
terraform graph
```

Paste the output into **WebGraphViz** to generate a diagram.

### What You’ll Observe

* The subnet and VNet are **parallel**
* No arrow showing dependency

## Visualization – No Dependency

![Image](https://raw.githubusercontent.com/musukvl/article-terraform-graph/master/001-local-for-name/graph.png)

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D420%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fl2535y1lh9lor9dyegrr.png)

![Image](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00NDY4MjI1LW1vcUlRRg?revision=3)

This confirms Terraform has **no idea** that one resource relies on the other.

---

## Step 3: Fixing the Issue with an Implicit Dependency

Now update the subnet configuration to **reference the Virtual Network directly**.

### Updated Subnet Configuration

```hcl
resource "azurerm_subnet" "demo_subnet" {
  name                 = "subnet-demo-eastus"
  resource_group_name  = "rg-demo-001"
  virtual_network_name = azurerm_virtual_network.demo_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
```

### What Changed?

* Instead of a **hardcoded string**
* We used:

  ```hcl
  azurerm_virtual_network.demo_vnet.name
  ```

This single line creates an **implicit dependency**.

---

## Why This Works

Terraform now understands:

> “The subnet needs the VNet’s name, so the VNet must be created first.”

No extra instructions required.

---

## Step 4: Apply Terraform Again

Run:

```bash
terraform apply
```

This time:

* Virtual Network is created first
* Subnet waits
* Deployment succeeds ✅

---

## Visualizing the Fixed Dependency

Run again:

```bash
terraform graph
```

Paste into WebGraphViz.

### What You’ll See Now

* An arrow from **Subnet → Virtual Network**
* Clear creation order

## Visualization – With Implicit Dependency

![Image](https://blog.jcorioland.io/images/terraform-implicit-explicit-dependencies-between-resources/graph-with-depends-on.jpg)

![Image](https://miro.medium.com/1%2AVMs5_1keJsBgdfRiIC_PTA.png)

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D420%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fl2535y1lh9lor9dyegrr.png)

This confirms Terraform has built a **correct dependency graph**.

---

## Key Takeaways

### ✅ Implicit Dependencies

* Created by **referencing attributes** from other resources
* Preferred over `depends_on`
* Cleaner and safer

### ❌ Missing Dependencies

* Terraform may create resources **out of order**
* Leads to runtime errors
* Harder to troubleshoot without `terraform graph`

### 🧠 Best Practices

* Always reference:

  * VNet names
  * IDs
  * Resource attributes
* Use `terraform graph` to debug timing issues

---

## Summary

In this lab, you:

* Created Azure resources **without dependencies**
* Observed deployment failure
* Used `terraform graph` to visualize the issue
* Fixed the configuration using an **implicit dependency**
* Verified correct execution order visually

Understanding dependencies is **fundamental** to writing reliable, production-ready Terraform code — especially in Azure environments.

---
