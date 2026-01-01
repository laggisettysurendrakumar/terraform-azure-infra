# Passing Outputs Between Terraform Modules Using Terragrunt in Azure

Large Terraform projects are easier to manage when infrastructure is **split into multiple components**, each with its **own Terraform state**.
Some components (like **resource groups and networks**) rarely change, while others (like **servers**) may be updated frequently.

**Terragrunt** helps solve this by:

* Separating Terraform state per component
* Enforcing deployment order
* Passing outputs between components safely

In this lab, you will deploy an Azure environment using Terragrunt where **outputs from one module are used as inputs in another module**.

---

## 1️⃣ Why Split Terraform State?

![Image](https://cdn.prod.website-files.com/67f9776b8553224cbb897cd7/685b31f5d347ad9d00729598_1_H8G_fsjjRNSahLxrWDXibg.webp)

![Image](https://substackcdn.com/image/fetch/%24s_%217DMP%21%2Cf_auto%2Cq_auto%3Agood%2Cfl_progressive%3Asteep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F66d12ddc-2abe-4a98-82d5-ee177e80487c_1470x1600.png)

![Image](https://terragrunt.gruntwork.io/_vercel/image?q=100\&url=_astro%2Fgraph.COlg21Dx.png\&w=640)

In real projects:

* Resource Groups change rarely
* Networks change occasionally
* Servers change frequently

If everything shares one state file:

* Small changes cause large plans
* Risk of accidental changes increases

With Terragrunt:

* Each component has its **own state**
* Dependencies are explicitly defined
* Changes are safer and faster

---

## 2️⃣ Project Structure Overview

![Image](https://nordcloud.com/wp-content/uploads/2023/11/Screenshot-2023-11-24-at-14.36.36.png)

![Image](https://media.licdn.com/dms/image/v2/D5622AQF6AM_5f4EVjA/feedshare-shrink_800/B56ZcxV1iRHoAg-/0/1748879499652?e=2147483647\&t=PQQbRjk_97drqUjb8HmKrQtSnCrBrqX6DJNwHZpIOzA\&v=beta)

![Image](https://www.nordhero.com/posts/terragrunt-deployment-folders.jpg)

The infrastructure is split into **three components**:

```
terraformlab
├── terragrunt.hcl
├── rg
│   ├── terragrunt.hcl
│   └── main.tf
├── network
│   ├── terragrunt.hcl
│   └── main.tf
└── server
    ├── terragrunt.hcl
    └── main.tf
```

### Component Responsibilities

| Folder    | Purpose                |
| --------- | ---------------------- |
| `rg`      | Create Resource Group  |
| `network` | Create VNet + Subnet   |
| `server`  | Deploy Virtual Machine |

Each folder has:

* Its own Terraform code
* Its own Terraform state

---

## 3️⃣ Root Terragrunt Configuration (DRY Setup)

![Image](https://opengraph.githubassets.com/9f26d0a8f767cef7cc98989019e3b92fc94c619b038b771ac7dd9e7d4357f10e/gruntwork-io/terragrunt/issues/2726)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884250/notes-assets/images/Terragrunt-for-Beginners-Root-Configuration-and-Remote-State/root-configuration-remote-state-steps.jpg)

![Image](https://skundunotes.com/wp-content/uploads/2023/08/80-image-0.png?w=640)

Open the **root** `terragrunt.hcl`:

```hcl
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
EOF
}
```

### What This Does

* Automatically creates `provider.tf` in each child folder
* Ensures consistent provider and backend configuration
* Keeps Terraform code **DRY**

---

## 4️⃣ Resource Group Module (No Dependencies)

![Image](https://azapril.dev/wp-content/uploads/2020/05/tf.png?w=1024)

![Image](https://www.datocms-assets.com/2885/1611186902-output1.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884314/notes-assets/images/Terragrunt-for-Beginners-terragrunt-apply/terragrunt-apply-configuration-diagram.jpg)

The **Resource Group** is the base component.

* No dependencies
* Exposes outputs like:

  * `rg_name`
  * `rg_location`

These outputs will be used by other components.

---

## 5️⃣ Network Module – Using Dependency Outputs

![Image](https://miro.medium.com/1%2A-GrqVDODsVbmQQNQGKG9rg.png)

![Image](https://user-images.githubusercontent.com/49336831/196701513-e4dc185d-ed28-469d-aeb8-49a92f12dfcf.png)

![Image](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00NDY4MjI1LW1vcUlRRg?image-dimensions=750x750\&revision=3)

Open `network/terragrunt.hcl`:

```hcl
dependency "rg" {
  config_path = "../rg"
}

inputs = {
  rg_name     = dependency.rg.outputs.rg_name
  rg_location = dependency.rg.outputs.rg_location
}

include {
  path = find_in_parent_folders()
}
```

### What’s Happening Here?

* `dependency "rg"` declares dependency on Resource Group
* Terragrunt waits until RG is deployed
* Outputs from RG are passed as **inputs** to Network Terraform code

This allows the network to be created **inside the correct RG and location**.

---

## 6️⃣ Server Module – Multiple Dependencies

![Image](https://opengraph.githubassets.com/3f77b19ac4c8633d6ff7d7155f9ebb2f014740a53acd41bf32bdcc20a78cb8c0/gruntwork-io/terragrunt/issues/1571)

![Image](https://blog.jcorioland.io/images/terraform-implicit-explicit-dependencies-between-resources/graph-with-depends-on.jpg)

![Image](https://cdn.prod.website-files.com/67f9776b8553224cbb897cd7/68155051763ce215458fbe0e_acd60324eb29b6ffe946b620c4a6856e1fe8eeab-1100x316.png)

Open `server/terragrunt.hcl`:

```hcl
dependency "rg" {
  config_path = "../rg"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  rg_name     = dependency.rg.outputs.rg_name
  rg_location = dependency.rg.outputs.rg_location
  subnet_id   = dependency.network.outputs.subnet_id
}

include {
  path = find_in_parent_folders()
}
```

### Why Multiple Dependencies?

A Virtual Machine needs:

* Resource Group name
* Location
* Subnet ID

Terragrunt:

* Resolves dependencies in order
* Passes outputs automatically
* Prevents deployment failures

---

## 7️⃣ Modify Server Configuration

![Image](https://azapril.dev/wp-content/uploads/2020/03/variables.png?w=1024)

![Image](https://assets.platform.qa.com/bakery/media/uploads/entity/blobid0-3fa33c92-c727-4de1-a595-26f839dabf7d.png)

![Image](https://www.georgeollis.com/content/images/2023/05/cloud_clare_high_level_image.png)

Open `server/main.tf` and update:

* VM size → `Standard_B1s`
* Image SKU → `2019-datacenter-gensecond`

Save the file before proceeding.

---

## 8️⃣ Authenticate with Azure

![Image](https://www.thomasmaurer.ch/wp-content/uploads/2019/07/Azure-CLI-Windows-Terminal-PowerShell.jpg)

![Image](https://codemag.com/Article/Image/2001021/image1.png)

![Image](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/media/filter-view-subscriptions/subscription-list.png)

Login using Azure CLI:

```bash
az login
```

Complete authentication using the provided credentials.

---

## 9️⃣ Auto-Fill Environment-Specific Values

![Image](https://learn-attachment.microsoft.com/api/attachments/240060-image.png?platform=QnA)

![Image](https://www.xenonstack.com/hubfs/terraform-benefits.png)

![Image](https://www.linuxteck.com/wp-content/uploads/2021/07/sed_syntax2.png)

Run the following commands to replace placeholders:

```bash
find "./terraformlab" -name "*.tf" | xargs sed -i "s/REPLACEME/wait-for-infrastructure-to-provision/g"
find "./terraformlab" -name "*.hcl" | xargs sed -i "s/REPLACEME/wait-for-infrastructure-to-provision/g"
find "./terraformlab" -name "*.hcl" | xargs sed -i "s/STORAGEACCOUNT/wait-for-infrastructure-to-provision/g"
```

This avoids manual edits in multiple files.

---

## 🔟 Deploy Everything with One Command

![Image](https://cdn.prod.website-files.com/63eb9bf7fa9e2724829607c1/6411d50b3d7d7538a2834446_62d3b8f77fcc9c4f0193b146_image6.png)

![Image](https://miro.medium.com/1%2A-GrqVDODsVbmQQNQGKG9rg.png)

![Image](https://www.datocms-assets.com/2885/1647468806-com-terraform-before-and-after.svg)

From the root directory:

```bash
terragrunt run-all apply
```

### What Terragrunt Does Internally

1. Applies **RG** (no dependencies)
2. Reads RG outputs
3. Applies **Network**
4. Reads Subnet output
5. Applies **Server**
6. Generates `provider.tf` automatically
7. Keeps separate state files

All infrastructure is deployed **in the correct order**.

---

## 1️⃣1️⃣ Important Best Practice

![Image](https://kodekloud.com/kk-media/image/upload/v1752884314/notes-assets/images/Terragrunt-for-Beginners-terragrunt-apply/terragrunt-apply-configuration-diagram.jpg)

![Image](https://developer.harness.io/assets/images/provision-infra-dynamically-with-terraform-00-552de2a72e4e3184adf747cb076d6ef7.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884316/notes-assets/images/Terragrunt-for-Beginners-terragrunt-apply/terragrunt-best-practices-review-approval.jpg)

* Use `terragrunt run-all apply` **only for first deployment**
* For later changes:

  * Modify only the required component
  * Run `terragrunt apply` inside that folder

Example:

```bash
cd server
terragrunt apply
```

---

## ✅ Summary

In this lab, you learned how to:

* Split infrastructure into **separate Terraform states**
* Use **Terragrunt dependency blocks**
* Pass outputs between modules safely
* Control deployment order automatically
* Deploy a full Azure environment with one command

This pattern is widely used in **real-world enterprise Terraform + Azure projects**.

---
