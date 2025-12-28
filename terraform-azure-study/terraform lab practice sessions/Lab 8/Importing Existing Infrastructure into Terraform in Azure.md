# Importing Existing Infrastructure into Terraform in Azure

## Introduction

Not all infrastructure starts its life with Terraform. In many real-world Azure environments, resources already exist and must later be brought under Terraform management.

Terraform provides the **`terraform import`** command for this purpose. However, importing infrastructure requires **care and patience** because:

* Terraform **does NOT generate configuration automatically**
* Only the **state file** is updated during import
* The configuration must be **manually aligned** with the existing resource

A typical import workflow looks like this:

1. Create an empty Terraform resource block
2. Import the existing Azure resource into Terraform state
3. Extract the resource attributes from state
4. Update the Terraform configuration
5. Validate with `terraform plan`

In this lab, you will import an **existing Azure Virtual Network** into Terraform.

---

## Terraform Import Workflow

![Image](https://content.hashicorp.com/api/assets?asset=public%2Fimg%2Fterraform%2Fterraform-workflow-diagram.png\&product=tutorials\&version=main)

![Image](https://global.discourse-cdn.com/hashicorp/optimized/2X/6/6d8450b0763d1df5e8784bcd71b16430e66340a3_2_690x494.png)

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/11/Terraform_import_existing_infrastructure_Featured_Image.jpg)

---

## Lab Objective

In this lab, you will:

* Create a placeholder Terraform configuration
* Import an existing Azure Virtual Network
* Inspect Terraform state
* Update Terraform configuration to match Azure
* Validate synchronization between Azure and Terraform

---

## Step 1: Create Terraform Configuration File

Inside the `terraformlab` directory, create a file named **`main.tf`**.

### Initial `main.tf`

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

# Placeholder for existing Virtual Network
resource "azurerm_virtual_network" "existing_vnet" {
}
```

### Why Is This Empty?

Terraform requires a **matching resource block** to map the Azure resource ID into state.
This block will be populated later.

---

## Step 2: Authenticate with Azure

Open a terminal and log in:

```bash
az login
```

Complete browser-based authentication.

---

## Azure CLI Login Flow

![Image](https://learn.microsoft.com/en-us/entra/identity-platform/media/v2-oauth2-device-code/v2-oauth-device-flow.svg)

<img width="1680" height="1128" alt="image" src="https://github.com/user-attachments/assets/01a0520c-36ee-4716-952c-9ec17bec2e77" />

![Image](https://www.varonis.com/hubfs/Imported_Blog_Media/az-cli-login-browser.png?hsLang=en)

---

## Step 3: Initialize Terraform

Navigate to the working directory and initialize Terraform:

```bash
cd terraformlab
terraform init
```

This downloads the Azure provider and prepares Terraform to work with state.

---

## Step 4: Retrieve the Azure Resource ID

Terraform imports resources using **Azure Resource IDs**.

Fetch the Virtual Network ID (example):

```bash
VNET_ID=$(az network vnet show \
  --resource-group rg-existing-infra \
  --name prod-vnet \
  --query id \
  --output tsv)

echo $VNET_ID
```

You should see a long Azure resource ID similar to:

```
/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/prod-vnet
```

---

## Azure Resource ID Concept

![Image](https://learn.microsoft.com/en-us/entra/architecture/media/secure-resource-management/resource-model.png)

![Image](https://learn-attachment.microsoft.com/api/attachments/39019-image.png?platform=QnA)

![Image](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/voice-video-calling/media/call-recording/immutable-resource-id.png)

---

## Step 5: Import the Existing Virtual Network

Run the import command:

```bash
terraform import azurerm_virtual_network.existing_vnet $VNET_ID
```

### What Happens During Import

* Terraform maps the Azure resource to the Terraform resource block
* A **state file is created**
* No infrastructure changes occur

---

## Terraform Import in Action

![Image](https://jhooq.com/wp-content/uploads/terraform/terraform-import-resource/terraform-aws_s3_bucket_acl.webp)

![Image](https://jeffbrown.tech/wp-content/uploads/2021/06/plan-output-new-subnet-1024x428.png)

![Image](https://controlmonkey.io/wp-content/uploads/2023/03/image2-1024x475-1.png)

---

## Step 6: Inspect Imported State

Run:

```bash
terraform show
```

This displays:

* All attributes pulled from Azure
* A Terraform-compatible resource representation

Copy the **Virtual Network resource block output**.

---

## Terraform State Inspection

![Image](https://k21academy.com/wp-content/uploads/2021/01/terraform-cli-help.png)

![Image](https://iamachs.com/images/posts/azure-terraform/part-4/terraform-state-workflow.jpg)

![Image](https://www.datocms-assets.com/2885/1611186902-output1.png)

---

## Step 7: Update the Terraform Configuration

Replace the empty resource block in `main.tf` with the copied content.

Then **remove non-configurable attributes**, such as:

* IDs
* ETags
* Read-only metadata

### Cleaned `main.tf`

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

resource "azurerm_virtual_network" "existing_vnet" {
  name                = "prod-vnet"
  location            = "South Central US"
  resource_group_name = "rg-existing-infra"
  address_space       = ["10.0.0.0/20"]
  dns_servers         = []
}
```

---

## Why Cleanup Is Required

![Image](https://controlmonkey.io/wp-content/uploads/2023/03/image15-1024x623-1.png)

![Image](https://cloudfoundation.com/blog/wp-content/uploads/2025/06/Terraform-Attributes-And-Outputs.png)

![Image](https://controlmonkey.io/wp-content/uploads/2023/03/image6-1024x563-1.png)

Terraform can only manage **configurable attributes**.
Leaving read-only fields will cause plan/apply errors.

---

## Step 8: Validate Configuration

Run:

```bash
terraform plan
```

### Expected Result

* Terraform reports **no changes**
* Configuration and Azure resource are in sync

If Terraform shows changes:

* Review configuration
* Adjust values carefully

---

## Terraform Sync Validation

![Image](https://i.sstatic.net/ck6dw.jpg)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2A6fQaqUHPvb68_60W)

![Image](https://content.hashicorp.com/api/assets?asset=public%2Fimg%2Fterraform%2Fterraform-workflow-diagram.png\&product=tutorials\&version=main)

---

## Important Notes & Best Practices

* ❌ Importing does **not** create Terraform code
* ❌ Never import production resources blindly
* ✅ Always test imports in non-prod first
* ✅ Validate with `terraform plan`
* ✅ Backup state before importing

For large environments, consider automation tools like:

* Terraformer (community-driven)

---

## Summary

In this lab, you:

* Imported an existing Azure Virtual Network into Terraform
* Learned the Terraform import workflow
* Manually aligned Terraform configuration with Azure
* Validated synchronization using Terraform plan
* Understood risks and best practices for importing infrastructure

Importing existing infrastructure is **slow but powerful**.
Once completed correctly, it enables **full lifecycle management** using Terraform.

---
