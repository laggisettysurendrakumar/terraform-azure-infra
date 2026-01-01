# Importing Existing Azure Resources into Terraform (Hands-on Guide)

Managing resources that were created **outside Terraform** is common in real projects. Terraform allows you to **bring existing Azure infrastructure under its control** using the `terraform import` command.
However, importing must be done **carefully**, because Terraform **does not auto-generate configuration files** — it only updates the **state file**.

In this guide, you’ll import an **existing Azure Virtual Network** into Terraform and align the configuration correctly.

---

## 1️⃣ Understanding the Import Workflow

![Image](https://k21academy.com/wp-content/uploads/2020/11/terraform-import-workflow-diagram-400x152.png)

![Image](https://miro.medium.com/1%2AlmYNNT40GBPaVEL2K4zzNg.png)

![Image](https://media2.dev.to/cdn-cgi/image/width%3D800%2Cheight%3D%2Cfit%3Dscale-down%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fg1ormw9rdlb77vosclve.jpeg)

Before touching commands, understand this **standard workflow**:

1. Existing Azure resource already exists
2. Create an **empty Terraform resource block**
3. Import the Azure resource into Terraform **state**
4. Copy attributes from `terraform show`
5. Clean unsupported arguments
6. Run `terraform plan` to confirm sync

⚠️ **Important Rule**
Terraform import:

* ✅ Updates **state**
* ❌ Does NOT create `.tf` configuration automatically

---

## 2️⃣ Preparing Terraform Configuration

![Image](https://geektechstuff.com/wp-content/uploads/2020/07/geektechstuff_terraform_1st_attempt_1.png)

![Image](https://global.discourse-cdn.com/hashicorp/original/2X/e/e3db5a86d9d96459b882c2107b88f1b263a8e4a2.png)

![Image](https://media2.dev.to/dynamic/image/width%3D800%2Cheight%3D%2Cfit%3Dscale-down%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fym3dz2c5n6oktsxmrxfx.jpeg)

Create a new Terraform file to act as a placeholder.

### Step 1: Create `main.tf`

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

### Step 2: Add an empty resource block

(This is **mandatory** for import mapping)

```hcl
resource "azurerm_virtual_network" "existing_vnet" {
}
```

Terraform now has a **logical address** to map the Azure resource.

---

## 3️⃣ Authenticating with Azure

<img width="1648" height="650" alt="image" src="https://github.com/user-attachments/assets/a2db4644-2cc0-4cf6-9132-b7cc149f48ba" />

<img width="1680" height="1128" alt="image" src="https://github.com/user-attachments/assets/8f657f4e-0a84-485b-8a18-fdbefbb8b02a" />

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2019/12/az-account-list.png?resize=515%2C559\&ssl=1)

Login using Azure CLI:

```bash
az login
```

* Open the provided URL
* Enter the verification code
* Authenticate using lab or Azure credentials

Verify subscription access:

```bash
az account show
```

---

## 4️⃣ Initializing Terraform

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/02/terraform-init-command-terminal-output.png?resize=400%2C242\&ssl=1)

![Image](https://www.opcito.com/sites/default/files/inline-images/TERRAFORM%20CORE.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20230606114940/Terraform-flow-chartr-%282%29.webp)

Navigate to your project directory and initialize:

```bash
cd terraformlab
terraform init
```

This downloads:

* AzureRM provider
* Initializes backend
* Prepares state handling

---

## 5️⃣ Fetching the Azure Resource ID

![Image](https://learn-attachment.microsoft.com/api/attachments/39151-image.png?platform=QnA)

![Image](https://user-images.githubusercontent.com/12371639/236785582-4fa781a5-1789-4510-a4bf-330b863585e9.png)

![Image](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/voice-video-calling/media/call-recording/immutable-resource-id.png)

Terraform import **requires the exact Azure Resource ID**.

Example command (different VNet name):

```bash
VNET_ID=$(az network vnet show \
  --resource-group demo-rg \
  --name demo-vnet \
  --query id \
  --output tsv)

echo $VNET_ID
```

Sample output:

```
/subscriptions/xxxx/resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet
```

---

## 6️⃣ Importing the Virtual Network

![Image](https://jhooq.com/wp-content/uploads/terraform/terraform-import-resource/terraform-import-ec2-instance.webp)

![Image](https://controlmonkey.io/wp-content/uploads/2023/03/image2-1024x475-1.png)

![Image](https://jhooq.com/wp-content/uploads/terraform/terraform-import-resource/terraform-import-aws_s3_bucket.webp)

Now map Azure → Terraform state:

```bash
terraform import azurerm_virtual_network.existing_vnet $VNET_ID
```

What happens:

* Terraform **creates a state file**
* Azure resource attributes are stored
* Configuration is still empty

✅ Import successful ≠ configuration complete

---

## 7️⃣ Inspecting Imported State

![Image](https://www.datocms-assets.com/2885/1611186902-output1.png)

![Image](https://www.easydeploy.io/blog/wp-content/uploads/2022/07/Terraform-State-File-Show-Command.png)

![Image](https://www.easydeploy.io/blog/wp-content/uploads/2022/07/Terraform-State-File-EC2.png)

View imported details:

```bash
terraform show
```

You’ll see a **fully populated resource block** generated from state.

📌 Copy the **entire `azurerm_virtual_network` block** shown in output.

---

## 8️⃣ Syncing Configuration with State

![Image](https://www.patrickkoch.dev/images/post_26/architecture.png)

![Image](https://learn.microsoft.com/en-us/azure/virtual-network/media/quick-create-portal/virtual-network-qs-resources.png)

![Image](https://cloudza.io/_next/static/media/terraform-blog.4df221f7.png)

Paste the copied content into `main.tf`, replacing the empty block.

### ⚠️ Clean Unsupported Arguments

Remove:

* `id`
* `guid`
* `subnet`
* `etag`
* Read-only attributes

### Final Clean Configuration Example

```hcl
resource "azurerm_virtual_network" "existing_vnet" {
  name                = "demo-vnet"
  location            = "East US"
  resource_group_name = "demo-rg"

  address_space = [
    "10.1.0.0/16"
  ]

  dns_servers = []
}
```

This ensures Terraform only manages **configurable attributes**.

---

## 9️⃣ Validating with Terraform Plan

![Image](https://i.sstatic.net/ck6dw.jpg)

![Image](https://i.sstatic.net/GUUwG.png)

![Image](https://spacelift.io/_next/image?q=75\&url=https%3A%2F%2Fspaceliftio.wpcomstaging.com%2Fwp-content%2Fuploads%2F2022%2F09%2Ftf_plan_initial_output_1.png\&w=3840)

Run:

```bash
terraform plan
```

### Expected Result:

```
No changes. Infrastructure is up-to-date.
```

This confirms:

* Configuration
* Terraform state
* Azure resource
  are **perfectly aligned**

---

## 10️⃣ Key Notes & Best Practices

![Image](https://media.licdn.com/dms/image/v2/D5612AQEeSrQ__lcjFw/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1692462504861?e=2147483647\&t=NAQJWWFV9JLZbKYyA_9BMGnQx2N-3nypWMInAJ1W_Fg\&v=beta)

![Image](https://miro.medium.com/1%2A8GmUmBJrXrcNQGx8zGUEFg.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AazlDiCZlFfytmHqEF3reyw.png)

✔ Always test imports in **non-production**
✔ Never blindly trust provider docs for imports
✔ Some resources may still need `terraform apply`
✔ Importing complex environments takes time

🔧 **Automation Option**
For bulk imports, you can explore **Terraformer**, a community tool that auto-generates Terraform configs for existing cloud resources.

---

## ✅ Summary

You successfully learned how to:

* Import an existing Azure Virtual Network
* Understand Terraform state vs configuration
* Clean unsupported attributes
* Validate infrastructure sync using `terraform plan`

Although importing is **manual and slow**, once completed, you gain:

* Version control
* Infrastructure consistency
* Safe future automation

