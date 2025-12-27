# 🟡 Day 20 – Terraform State Management

**(`terraform state list` • `terraform state rm` • Import Existing Resources)**

Terraform state is **not just a file**—it’s Terraform’s **memory**.
Knowing how to manage it safely prevents **downtime, drift, and accidental deletes**.

This day teaches you how to inspect, fix, and recover Terraform state safely—a core real-world skill.

![Image](https://miro.medium.com/1%2AlmYNNT40GBPaVEL2K4zzNg.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AzhlOZE8QQQHJFGUbj4lzlw.jpeg)

![Image](https://k21academy.com/wp-content/uploads/2020/11/terraform-import-workflow-diagram-400x152.png)

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/666d1cb47b96efb34716e791_AD_4nXea93FasBUuz71-dnR4L8YRpsdDsL1tmNboinkvqFzdzB8l547Y04YDpWxpaOc8ogspABEpnoMlALX3M7t6VyUtc9XA1H_UEaYc3SWZQ__S7JVfg9lRcJMurQtZRjqG55tahJvBkikm7eAZs5y6UxI3vJc.png)

---

## 🧠 Why State Management Matters

In real projects:

* Resources may be created **outside Terraform**
* Code may be **refactored**
* State can go **out of sync**

State management lets you:

✔ Inspect what Terraform thinks exists

✔ Fix mismatches safely

✔ Bring existing infra under Terraform control

---

## 1️⃣ `terraform state list` – Inspect State

### 🔹 What It Does

Lists **all resources currently tracked** in the state file.

👉 It does **NOT** query Azure

👉 It reads **only the state**

---

### 🔹 Command

```bash
terraform state list
```

---

### 🔹 Example Output

```text
azurerm_resource_group.rg
azurerm_virtual_network.vnet
azurerm_subnet.subnet
azurerm_network_interface.nic
azurerm_linux_virtual_machine.vm
```

---

### 🔹 When You Use It (REAL LIFE)

* Before refactoring code
* Before deleting resources
* To verify what Terraform controls
* During debugging

---

### 🔹 Interview Tip

> **Q:** Does `terraform state list` check Azure?
> **A:** No. It only reads Terraform state.

---

## 2️⃣ `terraform state rm` – Remove from State (NOT FROM AZURE)

### 🔹 What It Does

Removes a resource **only from state**, **not from Azure**.

👉 Terraform **forgets** the resource

👉 The resource **continues to exist** in Azure

---

### 🔹 Command Syntax

```bash
terraform state rm <RESOURCE_ADDRESS>
```

---

### 🔹 Example

```bash
terraform state rm azurerm_linux_virtual_machine.vm
```

Result:

* VM still exists in Azure ✅
* Terraform no longer tracks it ❌

---

### 🔹 Real-World Use Cases

✔ Resource created manually

✔ Want Terraform to stop managing it

✔ Preparing for re-import

✔ Fixing broken state entries

---

### 🔹 ⚠️ VERY IMPORTANT WARNING

❌ **Do NOT run `terraform apply` immediately** after `state rm`
Terraform may try to **recreate** the resource.

✔ First: decide next step

* Re-import
* Or remove resource block

---

### 🔹 Interview Tip

> **Q:** Does `terraform state rm` delete Azure resources?
> **A:** No. It only removes them from state.

---

## 3️⃣ Import Existing Azure Resources (CRITICAL SKILL)

### 🔹 What Is Import?

`terraform import` tells Terraform:

> “This existing Azure resource belongs to this Terraform resource block.”

---

### 🔹 When Import Is Needed

* Infra created via Azure Portal
* Infra created by another team
* Migrating from manual → Terraform
* Legacy environments

---

### 🔹 Import Workflow (VERY IMPORTANT)

```text
Existing Azure Resource
        ↓
Write matching Terraform code
        ↓
terraform import
        ↓
terraform plan
```

---

## 4️⃣ Import Example – Resource Group

### 🔹 Step 1: Write Terraform Code (NO apply)

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-existing"
  location = "East US"
}
```

---

### 🔹 Step 2: Import Resource

```bash
terraform import azurerm_resource_group.rg /subscriptions/<SUB_ID>/resourceGroups/rg-existing
```

---

### 🔹 Step 3: Verify

```bash
terraform plan
```

Expected:

```
No changes. Infrastructure is up-to-date.
```

✅ Import successful

---

## 5️⃣ Import Example – Virtual Machine (COMMON INTERVIEW QUESTION)

```bash
terraform import \
  azurerm_linux_virtual_machine.vm \
  /subscriptions/<SUB_ID>/resourceGroups/rg-app/providers/Microsoft.Compute/virtualMachines/linux-vm
```

---

### 🔹 Key Rule (CRITICAL)

Terraform code **MUST MATCH** the real Azure resource:

* Size
* OS
* Disks
* Network

❌ If not → Terraform plans changes

---

## 6️⃣ Import + Remote State (Production Reality)

Imported resources are stored in:

* **Remote state**
* With locking
* With RBAC

✔ Safe for teams

✔ Enterprise-ready

---

## 7️⃣ Common State Management Scenarios

### 🔹 Scenario 1: Drift

* Someone changes VM size in portal
* Terraform state ≠ Azure

Fix:

```bash
terraform plan
terraform apply
```

---

### 🔹 Scenario 2: Broken Resource

* Resource deleted manually
* Still in state

Fix:

```bash
terraform state rm <resource>
```

---

### 🔹 Scenario 3: Take Over Existing Infra

Fix:

```bash
terraform import
```

---

## ❌ Common Mistakes (VERY IMPORTANT)

❌ Editing state file manually

❌ Importing without writing resource block

❌ Wrong Azure resource ID

❌ Running apply blindly after `state rm`

❌ Importing into wrong module path

---

## 🧠 Interview Questions (Day 20)

**Q: Difference between `state rm` and destroy?**
`state rm` removes from state only; destroy deletes Azure resource.

**Q: Can Terraform import create resources?**
❌ No. Import only links existing ones.

**Q: Why is import important?**
For migrating existing infra to Terraform.

**Q: What happens if config doesn’t match imported resource?**
Terraform plans changes.

---

## 🎯 You Are READY When You Can

✅ Inspect Terraform state confidently

✅ Safely remove resources from state

✅ Import existing Azure resources

✅ Fix drift & broken state

---
