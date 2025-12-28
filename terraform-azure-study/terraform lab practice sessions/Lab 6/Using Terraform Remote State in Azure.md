# Using Terraform Remote State in Azure

## Introduction

By default, Terraform stores its state locally in a file called **`terraform.tfstate`**.
While this works for individual learning, **local state is risky** in real projects because:

* It is easy to lose or overwrite
* Multiple users cannot safely collaborate
* There is no built-in locking
* Sensitive data may be exposed

To solve this, Terraform supports **remote state backends**.
In Azure, **Azure Blob Storage** is commonly used to store Terraform state securely, centrally, and with **state locking and versioning**.

In this lab, you will configure Terraform to use **Azure Storage Account as a remote backend**.

---

## Why Use Remote State?

![Image](https://skundunotes.com/wp-content/uploads/2021/08/48.image-1-3.png?w=640)

![Image](https://iamachs.com/images/posts/azure-terraform/part-4/terraform-state-workflow.jpg)

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/6735f654f915bc1341994d8a_AD_4nXftAUL8b6yecfxOerrpN38O6qY6LXo33XF8qEVCB5t7AYVXYIlH8VHZSb1rnkBj0ACtzOtX6vuVjV003kG3YSv-IlAN0Oz5P5EVXO86XVSj_O0xKlGIKP9FjkwDyJCTgDGUxPPn.png)

### Benefits of Remote State

* ✅ Centralized state storage
* ✅ Prevents multiple users editing state simultaneously (locking)
* ✅ Supports version history
* ✅ Improves security
* ✅ Required for team-based Terraform usage

---

## Lab Objective

In this lab, you will:

* Create an Azure Storage Account
* Enable blob versioning
* Configure Terraform to use Azure remote state
* Deploy infrastructure using the remote backend
* Verify state storage in Azure Blob Storage

---

## Step 1: Authenticate with Azure

Open a terminal and log in:

```bash
az login
```

Complete authentication in the browser.

---

## Azure CLI Authentication Flow

![Image](https://learn.microsoft.com/en-us/entra/identity-platform/media/v2-oauth2-device-code/v2-oauth-device-flow.svg)

![Image](https://codemag.com/Article/Image/2001021/image1.png)

![Image](https://user-images.githubusercontent.com/14242083/224446793-33930f7f-03b6-4447-8c80-b3b241caba64.png)

---

## Step 2: Create Azure Storage Account and Container

Run the following commands (example values used):

```bash
az storage account create \
  --name satfstatelabs001 \
  --resource-group rg-terraform-remote-state \
  --location westus \
  --sku Standard_LRS \
  --encryption-services blob
```

Create a blob container for Terraform state:

```bash
az storage container create \
  --name tfstate \
  --account-name satfstatelabs001 \
  --auth-mode login
```

### Why This Matters

* Storage Account → Holds the state file
* Blob Container → Organizes Terraform state files
* Azure Blob Storage → Provides **native state locking**

---

## Azure Remote State Architecture

![Image](https://mycloudrevolution.com/2025/01/06/terraform-azurerm-backend/images/azurerm-diagram_hu_9f138f3115d297ac.png)

![Image](https://cdn.hashnode.com/res/hashnode/image/upload/v1648067348971/l2wL9On95.png)

![Image](https://www.torivar.com/blog/wp-content/uploads/2022/06/focus-image.png)

---

## Step 3: Enable Versioning on Storage Account

Enable blob versioning and change tracking:

```bash
az storage account blob-service-properties update \
  --account-name satfstatelabs001 \
  --enable-change-feed true \
  --enable-versioning true
```

### Why Versioning Is Important

* Tracks every change to the state file
* Enables recovery from accidental deletes or corruption
* Provides auditability for infrastructure changes

---

## Terraform State Versioning Flow

![Image](https://i.sstatic.net/LWdef.png)

![Image](https://miro.medium.com/1%2AqU2gWNP4NCPNYzENMbxWRw.png)

![Image](https://miro.medium.com/1%2AlmYNNT40GBPaVEL2K4zzNg.png)

---

## Step 4: Create Terraform Configuration

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

  backend "azurerm" {
    resource_group_name  = "rg-terraform-remote-state"
    storage_account_name = "satfstatelabs001"
    container_name       = "tfstate"
    key                  = "dev/network.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-remote-westus"
  location            = "westus"
  resource_group_name = "rg-terraform-remote-state"
  address_space       = ["10.30.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-remote-westus"
  resource_group_name  = "rg-terraform-remote-state"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.1.0/24"]
}
```

---

## Understanding the Backend Block

![Image](https://www.torivar.com/blog/wp-content/uploads/2022/06/focus-image.png)

![Image](https://api.reliasoftware.com/uploads/terraform_conflicts_56c78b355b.webp)

![Image](https://mycloudrevolution.com/2025/01/06/terraform-azurerm-backend/images/azurerm-diagram_hu_9f138f3115d297ac.png)

### Key Backend Attributes

* `resource_group_name` → Where the storage account exists
* `storage_account_name` → Azure Storage Account
* `container_name` → Blob container
* `key` → Path & filename of the state file

📌 **Best Practice:**
Use structured key names like:

```
env/component/terraform.tfstate
```

---

## Step 5: Initialize Terraform with Remote Backend

Navigate to the lab directory:

```bash
cd terraformlab
```

Initialize Terraform:

```bash
terraform init
```

Terraform will:

* Configure the Azure backend
* Download providers
* Migrate state (if needed)

---

## Terraform Init with Remote Backend

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AjIuhyFOU8oQq6zrVEwRqQw.png)

![Image](https://www.torivar.com/blog/wp-content/uploads/2022/06/focus-image.png)

![Image](https://global.discourse-cdn.com/hashicorp/original/3X/8/e/8e59ca36b4b6a2a5142106c7cdfd305fff3014e1.png)

---

## Step 6: Apply the Configuration

Run:

```bash
terraform apply
```

Confirm with **yes**.

### What Happens During Apply

* Terraform **locks the remote state**
* Writes state to Azure Blob Storage
* Prevents concurrent modifications

---

## Terraform State Locking in Action

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/6735f654f915bc1341994d8a_AD_4nXftAUL8b6yecfxOerrpN38O6qY6LXo33XF8qEVCB5t7AYVXYIlH8VHZSb1rnkBj0ACtzOtX6vuVjV003kG3YSv-IlAN0Oz5P5EVXO86XVSj_O0xKlGIKP9FjkwDyJCTgDGUxPPn.png)

![Image](https://global.discourse-cdn.com/hashicorp/optimized/3X/6/c/6c584988ce68df835d9c42fb27b39b37eb427797_2_1024x275.png)

If another user tries to apply at the same time → **lock error**.

---

## Step 7: Verify State File in Azure

Fetch the storage account key:

```bash
key=$(az storage account keys list \
  -g rg-terraform-remote-state \
  -n satfstatelabs001 \
  --query [0].value -o tsv)
```

List blobs in the container:

```bash
az storage blob list \
  --container-name tfstate \
  --account-name satfstatelabs001 \
  --account-key $key
```

You will see:

```
dev/network.terraform.tfstate
```

✔ This confirms Terraform is using **remote state**.

---

## Remote State Location (Visual)

![Image](https://cdn.hashnode.com/res/hashnode/image/upload/v1648067348971/l2wL9On95.png)

![Image](https://iamachs.com/images/posts/azure-terraform/part-4/terraform-state-workflow.jpg)

---

## Key Takeaways

* Terraform state is **critical**
* Remote state enables:

  * Team collaboration
  * State locking
  * Version history
* Azure Blob Storage is a **production-ready backend**
* Local state should never be used for shared environments

---

## Summary

In this lab, you:

* Created an Azure Storage Account for Terraform state
* Enabled versioning and change tracking
* Configured Terraform to use a **remote Azure backend**
* Deployed infrastructure with state locking
* Verified state storage in Azure Blob Storage

This setup is **mandatory knowledge** for:

* Team-based Terraform
* CI/CD pipelines
* Production infrastructure

---
