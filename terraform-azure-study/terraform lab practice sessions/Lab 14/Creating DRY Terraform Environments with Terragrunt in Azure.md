# Creating DRY Terraform Environments with Terragrunt in Azure

Copy-pasting Terraform code across environments (prod, dev, test) often leads to mistakes, configuration drift, and wasted effort.
**Terragrunt** enables a **DRY (Don’t Repeat Yourself)** approach where most of the infrastructure logic stays the same, and **only environment-specific values change**.

In this lab, you’ll learn how to **create a new environment (Development) from an existing one (Production)** by copying a DRY Terragrunt setup and modifying just **one configuration file**.

---

## 1️⃣ Why DRY Environments Matter

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D420%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fceg39lx4%2Fproduction%2Feb45102837a5971f94fed46026121081187f08e2-2000x818.png)

![Image](https://cdn.prod.website-files.com/67f9776b8553224cbb897cd7/683e3cb64d47d0a0df8d1a25_8d12eaa9b5f561f3b321d71ab6b17aea06ca3df1-1100x613.jpeg)

![Image](https://www.hashicorp.com/_next/image?q=75\&url=https%3A%2F%2Fwww.datocms-assets.com%2F2885%2F1607472030-bestprac5.png\&w=3840)

Without DRY principles:

* Each environment has duplicated `.tf` files
* Small changes require editing many places
* Higher risk of errors and inconsistency

With Terragrunt:

* Terraform code stays minimal
* Environment differences are centralized
* New environments are created quickly and safely

---

## 2️⃣ Project Structure Overview

![Image](https://www.nordhero.com/posts/terragrunt-deployment-folders.jpg)

![Image](https://miro.medium.com/0%2AbJzMGdZBo0zKfbvQ)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A6-MiqD8toSS3it7XXL3V-w.png)

The project is organized by **environment and component**.

```
terraformlab
├── terragrunt.hcl
├── environment_vars.yaml
├── production
│   ├── rg
│   ├── network
│   └── server
├── development
│   ├── rg
│   ├── network
│   └── server
```

### Key Design Idea

* Each component (`rg`, `network`, `server`) contains **only `terragrunt.hcl`**
* No `main.tf` or `variables.tf` per environment
* Environment customization is done via **YAML**

---

## 3️⃣ Centralizing Environment Configuration (YAML)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AKd9cheQIMhcUL-qO5LRhlQ.png)

![Image](https://jhooq.com/wp-content/uploads/terraform/terragrunt-guide/valyes-yaml-dev-test-common.webp)

![Image](https://miro.medium.com/0%2AFRA7T7ns3t_fbEi5.png)

At the root, there is an **environment configuration file**:

### `environment_vars.yaml`

```yaml
server_name: appserver-prod
vnet_address: 10.0.0.0/16
snet_address: 10.0.0.0/24
```

This file contains **all values that differ per environment**:

* Server naming
* Network ranges
* Environment identity

---

## 4️⃣ Root Terragrunt Configuration (Locals)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884308/notes-assets/images/Terragrunt-for-Beginners-locals-Block/locals-block-scope-considerations-diagram.jpg)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AKd9cheQIMhcUL-qO5LRhlQ.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884250/notes-assets/images/Terragrunt-for-Beginners-Root-Configuration-and-Remote-State/root-configuration-remote-state-steps.jpg)

Open the **root** `terragrunt.hcl`:

```hcl
locals {
  env_vars = yamldecode(file("environment_vars.yaml"))
}
```

### What This Does

* Reads values from `environment_vars.yaml`
* Stores them as local variables
* Makes them accessible in all child configurations

This is the foundation of the DRY setup.

---

## 5️⃣ Using Remote Terraform Modules

![Image](https://i0.wp.com/wahlnetwork.com/wp-content/uploads/2020/08/image-5.png?fit=910%2C445\&ssl=1)

![Image](https://opengraph.githubassets.com/6fec3f9f57940d56bd2dc50095cfebcc64e96a69b1bd7b045934aea99a5600ae/gruntwork-io/terragrunt/issues/444)

![Image](https://aws-quickstart.github.io/workshop-terraform-modules/20_terraform_module_overview/images/module-version.png)

Open `network/terragrunt.hcl`:

```hcl
terraform {
  source = "git::https://github.com/example/terraform-azure-modules.git//network?ref=v1.0.0"
}

dependency "rg" {
  config_path = "../rg"
}

locals {
  env_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
}

inputs = {
  rg_name       = dependency.rg.outputs.rg_name
  rg_location   = dependency.rg.outputs.rg_location
  vnet_address  = local.env_vars.vnet_address
  snet_address  = local.env_vars.snet_address
}

include {
  path = find_in_parent_folders()
}
```

### Key Concepts Here

* Terraform code comes from a **versioned Git module**
* No local `.tf` files are needed
* Inputs use:

  * Outputs from dependencies
  * Values from YAML
* Infrastructure code remains extremely small

---

## 6️⃣ Authenticate with Azure

![Image](https://i.sstatic.net/HmE1W.png)

![Image](https://codemag.com/Article/Image/2001021/image1.png)

![Image](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/media/filter-view-subscriptions/subscription-list.png)

Before deploying, authenticate with Azure:

```bash
az login
```

Confirm you’re logged into the correct subscription.

---

## 7️⃣ Creating a New Environment (Development)

![Image](https://static.linuxblog.io/wp-content/uploads/2023/04/cp-command-examples.png)

![Image](https://terraform-tutorial.schoolofdevops.com/images/00-windows-path-env-paste.png)

![Image](https://www.sokube.io/wp-content/uploads/032-dry.png)

Copy the **production environment** to create development:

```bash
cd terraformlab
cp -a production development
```

Now both environments share the **same infrastructure logic**.

---

## 8️⃣ Modify Only Environment Values

![Image](https://www.virtualizationhowto.com/wp-content/smush-webp/2022/11/2022-11-14_14-06-14.png.webp)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A7x7SmXVPuUZyP9GbOISZbA.png)

![Image](https://www.arthurkoziel.com/setting-up-vim-for-yaml/indentlines.png)

Update `development/environment_vars.yaml`:

```bash
sed -i 's/appserver-prod/appserver-dev/g' development/environment_vars.yaml
sed -i 's+10.0.0.0/16+10.1.0.0/16+g' development/environment_vars.yaml
sed -i 's+10.0.0.0/24+10.1.0.0/24+g' development/environment_vars.yaml
```

Now:

* Server names differ
* Network ranges don’t overlap
* No Terraform code was modified

---

## 9️⃣ Deploy the Development Environment

![Image](https://cdn.prod.website-files.com/63eb9bf7fa9e2724829607c1/6411d50b3d7d7538a2834446_62d3b8f77fcc9c4f0193b146_image6.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752884359/notes-assets/images/Terragrunt-for-Beginners-Terragrunt-Cache/terragrunt-cache-process-diagram.jpg)

![Image](https://www.datocms-assets.com/2885/1647468806-com-terraform-before-and-after.svg)

Move into the development environment:

```bash
cd development
terragrunt run-all apply
```

Terragrunt will:

* Download remote modules into `.terragrunt-cache`
* Apply RG → Network → Server
* Maintain separate state files
* Deploy the full environment automatically

---

## 🔟 What Makes This Approach Powerful

![Image](https://kodekloud.com/kk-media/image/upload/v1752884290/notes-assets/images/Terragrunt-for-Beginners-The-DRY-Principle/dry-principle-benefits-code-maintenance.jpg)

![Image](https://media.licdn.com/dms/image/v2/D4D12AQG0V8j9aW1sLQ/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1734069812626?e=2147483647\&t=tLiRZVP1BL9reP480XkBLk5Km7L67ykO4OTmblstHgE\&v=beta)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2A5uGN0LPP4D5Thl7rvDjE0Q.png)

✔ One YAML file controls the environment
✔ Terraform code is reused without duplication
✔ New environments are created in minutes
✔ Safer and cleaner than `.tfvars` per folder
✔ Matches real enterprise DevOps practices

---

## ✅ Summary

In this lab, you learned how to:

* Create DRY Terraform environments using Terragrunt
* Centralize environment values in YAML
* Use remote, versioned Terraform modules
* Spin up a new environment by modifying **one file**
* Avoid copy-paste Terraform configurations

This pattern is widely used in **enterprise Azure + Terraform + Terragrunt setups**.

