# Terraform Challenge: Deploying a Virtual Machine in Azure

## 🎯 Challenge Overview

You are working as a **Cloud Engineer** in an enterprise organization. A development team has requested a **Virtual Machine environment**, and your company follows a strict policy:

> **“All infrastructure must be defined and deployed using Terraform.”**

Your task is to design and deploy an **Azure Virtual Machine** using Terraform, following these constraints:

* Infrastructure must be **fully defined in code**
* Terraform must use a **remote state backend**
* Configuration must support **re-deployment via variables**
* Deployment region must be **West US**
* Only **Standard_B1s** VM size is allowed

A Terraform development environment has already been provided for you to complete this challenge.

---

## 🧠 What You Will Build

![Image](https://learn.microsoft.com/en-us/azure/architecture/guide/hpc/media/ansys-rocky/architecture.png)

![Image](https://www.azure365pro.com/wp-content/uploads/2024/07/image.png)

![Image](https://iamachs.com/images/posts/azure-terraform/part-4/terraform-state-workflow.jpg)

By the end of this challenge, you will have:

* A Terraform configuration (`main.tf`)
* Azure authentication via CLI
* A VM deployed into an **existing lab resource group**
* A setup that can be reused for **test environments**

This challenge simulates a **real enterprise request**, not just a basic lab exercise.

---

## 📋 Challenge Requirements

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2017/09/AzurePortal_VM_B-Series_Preview_Screenshot.png?fit=1132%2C1390\&ssl=1)

![Image](https://holori.com/wp-content/uploads/2024/06/azure-regions-map.png)

![Image](https://controlmonkey.io/wp-content/uploads/2025/08/SEO-How-to-Use-Terraform-Variables-LQ-1024x478-1.png)

Make sure your solution follows these rules:

| Requirement      | Constraint                           |
| ---------------- | ------------------------------------ |
| Cloud Provider   | Azure                                |
| Region           | West US                              |
| VM Size          | Standard_B1s only                    |
| State Management | Azure Storage Account (Remote State) |
| Configuration    | Terraform variables                  |
| Deployment Style | Infrastructure as Code only          |

---

## 🗂️ Project Setup

![Image](https://media.beehiiv.com/cdn-cgi/image/fit%3Dscale-down%2Cformat%3Dauto%2Conerror%3Dredirect%2Cquality%3D80/uploads/asset/file/a70941e1-5fb2-4a29-a70b-a671150e9298/directory_2.png?t=1730702773)

![Image](https://geektechstuff.com/wp-content/uploads/2020/07/geektechstuff_terraform_1st_attempt_1.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2ABaZXspSwzodUAWyc.jpg)

You will work inside the provided **terraformlab** directory.

### Step 1: Create Terraform Configuration File

1. Right-click on the **terraformlab** folder
2. Select **New File**
3. Name the file:

```text
main.tf
```

This file will contain all required Terraform configuration.

---

## ⚙️ Terraform Provider Configuration

![Image](https://i.sstatic.net/VyBGf.png)

![Image](https://k21academy.com/wp-content/uploads/2020/08/terraform-providers.png)

![Image](https://global.discourse-cdn.com/hashicorp/original/2X/9/928c4cb3d68de8255b0a24104ddc4a30d339a3e4.png)

Add the following Terraform boilerplate to `main.tf`:

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
```

This ensures:

* Terraform uses the AzureRM provider
* Provider version remains consistent

---

## 🧩 Using the Existing Lab Resource Group

![Image](https://butfirstcoffee.me/media/posts/20/code2.png)

![Image](https://k21academy.com/wp-content/uploads/2023/12/Data-Source1-1024x523.webp)

![Image](https://www.datocms-assets.com/2885/1617837549-tfdatasource2.png)

Instead of creating a new Resource Group, your lab already provides one.

Add this **data source** to `main.tf`:

```hcl
data "azurerm_resource_group" "lab_rg" {
  name = "wait-for-infrastructure-to-provision"
}
```

### Why Use a Data Source?

* Prevents accidental resource group creation
* Aligns with enterprise governance
* Uses lab-provided infrastructure safely

---

## 🔐 Authenticate with Azure

![Image](https://i.sstatic.net/HmE1W.png)

![Image](https://codemag.com/Article/Image/2001021/image1.png)

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2019/12/az-account-list.png?resize=515%2C559\&ssl=1)

Before deploying any infrastructure, authenticate to Azure.

### Step-by-step:

```bash
az login
```

1. Copy the authentication code
2. Open the browser link
3. Log in using the provided lab credentials
4. Confirm access to the correct subscription

Once authenticated, Terraform can deploy Azure resources.

---

## 🏗️ Next Steps (Validation Phase)

![Image](https://media2.dev.to/cdn-cgi/image/width%3D800%2Cheight%3D%2Cfit%3Dscale-down%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fg1ormw9rdlb77vosclve.jpeg)

![Image](https://learn.microsoft.com/en-us/azure/developer/terraform/media/best-practices-integration-testing/azure-devops-green-pipeline.png)

![Image](https://miro.medium.com/1%2ARALo5dIC65kt6cWhamCcKg.png)

After completing the setup:

* You will add:

  * Virtual Network
  * Subnet
  * Network Interface
  * Virtual Machine
* Use **variables** for environment flexibility
* Configure **remote state** using Azure Storage
* Deploy using `terraform init` and `terraform apply`

These steps are validated automatically when you proceed to the **Validation Steps**.

---

## ✅ What This Challenge Teaches You

![Image](https://www.cloudbolt.io/wp-content/uploads/terraform-best-practicies-1024x654-1.png)

![Image](https://lanet.co.uk/wp-content/uploads/2021/01/1-IaC.png)

![Image](https://spacelift.io/_next/image?q=75\&url=https%3A%2F%2Fspaceliftio.wpcomstaging.com%2Fwp-content%2Fuploads%2F2023%2F03%2Fterraform-architecture-diagram.png\&w=1920)

By completing this challenge, you demonstrate:

* Real-world Terraform usage
* Azure VM deployment knowledge
* Understanding of enterprise constraints
* Remote state management
* Reusable infrastructure design

This mirrors how **production-grade cloud infrastructure** is requested and delivered in real companies.

---

## 🧾 Summary

In this challenge, you:

* Prepared a Terraform configuration from scratch
* Authenticated securely with Azure
* Used an existing Resource Group via data sources
* Followed strict region and VM size constraints
* Built a reusable, test-friendly Terraform setup

Once validation is complete, your solution confirms that you can deploy **Azure Virtual Machines using Terraform the enterprise way**.
