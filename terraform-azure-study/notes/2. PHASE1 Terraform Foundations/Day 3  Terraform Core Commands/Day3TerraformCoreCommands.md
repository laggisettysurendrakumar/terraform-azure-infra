Day 3 – Terraform Core Commands & Provider Versioning 

🎯 Goal of Day-3 

By the end of this day, you will clearly understand: 

What each core Terraform command does internally 

How Terraform plans & applies changes 

How providers work 

Why provider versioning is critical in real projects 

 

 

1️⃣ terraform init 

 

📌 What is terraform init? 

terraform init initializes a Terraform working directory. 

It prepares Terraform to work with your configuration. 

 

 

🔍 What Happens Internally? 

When you run: 

terraform init  

Terraform does the following: 

Downloads required providers 

Initializes the backend (local or remote) 

Creates the .terraform/ directory 

Generates .terraform.lock.hcl 

 

 

🧠 Key Files Created 

.terraform/ 

└── providers/ 

.terraform.lock.hcl 

 

.terraform/ → Provider binaries  

.terraform.lock.hcl → Locked provider versions 

 

🧪 Example 

 

provider "azurerm" { features {} }  

 

Run: 

terraform init  

✅ AzureRM provider is downloaded. 

 

 

⚠️ Important Notes 

Must be run first 

Re-run if: 

Provider changes 

Backend changes 

Terraform version changes 

 

 

2️⃣ terraform plan 

 

📌 What is terraform plan? 

terraform plan creates an execution plan without making changes. 

It answers: 

“What will Terraform do if I apply this?” 

 

🔍 What Happens Internally? 

Terraform: 

Reads your .tf files 

Reads the state file 

Compares: 

Desired state (code) 

Current state (real infrastructure) 

Shows the difference 

 

 

🧪 Example 

terraform plan  

Output: 

+ create azurerm_resource_group.rg  

Symbols: 

+ → Create 

~ → Modify 

- → Destroy 

 

 

✅ Why plan is Critical 

Prevents surprises 

Required in CI/CD pipelines 

Safe preview before apply 

 

 

🧠 Pro Tip 

 

terraform plan -out=tfplan  

Then: 

terraform apply tfplan  

➡️ Ensures only reviewed changes are applied. 

 

 

3️⃣ terraform apply 

 

📌 What is terraform apply? 

terraform apply executes the plan and creates/modifies infrastructure. 

 

🔍 What Happens Internally? 

Terraform creates a dependency graph 

Resources are created in correct order 

State file is updated 

Output is displayed 

 

🧪 Example 

terraform apply  

 

Terraform asks: 

Do you want to perform these actions? Type 'yes'  

➡️ Type yes → Infrastructure created 🎉 

 

 

⚠️ Important Rules 

Always run plan before apply 

Never apply unreviewed changes in production 

 

 

🔐 CI/CD Mode 

terraform apply -auto-approve  

⚠️ Use only in pipelines with approvals. 

 

 

4️⃣ terraform destroy 

📌 What is terraform destroy? 

terraform destroy deletes all resources managed by Terraform. 

 

🔍 What Happens Internally? 

Terraform reads state 

Determines all managed resources 

Deletes them safely in reverse order 

 

🧪 Example 

terraform destroy  

Confirmation required: 

Type 'yes'  

 

⚠️ Danger Zone 🚨 

Deletes everything 

Never run blindly in production 

 

 

🧠 Best Practice 

terraform plan -destroy  

➡️ Preview destruction before executing. 

 

 

5️⃣ Terraform Provider (Deep Dive) 

 

📌 What is a Provider? 

A provider is a plugin that allows Terraform to interact with APIs. 

Examples: 

Azure → azurerm 

AWS → aws 

 

 

🧩 Provider Architecture 

Terraform Core → Provider → Cloud API  

 

🧪 Example Provider Block 

 

provider "azurerm"  

{  

  features {}  

}  

 

🔹 Multiple Providers Example 

 

provider "azurerm"  

{  

  features {} 

}  

 

provider "aws"  

{  

  region = "us-east-1" 

} 

 

➡️ Same Terraform codebase, multi-cloud power 💪 

 

 

6️⃣ Provider Versioning (VERY IMPORTANT ⭐) 

📌 Why Versioning Matters 

Providers change: 

New features 

Bug fixes 

Breaking changes 

Without versioning: 

❌ Builds break 

❌ CI/CD failures 

❌ Unexpected behavior 

 

 

🧪 Version Constraint Example 

 

terraform { 

  required_providers { 

    azurerm = { 

      source  = "hashicorp/azurerm" 

      version = "~> 3.100" 

    } 

  } 

} 

 

 

🧠 Version Symbols Explained 

Symbol 

Meaning 

= 3.100.0 

Exact version 

>= 3.0 

Minimum version 

~> 3.100 

Allow patch updates 

< 4.0 

Less than version 

 

✅ Recommended: ~> (pessimistic constraint) 

 

 

🔒 Provider Lock File 

.terraform.lock.hcl ensures: 

Same provider version across team 

Consistent CI/CD behavior 

⚠️ Commit this file to GitHub 

 

 

7️⃣ End-to-End Example (Mental Model) 

🎯 Goal: Create & Delete Resource Group 

 

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

  

resource "azurerm_resource_group" "demo" { 

  name     = "rg-day3-demo" 

  location = "Central India" 

} 

 

Day-3 Summary (Revision Ready) 

✔ init → setup environment 

✔ plan → preview changes 

✔ apply → create/update infra 

✔ destroy → delete infra 

✔ Providers connect Terraform to cloud 

✔ Versioning prevents breaking changes 

 

 
