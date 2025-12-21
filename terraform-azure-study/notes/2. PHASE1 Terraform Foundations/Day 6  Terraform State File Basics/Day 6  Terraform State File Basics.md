Day 6 – Terraform State File Basics 

🎯 Goal of Day-6 

By the end of this day, you will clearly understand: 

What terraform.tfstate is 

Why Terraform state is critical 

How Terraform uses state internally 

Why local state is risky in real-world teams 

 

 

1️⃣ What is terraform.tfstate? 

📌 Definition 

terraform.tfstate is a JSON file that Terraform uses to track real infrastructure. 

It acts as Terraform’s source of truth. 

 

Terraform compares: 

Desired State (HCL code) vs Current State (terraform.tfstate)  

 

🧠 What State Stores 

The state file contains: 

Resource IDs (Azure resource IDs) 

Resource attributes 

Dependency relationships 

Metadata about providers 

 

 

🧪 Example (Simplified State Snippet) 

 

{ 

  "resources": [ 

    { 

      "type": "azurerm_resource_group", 

      "name": "rg", 

      "instances": [ 

        { 

          "attributes": { 

            "name": "rg-day5-demo", 

            "location": "centralindia" 

          } 

        } 

      ] 

    } 

  ] 

} 

 

 

📌 Never edit this file manually. 

 

 

2️⃣ Why State Matters (Very Important ⭐⭐⭐) 

🔍 Terraform Without State? 

Without state, Terraform: 

❌ Cannot know what already exists 

❌ Will try to recreate everything 

❌ Cannot detect drift 

❌ Cannot safely update resources 

 

 

🧠 Terraform Decision Flow 

 

terraform plan 

   ↓ 

Read terraform.tfstate 

   ↓ 

Compare with .tf code 

   ↓ 

Generate execution plan 

 

 

🧪 Real Example 

You change code: 

location = "East US"  

Terraform checks state: 

Current: Central India Desired: East US  

➡️ Terraform plans MODIFY, not CREATE. 

 

 

3️⃣ What Happens If State is Deleted? ⚠️ 

If terraform.tfstate is deleted: 

Terraform thinks nothing exists 

It may try to recreate resources 

Duplicate resources or failures occur 

📌 Azure resources still exist, but Terraform forgets them. 

 

 

4️⃣ Local State (Default Behavior) 

📌 What is Local State? 

By default, Terraform stores state locally: 

terraform.tfstate  

terraform.tfstate.backup  

 

Location: 

Same directory as .tf files 

 

 

🧪 Local State Example 

terraform apply  

Creates: 

terraform.tfstate  

terraform.tfstate.backup  

 

🧠 Backup File 

terraform.tfstate.backup = previous state 

Automatically created by Terraform 

 

 

5️⃣ Local State Risks (Real-World Problems) 🚨 

❌ Risk 1: No Team Collaboration 

Each engineer has a different state 

Changes conflict 

Terraform becomes unreliable 

 

 

❌ Risk 2: No State Locking 

Two people run: 

terraform apply  

At the same time → 

❌ Race condition 

❌ Corrupted state 

 

 

❌ Risk 3: Secrets in Plain Text 

State file may contain: 

Storage keys 

Passwords 

Connection strings 

⚠️ Stored as plain text JSON 

 

 

❌ Risk 4: Accidental Deletion 

Laptop crash 

Folder deleted 

No recovery 

 

 

❌ Risk 5: No Audit History 

No tracking of who changed what 

No rollback mechanism 

 

 

State Drift (Hidden Danger) ⭐⭐ 

📌 What is Drift? 

Drift occurs when: 

Someone changes infrastructure manually 

Terraform state is not updated 

 

 

🧪 Example 

Terraform creates Storage Account 

Someone deletes it from Azure Portal 

Terraform state still thinks it exists 

Next terraform plan: 

+ create azurerm_storage_account  

➡️ Terraform fixes drift automatically. 

 

 

8️⃣ Best Practices for State (Day-6 Key Takeaways) 

✔ Never commit terraform.tfstate to GitHub 

✔ Never edit state manually 

✔ Use remote backend for teams 

✔ Enable state locking 

✔ Protect state like credentials 

 

Day-6 Summary (Revision Ready) 

✔ terraform.tfstate tracks real infrastructure 

✔ State enables safe updates & deletes 

✔ Local state works only for learning 

✔ Local state is risky for teams 

✔ Remote state is mandatory in production 

 

 

 
