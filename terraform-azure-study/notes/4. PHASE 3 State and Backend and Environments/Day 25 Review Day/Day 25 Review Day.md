# 🟡 Day 25 – Review Day

**(Fix Broken Infrastructure • Rebuild with Backend)**

This day simulates **real production scenarios**:

* Terraform state is broken
* Infrastructure is partially created
* Backend is missing or misconfigured

👉 A strong Terraform engineer **knows how to recover safely**.

---

## 🎯 Goal of Review Day

By the end of Day 25, you should be able to:

* Diagnose broken Terraform setups
* Fix state and infra safely
* Rebuild infrastructure using **remote backend**
* Avoid panic and data loss

---

## 🧠 What “Broken Infra” Really Means

Broken infra does **NOT always mean Azure is broken**.

It usually means:

* Terraform state is wrong
* Backend is misconfigured
* Resources exist but Terraform lost track
* Partial apply failed

---

## 1️⃣ Fixing Broken Infrastructure (Step-by-Step)

### 🔹 Common Broken Scenarios

| Scenario            | What Happened               |
| ------------------- | --------------------------- |
| Apply failed at 60% | Partial resources created   |
| VM deleted manually | State still has VM          |
| Backend deleted     | Terraform can’t find state  |
| State mismatch      | Drift between Azure & state |

---

## 2️⃣ Step 1: Stop & Inspect (MOST IMPORTANT)

❌ **Do NOT run `terraform apply` immediately**

First, inspect.

### 🔹 Check Current State

```bash
terraform state list
```

Questions to ask:

* What does Terraform think exists?
* Does it match Azure?

---

### 🔹 Check Azure Reality

```bash
az resource list --resource-group <RG_NAME> --output table
```

👉 Compare **Terraform state vs Azure**

---

## 🔍 Visual: Debug Before Fixing

![Image](https://miro.medium.com/v2/da%3Atrue/resize%3Afit%3A1200/0%2AzgB8rYgEyBwuddAc)

![Image](https://developer.hashicorp.com/_next/image?dpl=dpl_AfXN3fbGqAojMmK9StgVYth2DCPP\&q=75\&url=https%3A%2F%2Fcontent.hashicorp.com%2Fapi%2Fassets%3Fproduct%3Dtutorials%26version%3Dmain%26asset%3Dpublic%252Fimg%252Fterraform%252Ftroubleshooting%252Ftf-layers.png%26width%3D2400%26height%3D810\&w=3840)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20230606114940/Terraform-flow-chartr-%282%29.webp)

---

## 3️⃣ Step 2: Fix State Problems (SAFE METHODS)

---

### 🔹 Case 1: Resource Deleted Manually in Azure

**Problem**

* Azure resource ❌
* Terraform state still has it ✅

**Fix**

```bash
terraform state rm azurerm_linux_virtual_machine.vm
```

Then:

```bash
terraform plan
terraform apply
```

✔ Terraform recreates resource cleanly

---

### 🔹 Case 2: Resource Exists but Terraform Doesn’t Know

**Problem**

* Azure resource exists
* Terraform wants to recreate it

**Fix → Import**

```bash
terraform import azurerm_virtual_network.vnet /subscriptions/<SUB_ID>/resourceGroups/rg-app/providers/Microsoft.Network/virtualNetworks/vnet-dev
```

Then:

```bash
terraform plan
```

✔ Plan should show **no changes**

---

## 4️⃣ Rebuild with Backend (CRITICAL SKILL)

This is a **very common real-world task**:

> “Move local Terraform to remote backend without breaking infra.”

---

## 5️⃣ Step-by-Step: Rebuild Using Azure Backend

### 🔹 Step 1: Backup Local State (MANDATORY)

```bash
cp terraform.tfstate terraform.tfstate.backup
```

---

### 🔹 Step 2: Create Backend Resources (Once)

* Resource Group
* Storage Account
* Blob Container

(Usually done via CLI or bootstrap Terraform)

---

### 🔹 Step 3: Add Backend Configuration

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate01"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

---

### 🔹 Step 4: Reinitialize Terraform

```bash
terraform init
```

Terraform asks:

```
Do you want to migrate existing state?
```

👉 Answer **YES**

---

## 🔍 Visual: Local → Remote Backend Migration

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/678d39797c13e74dcca1c50e_AD_4nXfXJ1FY-HuWKhAo8p_XvduQ2jinfLu_wJaN0sdvJ8boRV0GI3HfH9ntm75PESZZdVfa4pBvZK5Iv-1mZWq7-vcH4_I5Sqpog6V0qYvKGhxWFHjPEN9pNpeVDM_YdbYtQPSc1D9J0Q.png)

![Image](https://skundunotes.com/wp-content/uploads/2021/08/48.image-1-3.png?w=640)

![Image](https://mycloudrevolution.com/2025/01/06/terraform-azurerm-backend/images/azurerm-diagram_hu_9f138f3115d297ac.png)

---

## 6️⃣ Validate After Migration

### 🔹 Always Run

```bash
terraform plan
```

Expected:

```
No changes. Infrastructure is up-to-date.
```

✔ Migration successful

✔ No infra damage

---

## 7️⃣ Full Recovery Scenario (REALISTIC)

### 🔹 Situation

* Infra exists in Azure
* Local state lost
* Need to rebuild Terraform safely

### 🔹 Recovery Steps

1. Write Terraform code matching Azure
2. Configure remote backend
3. Run `terraform init`
4. Import all resources
5. Run `terraform plan`
6. Apply only when plan is clean

👉 This is **senior-level Terraform work**

---

## ❌ Dangerous Mistakes to Avoid

❌ Running `terraform apply` blindly

❌ Deleting backend storage

❌ Editing state manually

❌ Importing wrong resource IDs

❌ Skipping state backup

---

## 🧠 Review Day Checklist (PRINT THIS)

Before touching infra:

* [ ] State backed up
* [ ] Backend verified
* [ ] Plan reviewed
* [ ] Azure reality checked
* [ ] Correct workspace/env

---

## 🧠 Interview Questions (Day 25)

**Q: What’s the first step when Terraform breaks?**
Stop and inspect state.

**Q: How do you move local state to remote backend?**
Add backend → `terraform init` → migrate state.

**Q: Can broken infra be fixed without destroy?**
Yes, using state commands & import.

**Q: Should you ever edit state manually?**
No (except rare emergency with backup).

---

## 🎯 You Are READY When You Can

✅ Fix broken Terraform infra calmly

✅ Recover from state issues

✅ Migrate to remote backend safely

✅ Explain recovery steps clearly

---

## 🎉 Phase 3 Completed (Days 19–25)

You have mastered:

✔ Remote state

✔ State locking

✔ State commands

✔ Import

✔ Workspaces

✔ Environment patterns

✔ Secrets

✔ Debugging

✔ Recovery

---

