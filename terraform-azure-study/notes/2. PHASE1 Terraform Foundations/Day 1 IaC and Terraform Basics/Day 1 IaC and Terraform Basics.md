## Day 1 – Infrastructure as Code (IaC) & Terraform Basics 
 

1️⃣ What is Infrastructure as Code (IaC)? 

📌 Definition 

Infrastructure as Code (IaC) means managing and provisioning infrastructure using code instead of manual steps. 

Instead of: 

Clicking in Azure Portal 

Manually creating VMs, VNets, Storage 

You write code that describes: 

What infrastructure you want 

Terraform creates it automatically 

 

🏗 Traditional vs IaC 

Traditional (Manual)        IaC 

Click-based setup          Code-based 

Error-prone                Consistent 

Hard to repeat             Easily repeatable 

No version history         Git versioning 

Slow                       Fast & automated 

 

🧠 Real-World Example 

Manual approach: 

Create VM in Dev 

Re-create same VM in Test 

Re-create same VM in Prod 


➡️ Risk of mismatch 

IaC approach: 

One Terraform file 

Run it in all environments 

➡️ Same infra everywhere ✅ 

 

 

🧾 Simple IaC Example (Terraform) 

resource "azurerm_resource_group" "rg" { name = "rg-demo" location = "East US" }  

👉 This code is your infrastructure. 

 

 

2️⃣ Why Terraform? 

Terraform is an open-source IaC tool created by HashiCorp. 

 

🔑 Key Reasons to Use Terraform 

✅ Cloud-agnostic 

Works with: 

Azure 

AWS 

GCP 

On-prem 

One tool → multiple clouds 🌍 

 

 

✅ Declarative Language (HCL) 

You say what you want, not how to do it. 

Terraform figures out: 

Order of creation 

Dependencies 

 

 

✅ State Management 

Terraform tracks: 

What exists 

What changed 

What to add or delete 

Stored in: 

Local file 

Azure Storage Account (recommended) 

 

 

✅ Idempotent 

Running Terraform multiple times gives the same result. 

 

 

✅ Huge Provider Ecosystem 

Terraform supports 1000+ providers. 

 

 

🔁 Terraform Workflow 

Write Code → Plan → Apply → Manage State  

Command 

Purpose 

terraform init 

Initialize project 

terraform plan 

Preview changes 

terraform apply 

Create/update infra 

terraform destroy 

Delete infra 

 ## Terraform vs ARM vs Bicep (Azure)
---------------------------------------------------------------------
| Feature             | Terraform  | ARM Templates  | Bicep         |
|---------------------|------------|----------------|---------------|
| Language            | HCL        | JSON           | DSL (simpler) |
| Multi-cloud         | ✅ Yes    | ❌ No          | ❌ No         |
| Learning Curve      | Medium     | Hard           | Easy          |
| State Management    | External   | Azure managed  | Azure managed |
| Readability         | ⭐⭐⭐⭐ | ⭐             | ⭐⭐⭐⭐    |
| Community & Support | Huge       | Azure only     | Growing       |
 ---------------------------------------------------------------------

 

🧩 Explanation 

🔹 ARM Templates 

Native Azure IaC 

Very verbose JSON 

Hard to read & maintain 

Example: 

{ "type": "Microsoft.Compute/virtualMachines", "name": "vm1" }  

 

🔹 Bicep 

Simplified ARM 

Compiles into ARM 

Azure-only 

Example: 

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = { name: 'vm1' }  

 

🔹 Terraform (Preferred) 

Clean syntax 

Multi-cloud 

Strong state & modularity 

Example: 

resource "azurerm_virtual_machine" "vm" { name = "vm1" }  


 ## 🧠 When to Use What?
---------------------------------------------------------
| Scenario                           | Best Tool        |
|------------------------------------|------------------|
| Multi-cloud                        | Terraform        |
| Azure-only & simple deployments   | Bicep             |
| Existing ARM-heavy organization   | ARM Templates     |
| Enterprise-scale + CI/CD pipelines| Terraform ✅     |
--------------------------------------------------------



4️⃣ Terraform Architecture (Very Important ⭐)  


🧩 Terraform Core Components 

User Code → Terraform Core → Provider → Cloud API  

 

1️⃣ Terraform Configuration (Code) 

Written in .tf files 

Uses HCL 

Example: 

resource "azurerm_storage_account" "sa" { name = "mystorage123" location = "East US" resource_group_name = "rg-demo" account_tier = "Standard" account_replication_type = "LRS" }  

 

2️⃣ Terraform Core 

Responsible for: 

Parsing code 

Creating execution plan 

Managing state 

Dependency graph 

 

 

3️⃣ Providers 

Providers act as bridge between Terraform and cloud APIs. 

Example: 

azurerm → Azure 

aws → AWS 

provider "azurerm" { features {} }  

 

4️⃣ State File (terraform.tfstate) 

Stores: 

Resource IDs 

Metadata 

Current infra state 

Why important? 

Terraform compares desired state vs actual state 

 

 

5️⃣ Execution Plan 

terraform plan: 

Shows what will be created, changed, deleted 

No changes yet (safe preview) 

 

 

🔁 Complete Flow Example 

terraform init ↓ terraform plan ↓ terraform apply  

 

5️⃣ Simple End-to-End Example (Mental Model) 

🎯 Goal: Create Azure Resource Group 

Step 1 – Write Code 

resource "azurerm_resource_group" "rg" { name = "rg-day1" location = "Central India" }  

Step 2 – Plan 

terraform plan  

➡️ “1 resource will be created” 

Step 3 – Apply 

terraform apply  

➡️ Resource created in Azure 🎉 


Day-1 Summary (Revision Ready) 

✔ IaC = Infrastructure through code 

✔ Terraform = multi-cloud, declarative IaC tool 

✔ Terraform beats ARM/Bicep for enterprise use 

✔ Architecture = Core + Provider + State 

✔ Plan before Apply always 

 
