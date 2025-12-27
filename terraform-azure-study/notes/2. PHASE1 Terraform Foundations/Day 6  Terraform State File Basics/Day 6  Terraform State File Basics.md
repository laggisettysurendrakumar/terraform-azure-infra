# **Day 6 – Terraform State File Basics**

🎯 **Goal of Day-6**
By the end of this day, you will clearly understand:

* What `terraform.tfstate` is
* Why Terraform state is critical
* How Terraform uses state internally
* Why **local state is risky** in real-world teams

---

## **1️⃣ What is `terraform.tfstate`?**

### 📌 Definition

`terraform.tfstate` is a **JSON file** that Terraform uses to **track real infrastructure**.

It acts as Terraform’s **source of truth**.

Terraform compares:

```text
Desired State (HCL code)
vs
Current State (terraform.tfstate)
```

---

### 🧠 What State Stores

The state file contains:

* Resource IDs (Azure resource IDs)
* Resource attributes
* Dependency relationships
* Metadata about providers

---

### 🧪 Example (Simplified State Snippet)

```json
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
```

📌 **Never edit this file manually**.

---

## **2️⃣ Why State Matters (Very Important ⭐⭐⭐)**

### 🔍 Terraform Without State?

Without state, Terraform:
❌ Cannot know what already exists

❌ Will try to recreate everything

❌ Cannot detect drift

❌ Cannot safely update resources

---

### 🧠 Terraform Decision Flow

```text
terraform plan
   ↓
Read terraform.tfstate
   ↓
Compare with .tf code
   ↓
Generate execution plan
```

---

### 🧪 Real Example

**You change code:**

```hcl
location = "East US"
```

Terraform checks state:

```text
Current: Central India
Desired: East US
```

➡️ Terraform plans **MODIFY**, not CREATE.

---

## **3️⃣ What Happens If State is Deleted?** ⚠️

If `terraform.tfstate` is deleted:

* Terraform thinks **nothing exists**
* It may try to recreate resources
* Duplicate resources or failures occur

📌 Azure resources still exist, but Terraform **forgets them**.

---

## **4️⃣ Local State (Default Behavior)**

### 📌 What is Local State?

By default, Terraform stores state **locally**:

```text
terraform.tfstate
terraform.tfstate.backup
```

Location:

* Same directory as `.tf` files

---

### 🧪 Local State Example

```bash
terraform apply
```

Creates:

```text
terraform.tfstate
terraform.tfstate.backup
```

---

### 🧠 Backup File

* `terraform.tfstate.backup` = previous state
* Automatically created by Terraform

---

## **5️⃣ Local State Risks (Real-World Problems)** 🚨

### ❌ Risk 1: No Team Collaboration

* Each engineer has a different state
* Changes conflict
* Terraform becomes unreliable

---

### ❌ Risk 2: No State Locking

Two people run:

```bash
terraform apply
```

At the same time →

❌ Race condition

❌ Corrupted state


---

### ❌ Risk 3: Secrets in Plain Text

State file may contain:

* Storage keys
* Passwords
* Connection strings

⚠️ Stored as **plain text JSON**

---

### ❌ Risk 4: Accidental Deletion

* Laptop crash
* Folder deleted
* No recovery

---

### ❌ Risk 5: No Audit History

* No tracking of who changed what
* No rollback mechanism

---

## **6️⃣ Visual Mental Model (State Importance)**

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/666ca94313bc92617e6eb9fa_AD_4nXe-5_WQu-YNEB3tjjsejMPFliYTzRNjfX5D4sBknnJ9T-25KaQ1UAv3JsxDelee3icN2knxbdR7O6Upx--gqbvpij3hpWqgifxPez8_0ZtHflV45C1BsL3Wzs_tSLjn7WhK9JoiuY6EAd3gAtPfFU3-HaJ-.png?utm_source=chatgpt.com)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AazlDiCZlFfytmHqEF3reyw.png?utm_source=chatgpt.com)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AazlDiCZlFfytmHqEF3reyw.png?utm_source=chatgpt.com)

---

## **7️⃣ State Drift (Hidden Danger)** ⭐⭐

### 📌 What is Drift?

Drift occurs when:

* Someone changes infrastructure manually
* Terraform state is not updated

---

### 🧪 Example

1. Terraform creates Storage Account
2. Someone deletes it from Azure Portal
3. Terraform state still thinks it exists

Next `terraform plan`:

```text
+ create azurerm_storage_account
```

➡️ Terraform **fixes drift** automatically.

---

## **8️⃣ Best Practices for State (Day-6 Key Takeaways)**

✔ Never commit `terraform.tfstate` to GitHub

✔ Never edit state manually

✔ Use **remote backend** for teams

✔ Enable **state locking**

✔ Protect state like credentials

---

## **Day-6 Summary**

✔ `terraform.tfstate` tracks real infrastructure

✔ State enables safe updates & deletes

✔ Local state works only for learning

✔ Local state is risky for teams

✔ Remote state is mandatory in production

---
