# Keeping Terraform Remote State DRY Using Terragrunt in Azure

When working with multiple environments like **dev, qa, and prod**, managing Terraform remote state can quickly become repetitive.
**Terragrunt** solves this problem by acting as a **thin wrapper over Terraform**, allowing you to define common configurations (like remote state) **once** and reuse them everywhere.

This guide walks you step by step through using **Terragrunt to manage Azure remote state** while keeping your configuration **DRY (Don’t Repeat Yourself)**.

---

## 1️⃣ What Problem Does Terragrunt Solve?

![Image](https://skundunotes.com/wp-content/uploads/2023/08/80-image-0.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884289/notes-assets/images/Terragrunt-for-Beginners-The-DRY-Principle/dry-principle-configuration-inheritance-reuse.jpg)

![Image](https://nordcloud.com/wp-content/uploads/2023/11/Screenshot-2023-11-24-at-14.36.36.png)

Without Terragrunt:

* Every environment repeats the same backend configuration
* State configuration becomes hard to maintain
* Small changes require edits in many places

With Terragrunt:

* Remote state is defined **once**
* Environments inherit configuration automatically
* Infrastructure is easier to scale and manage

👉 Terragrunt **does not replace Terraform** — it enhances it.

---

## 2️⃣ Folder Structure for Multi-Environment Setup

![Image](https://user-images.githubusercontent.com/3172378/120503644-7a08bf80-c391-11eb-85e4-23cb974034d6.png)

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D420%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fceg39lx4%2Fproduction%2Feb45102837a5971f94fed46026121081187f08e2-2000x818.png)

We’ll deploy the **same Terraform code** into multiple environments using Terragrunt.

### Example Folder Layout

```
terraformlab
├── terragrunt.hcl
├── dev
│   ├── terragrunt.hcl
│   └── main.tf
├── qa
│   ├── terragrunt.hcl
│   └── main.tf
└── prod
    ├── terragrunt.hcl
    └── main.tf
```

✔ One root configuration
✔ Multiple environments
✔ Zero duplication of backend config

---

## 3️⃣ Authenticate with Azure

![Image](https://codemag.com/Article/Image/2001021/image6.png)

![Image](https://codemag.com/Article/Image/2001021/image1.png)

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2019/12/az-account-list.png?resize=515%2C559\&ssl=1)

Before using Terraform or Terragrunt, authenticate with Azure:

```bash
az login
```

* Open the browser link
* Enter the provided code
* Sign in using lab credentials
* Confirm access to the subscription

You should see your Azure subscriptions listed in the terminal.

---

## 4️⃣ Root Terragrunt Configuration (Remote State)

![Image](https://miro.medium.com/1%2AUvrw3u7dEMDx_2s_A3cFhA.jpeg)

![Image](https://mycloudrevolution.com/2025/01/06/terraform-azurerm-backend/images/azurerm-diagram_hu_9f138f3115d297ac.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884250/notes-assets/images/Terragrunt-for-Beginners-Root-Configuration-and-Remote-State/root-configuration-remote-state-steps.jpg)

Open the **root-level** `terragrunt.hcl` file:

```hcl
# Shared remote state configuration
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateaccount123"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}
```

### 🔍 Why This Is Powerful

* Remote state is defined **once**
* `${path_relative_to_include()}` automatically creates:

  * `dev/terraform.tfstate`
  * `qa/terraform.tfstate`
  * `prod/terraform.tfstate`

Each environment gets its **own isolated state file**.

---

## 5️⃣ Environment-Level Terragrunt Configuration

![Image](https://kodekloud.com/kk-media/image/upload/v1752884305/notes-assets/images/Terragrunt-for-Beginners-include-Block/include-block-infographic-benefits.jpg)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884351/notes-assets/images/Terragrunt-for-Beginners-find-in-parent-folders/find-in-parent-folders-diagram-best-practices.jpg)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884346/notes-assets/images/Terragrunt-for-Beginners-Terragrunt-Configuration-Files-HCL/terragrunt-inheritance-model-diagram-hcl.jpg)

Open `dev/terragrunt.hcl` (same for qa & prod):

```hcl
include {
  path = find_in_parent_folders()
}
```

### What This Does

* Pulls configuration from the root `terragrunt.hcl`
* Avoids copying backend settings
* Keeps environments clean and minimal

✔ True DRY implementation

---

## 6️⃣ Terraform Code per Environment

![Image](https://cloudbuild.co.uk/wp-content/uploads/2022/02/image-60.png)

![Image](https://opengraph.githubassets.com/33d885fbd91df3e158facf3e078439f4ec91171eeac25ba06be1b79190a53881/gruntwork-io/terragrunt/issues/990)

![Image](https://www.patrickkoch.dev/images/post_26/architecture.png)

Each environment contains a `main.tf` file with **no backend config**.

Example `dev/main.tf`:

```hcl
terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = "dev-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = "eastus"
  resource_group_name = "rg-dev"
}

resource "azurerm_subnet" "subnet" {
  name                 = "dev-subnet"
  resource_group_name  = "rg-dev"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
```

⚠️ Backend block exists but contains **no configuration** — Terragrunt injects it automatically.

---

## 7️⃣ Deploy All Environments with One Command

![Image](https://cdn.prod.website-files.com/63eb9bf7fa9e2724829607c1/6411d50b3d7d7538a2834446_62d3b8f77fcc9c4f0193b146_image6.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AD-1fMDhNqANroySihHkFYg.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884333/notes-assets/images/Terragrunt-for-Beginners-terragrunt-plan/terragrunt-plan-process-terraform-diagram.jpg)

From the root directory:

```bash
terragrunt run-all apply
```

### What Happens Internally

* Terragrunt scans subfolders
* Runs `terraform init`
* Applies each environment one by one
* Uses unique state files automatically

You’ll be prompted to confirm deployment for each environment.

---

## 8️⃣ Understanding Remote State Key Automation

![Image](https://iamachs.com/images/posts/azure-terraform/part-4/terraform-state-workflow.jpg)

![Image](https://api.reliasoftware.com/uploads/terraform_conflicts_56c78b355b.webp)

![Image](https://miro.medium.com/1%2A1gACj3Eq1dyVxxJ8NhDEAQ.png)

Because of this line:

```hcl
key = "${path_relative_to_include()}/terraform.tfstate"
```

Your storage account will contain:

```
tfstate/
 ├── dev/terraform.tfstate
 ├── qa/terraform.tfstate
 └── prod/terraform.tfstate
```

✔ Clean
✔ Organized
✔ Environment-safe

---

## 9️⃣ Destroying All Environments (Use Carefully)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884337/notes-assets/images/Terragrunt-for-Beginners-terragrunt-run-all/terragrunt-run-all-puzzle-workflow.jpg)

![Image](https://i.sstatic.net/FXTaN.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884320/notes-assets/images/Terragrunt-for-Beginners-terragrunt-destroy/terragrunt-destroy-process-illustration.jpg)

To destroy everything:

```bash
terragrunt run-all destroy
```

⚠️ **Warning**

* Never use this on real production systems
* Suitable only for labs, test, or QA environments

Confirm with `y` when prompted.

---

## 10️⃣ Why This Pattern Is Used in Real Projects

![Image](https://cdn.prod.website-files.com/67f9776b8553224cbb897cd7/689389e6f1fa4ac87ee6661f_Diagram%20Blog%205.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20230908011807/Screenshot-from-2023-09-08-01-17-47.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884316/notes-assets/images/Terragrunt-for-Beginners-terragrunt-apply/terragrunt-best-practices-review-approval.jpg)

✔ Single source of truth for backend
✔ Easy environment replication
✔ Cleaner Git repositories
✔ Reduced human error
✔ Industry-standard DevOps pattern

Terragrunt is widely used in **enterprise Azure and AWS platforms**.

---

## ✅ Summary

In this lab, you learned how to:

* Use **Terragrunt** with Terraform
* Keep **remote state DRY**
* Deploy **multiple environments** with one command
* Automatically manage backend state paths
* Safely scale infrastructure configuration

Terragrunt dramatically improves Terraform maintainability when working with **multi-environment Azure deployments**.

---
