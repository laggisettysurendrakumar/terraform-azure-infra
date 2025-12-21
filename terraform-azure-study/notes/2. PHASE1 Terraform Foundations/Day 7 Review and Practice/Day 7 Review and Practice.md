Day 7 – Review + Practice 

🎯 Goal of Day-7 

By the end of this day, you will: 

Rebuild infrastructure from scratch without looking 

Learn how to identify & fix common Terraform errors 

Be interview-ready for Terraform + Azure basics 

 

 

1️⃣ Rebuild Infrastructure from Scratch (Hands-on Lab) ⭐⭐⭐ 

 

📌 Objective 

Recreate the following using Terraform: 

Azure Resource Group 

Azure Storage Account 

Proper provider versioning 

Clean .tf structure 

 

 

🧠 Rules for Practice 

✔ Do NOT copy from previous days 

✔ Write everything manually 

✔ Use variables 

✔ Use outputs 

✔ Run full Terraform lifecycle 

 

 

📁 Expected Folder Structure 

 

day-07-practice/ 

├── provider.tf 

├── main.tf 

├── variables.tf 

├── outputs.tf 

├── terraform.tfvars 

 

 

 

🔹 Step 1: Provider Configuration (provider.tf) 

 

terraform { 

  required_providers { 

    azurerm = { 

      source  = "hashicorp/azurerm" 

      version = "~> 3.100" 

    } 

  } 

} 

  

provider "azurerm" { 

  features {} 

} 

 

 

🔹 Step 2: Variables (variables.tf) 

 

variable "rg_name" { 

  type        = string 

  description = "Resource group name" 

} 

  

variable "location" { 

  type        = string 

  default     = "Central India" 

} 

  

variable "storage_name" { 

  type        = string 

  description = "Globally unique storage account name" 

} 

 

 

 

🔹 Step 3: Resources (main.tf) 

 

resource "azurerm_resource_group" "rg" { 

  name     = var.rg_name 

  location = var.location 

} 

  

resource "azurerm_storage_account" "sa" { 

  name                     = var.storage_name 

  resource_group_name      = azurerm_resource_group.rg.name 

  location                 = azurerm_resource_group.rg.location 

  account_tier             = "Standard" 

  account_replication_type = "LRS" 

} 

 

 

 

🔹 Step 4: Outputs (outputs.tf) 

 

output "resource_group_name" { 

  value = azurerm_resource_group.rg.name 

} 

  

output "storage_account_name" { 

  value = azurerm_storage_account.sa.name 

} 

 

 

🔹 Step 5: Variable Values (terraform.tfvars) 

 

rg_name      = "rg-day7-practice" 

storage_name = "day7storagedemo01" 

 

 

🔹 Step 6: Run Terraform Commands 

terraform init 

terraform plan 

terraform apply 

 

✅ If everything works → you are production-ready for basics 🎉 

 

 

2️⃣ Fix Common Terraform Errors (Very Important) 🚨 

❌ Error 1: Provider Not Installed 

 

Error: 

Provider registry.terraform.io/hashicorp/azurerm not available  

Fix: 

terraform init  

 

❌ Error 2: Storage Account Name Invalid 

 

Error: 

must be between 3 and 24 characters and lowercase  

Fix: 

Use lowercase 

Add random suffix 

Remove hyphens 

 

 

❌ Error 3: Authentication Failed 

Error: 

Error building ARM Config  

Fix Checklist: 

✔ Azure CLI logged in (az login) 

✔ Correct subscription set 

✔ Service Principal variables exported 

 

 

❌ Error 4: Resource Already Exists 

Error: 

Resource already exists  

Reason: 

Resource created manually or earlier 

Fix Options: 

Import resource (advanced) 

Rename resource 

Delete manually (dev only) 

 

 

❌ Error 5: State File Issues 

Error: 

State file locked  

Fix: 

Wait for lock release 

Never delete lock blindly (prod) 

 

 

3️⃣ Terraform Debugging Tips 🛠 

 

🔍 Use Detailed Logs 

export TF_LOG=TRACE terraform plan  

 

🔍 Validate Syntax 

terraform validate  

 

🔍 Format Code 

terraform fmt  

 

4️⃣ Interview Questions – Terraform Core (Day 1–7) ⭐⭐⭐ 

🔹 Basic Questions 

What is Infrastructure as Code? 

Why is Terraform preferred over ARM templates? 

What is HCL? 

What is a provider? 

 

 

🔹 State & Architecture 

What is terraform.tfstate? 

Why is state critical? 

What happens if state is deleted? 

What is state drift? 

 

 

🔹 Commands 

Difference between terraform plan and terraform apply? 

What does terraform init do? 

How does Terraform know resource dependency? 

 

 

🔹 Azure Specific 

What is AzureRM provider? 

How does Terraform authenticate with Azure? 

Why is Storage Account globally unique? 

 

 

🔹 Scenario-Based 

Two engineers run terraform apply simultaneously — what happens? 

Someone deletes a resource from Azure Portal — how does Terraform react? 

How do you protect secrets in Terraform? 

 

 

5️⃣ Self-Evaluation Checklist ✅ 

✔ Can write Terraform code without reference 

✔ Understand provider & versioning 

✔ Can debug basic errors 

✔ Can explain state clearly 

✔ Ready for interviews 

 

 

Day-7 Final Summary 

✔ Rebuilt infra from scratch 

✔ Practiced real-world errors 

✔ Understood debugging techniques 

✔ Covered interview questions 

✔ Solid Terraform foundation achieved 

 

 
