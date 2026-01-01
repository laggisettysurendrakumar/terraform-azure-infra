# Using Conditional Logic in Terraform Modules on Azure

Terraform becomes far more powerful when you introduce **conditional logic**. Instead of writing rigid configurations, you can design **flexible, reusable modules** that adapt based on input values. This is especially useful when building enterprise-grade infrastructure.

In this guide, you’ll create a **Terraform module with conditional logic** that deploys Azure resources differently depending on whether optional inputs are provided.

---

## 1️⃣ Why Conditional Logic Matters in Terraform

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AojrzK6V-Pf6kAHV5faXhrA.png)

![Image](https://www.cloudbolt.io/wp-content/uploads/image2-1024x859-1.png)

![Image](https://i0.wp.com/thomasthornton.cloud/wp-content/uploads/2022/06/reusable-terraform-modules-terraform-full.jpg?fit=691%2C571\&ssl=1)

Without conditions, Terraform code quickly becomes repetitive. Conditional expressions allow you to:

* Make inputs optional
* Apply defaults intelligently
* Reduce duplicate modules
* Improve reusability and maintainability

Terraform uses **HCL (HashiCorp Configuration Language)**, which supports logical operators and expressions similar to programming languages.

---

## 2️⃣ Project Structure Using Modules

![Image](https://media.beehiiv.com/cdn-cgi/image/fit%3Dscale-down%2Cformat%3Dauto%2Conerror%3Dredirect%2Cquality%3D80/uploads/asset/file/a70941e1-5fb2-4a29-a70b-a671150e9298/directory_2.png?t=1730702773)

![Image](https://www.cloudbolt.io/wp-content/uploads/terraform-best-practicies-1024x654-1.png)

![Image](https://media2.dev.to/dynamic/image/width%3D800%2Cheight%3D%2Cfit%3Dscale-down%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fym3dz2c5n6oktsxmrxfx.jpeg)

We’ll organize the code using **local modules**, which is a best practice even for small projects.

### Folder layout:

```
terraformlab
 ├── main.tf
 └── modules
     └── app-service
         ├── main.tf
         └── variables.tf
```

📌 In this example, instead of a Storage Account, we’ll deploy an **Azure App Service Plan** using conditional logic.

---

## 3️⃣ Creating the Module Resource with Conditional Logic

![Image](https://media2.dev.to/dynamic/image/width%3D800%2Cheight%3D%2Cfit%3Dscale-down%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fwfsoqyoxnyt1td4mao2i.png)


Create `modules/app-service/main.tf`

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

resource "azurerm_app_service_plan" "asp" {
  name                = var.plan_name
  resource_group_name = var.resource_group
  location            = var.location != "" ? var.location : "eastus"

  kind = "Linux"
  reserved = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}
```

### 🔍 Understanding the Conditional Expression

```hcl
var.location != "" ? var.location : "eastus"
```

This follows the format:

```
condition ? value_if_true : value_if_false
```

Meaning:

* If `location` is provided → use it
* If `location` is empty → default to **East US**

---

## 4️⃣ Defining Module Variables

![Image](https://k21academy.com/wp-content/uploads/2020/08/main.tf-file.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A0C-HoihbDUpZSV2PKEYSkQ.png)

![Image](https://k21academy.com/wp-content/uploads/2020/08/Terraform-IaC_BlogImage.png)

Create `modules/app-service/variables.tf`

```hcl
variable "plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "resource_group" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region for deployment"
  default     = ""
}
```

### Why an Empty String Default?

The empty string (`""`) acts as a **trigger** for the conditional logic.
If the user omits `location`, Terraform automatically applies the fallback region.

---

## 5️⃣ Consuming the Module in Root Configuration

![Image](https://azapril.dev/wp-content/uploads/2020/03/module.png)

![Image](https://jeffbrown.tech/wp-content/uploads/2021/07/root-module-diagram-1024x613.png)

![Image](https://azapril.dev/wp-content/uploads/2020/03/testvars.png?w=1024)

Create `terraformlab/main.tf`

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

module "app_service_default_region" {
  source          = "./modules/app-service"
  plan_name       = "asp-default"
  resource_group  = "rg-demo"
}

module "app_service_custom_region" {
  source          = "./modules/app-service"
  plan_name       = "asp-west"
  resource_group  = "rg-demo"
  location        = "westus"
}
```

### What’s Happening Here?

| Module                       | Location Behavior     |
| ---------------------------- | --------------------- |
| `app_service_default_region` | Uses default `eastus` |
| `app_service_custom_region`  | Deploys to `westus`   |

Same module → different outcomes → zero duplication.

---

## 6️⃣ Initializing and Applying Terraform

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/02/terraform-init-command-terminal-output.png?resize=400%2C242\&ssl=1)

![Image](https://www.datocms-assets.com/2885/1611186902-output1.png)

![Image](https://roykim.ca/wp-content/uploads/2023/02/image-1.png)

Authenticate with Azure:

```bash
az login
```

Initialize Terraform:

```bash
terraform init
```

Apply configuration:

```bash
terraform apply
```

### Terraform Output Will Show:

* One App Service Plan in **East US**
* One App Service Plan in **West US**

All driven by **conditional logic inside the module**.

---

## 7️⃣ Why This Approach Is Powerful

![Image](https://www.cloudbolt.io/wp-content/uploads/terraform-best-practicies-1024x654-1.png)

![Image](https://miro.medium.com/1%2AP24ovPAkTC5Phih9r8oDUg.png)

✔ Modules become environment-agnostic
✔ Optional inputs reduce configuration noise
✔ Defaults are enforced centrally
✔ Cleaner CI/CD pipelines
✔ Fewer bugs from copy-paste configs

This pattern is widely used in:

* Enterprise Terraform codebases
* Platform engineering
* Multi-region deployments

---

## ✅ Summary

In this lab, you learned how to:

* Use **conditional expressions** in Terraform
* Design **flexible Azure modules**
* Handle optional inputs cleanly
* Deploy the same module with different behaviors
* Improve reusability and scalability

Conditional logic is a **core Terraform skill**, and mastering it makes your infrastructure code smarter, safer, and easier to maintain.

