# Using Provisioners with Terraform in Azure

## Introduction

Terraform is primarily designed to **create, update, and delete infrastructure**. However, there are situations where you may need to perform **extra actions** that are not directly supported by Terraform resources—such as running scripts, importing images, or executing CLI commands.

This is where **Provisioners** come in.

Provisioners allow Terraform to:

* Run commands on the **local machine**
* Or execute commands on **remote resources**

⚠️ **Important:**
Provisioners increase complexity and introduce external dependencies.
They should be used **only when no better alternative exists** (such as CI/CD pipelines or native Terraform resources).

In this lab, you’ll learn how to use **`local-exec` provisioners** with Azure Container Registry (ACR).

---

## What Is a Terraform Provisioner?

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/11/hashicorp-terraform-workflow-learn-build5nines.jpg?amp%3Bssl=1\&fit=1200%2C675)

![Image](https://spaceliftio.wpcomstaging.com/wp-content/uploads/2022/08/terraform-provisioners-diagram.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1167/1%2Awkuo63Xa38F9Xofj03GSJg.png)

A provisioner:

* Runs **after** a resource is created (default)
* Or **during destroy**
* Executes shell commands, scripts, or tools

Common provisioner types:

* `local-exec` → runs on the system executing Terraform
* `remote-exec` → runs on the target resource (VM)

---

## Lab Objective

In this lab, you will:

* Create an Azure Container Registry (ACR)
* Use a **null resource + provisioner** to import a container image
* Add a **destroy provisioner** for cleanup
* Understand why provisioners are considered a last resort

---

## Step 1: Create the Terraform Configuration File

Create a file named **`main.tf`** inside the `terraformlab` directory.

---

## Step 2: Configure Terraform and Azure Provider

Add the Terraform and provider blocks:

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
---

## Terraform Initialization Flow

![Image](https://opengraph.githubassets.com/bf86e55c6fe7527df76411a6e8ffe8b40ec8c9a4dfe438b4bb36dff4a64da15d/hashicorp/terraform/issues/16815)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20230606114940/Terraform-flow-chartr-%282%29.webp)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AcJ166cSFeSAT6CiVAm0iAQ.png)

---

## Step 3: Create an Azure Container Registry

Now define an Azure Container Registry resource:

```hcl
resource "azurerm_container_registry" "acr" {
  name                = "xyzacrregistry001"
  resource_group_name = "rg-xyz-labs"
  location            = "East US"
  sku                 = "Standard"
  admin_enabled       = false
}
```

This resource creates a **private container registry** in Azure.

---

## Azure Container Registry Overview

![Image](https://learn.microsoft.com/en-us/azure/container-registry/media/container-registry-concepts/registry-elements.png)

![Image](https://learn.microsoft.com/en-us/azure/container-registry/media/tasks-consume-public-content/consuming-public-content-workflow.png)

![Image](https://azure.microsoft.com/en-us/blog/wp-content/uploads/2020/06/ecfc63bf-21d1-493f-9f76-e1f895dc90a9.webp)

---

## Step 4: Use a Provisioner with a Null Resource

Terraform does not have a native resource to **import images into ACR**.
To handle this, we use a **`null_resource`** with a **`local-exec` provisioner**.

```hcl
resource "null_resource" "import_image" {

  provisioner "local-exec" {
    command = <<EOT
      az acr import \
        --name ${azurerm_container_registry.acr.name} \
        --source mcr.microsoft.com/hello-world \
        --image hello-world:xyzlab
    EOT
  }
}
```

### What’s Happening Here?

* `null_resource` → no infrastructure, only logic
* `local-exec` → runs on the machine executing Terraform
* Uses **Azure CLI**
* Imports a public Docker image into ACR

---

## Implicit Dependency with Provisioners

![Image](https://earthly.dev/blog/assets/images/terraform-depends-on-argument/v4qpBrx.png)

![Image](https://static.wixstatic.com/media/12b015_64d680271062402c8f2178ff6b79d61b~mv2.png/v1/fill/w_865%2Ch_336%2Cal_c%2Cq_85%2Cenc_avif%2Cquality_auto/12b015_64d680271062402c8f2178ff6b79d61b~mv2.png)

![Image](https://user-images.githubusercontent.com/20180/34902152-9400045c-f7ca-11e7-855d-468396834f5a.png)

The reference below creates an **implicit dependency**:

```hcl
${azurerm_container_registry.acr.name}
```

Terraform understands:

```
Create ACR → Run provisioner
```

---

## ⚠️ Why Provisioners Are Risky

Provisioners depend on:

* External tools (Azure CLI)
* Network availability
* Local machine configuration

If Azure CLI is missing, the deployment fails.

This is why:

> **Provisioners should be avoided when possible**

---

## Step 5: Add a Destroy-Time Provisioner

You can also run provisioners **during resource deletion**.

Add this inside the ACR resource:

```hcl
provisioner "local-exec" {
  when    = destroy
  command = <<EOT
    az acr repository delete \
      --name ${self.name} \
      --image hello-world:xyzlab \
      --yes
  EOT
}
```

### Key Concepts

* `when = destroy` → runs only during `terraform destroy`
* `self.name` → references the current resource
* Performs cleanup before resource removal

---

## Destroy Provisioner Flow

![Image](https://opengraph.githubassets.com/9a1aa1111a96aad15d94775450c35fa21bdc176eedf2224fae45421e5cbf2764/johndturn/terraform-destroy-provisioner-example)

![Image](https://media.licdn.com/dms/image/v2/D5612AQGZEHpV9PX7hQ/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1698736792501?e=2147483647\&t=Qvwe46K8ta5QBq2B8DFnWRMdUguCN-ta_MRdO6WCspA\&v=beta)

---

## Step 6: Final `main.tf` (Complete File)

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

resource "azurerm_container_registry" "acr" {
  name                = "xyzacrregistry001"
  resource_group_name = "rg-xyz-labs"
  location            = "East US"
  sku                 = "Standard"
  admin_enabled       = false

  provisioner "local-exec" {
    when = destroy
    command = <<EOT
      az acr repository delete \
        --name ${self.name} \
        --image hello-world:xyzlab \
        --yes
    EOT
  }
}

resource "null_resource" "import_image" {

  provisioner "local-exec" {
    command = <<EOT
      az acr import \
        --name ${azurerm_container_registry.acr.name} \
        --source mcr.microsoft.com/hello-world \
        --image hello-world:xyzlab
    EOT
  }
}
```

---

## Step 7: Deploy and Destroy

Run the following:

```bash
terraform init
terraform apply
```

Then clean up:

```bash
terraform destroy
```

You will observe:

* Image import after ACR creation
* Image cleanup before ACR deletion

---

## Best Practices: When NOT to Use Provisioners

![Image](https://d2908q01vomqb2.cloudfront.net/22d200f8670dbdb3e253a90eee5098477c95c23d/2019/11/19/DevSecOps-Figure1.png)

![Image](https://skundunotes.com/wp-content/uploads/2021/02/33.-az-plines-tf-s3-image0-3.png)

![Image](https://www.veritis.com/wp-content/uploads/2019/03/cloud-vs-on-premise-deployment-1.jpg)

Avoid provisioners when:

* CI/CD pipelines can handle the task
* Native Terraform resources exist
* Configuration must be portable across environments

Better alternatives:

* Azure DevOps
* GitHub Actions
* Jenkins pipelines

---

## Summary

In this lab, you:

* Used **local-exec provisioners** in Terraform
* Imported a Docker image into Azure Container Registry
* Created a **destroy-time provisioner**
* Learned how implicit dependencies work with provisioners
* Understood why provisioners should be used cautiously

Provisioners can be powerful, but **production-grade Terraform code should minimize their use**.

---
