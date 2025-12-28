## Day 41 – Migration Scenarios

### Manual → Terraform | ARM → Terraform (Azure Enterprise POV)

Migration is where **Terraform maturity is truly tested**.
Most real-world Azure environments already exist — created via **Portal clicks or ARM templates**.
Your job is to **bring them under Terraform safely, without downtime**.

---

## 1️⃣ Why Migration to Terraform Is Needed

### Common Enterprise Reality

* Infra created manually in Azure Portal
* Some ARM templates used by Dev teams
* No version control
* No drift visibility
* No approval workflows

### Terraform Solves

✔ Single source of truth

✔ Change visibility

✔ CI/CD enforcement

✔ Governance & compliance

👉 Migration is **not rebuild**, it’s **adoption**.

---

## 2️⃣ Migration Types (What We’re Covering)

| Scenario           | Meaning                  |
| ------------------ | ------------------------ |
| Manual → Terraform | Portal-created resources |
| ARM → Terraform    | ARM/Bicep-managed infra  |

---

## 3️⃣ Migration Principles (VERY IMPORTANT)

Before touching tools, follow these **golden rules**:

1. ❌ **Never destroy production resources**
2. ✔ Import first, modify later
3. ✔ One resource at a time
4. ✔ Validate with `terraform plan`
5. ✔ Use remote state from Day 39

---

## 4️⃣ Manual → Terraform Migration (Portal → IaC)

### Scenario

A Storage Account exists, created manually.

---

### Step 1: Identify the Resource

From Azure Portal:

```
Resource Group: prod-rg
Resource: storage account prodstore01
```

---

### Step 2: Write Matching Terraform Code (NO APPLY)

```hcl
resource "azurerm_storage_account" "sa" {
  name                     = "prodstore01"
  resource_group_name      = "prod-rg"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

❗ Code must **exactly match** Azure config.

---

### Step 3: Import the Resource

```bash
terraform import \
azurerm_storage_account.sa \
/subscriptions/<sub-id>/resourceGroups/prod-rg/providers/Microsoft.Storage/storageAccounts/prodstore01
```

✔ No resource recreated

✔ State updated

---

### Step 4: Validate with Plan

```bash
terraform plan
```

✅ **Expected Output**

```
No changes. Infrastructure is up-to-date.
```

❌ If changes appear → Fix code, NOT Azure.

![Image](https://k21academy.com/wp-content/uploads/2020/11/terraform-import-workflow-diagram-400x152.png)

![Image](https://learn.microsoft.com/en-us/azure/developer/terraform/azure-export-for-terraform/media/terraform-export-blade.png)

---

## 5️⃣ Common Issues in Manual → Terraform Migration

| Problem                   | Fix                        |
| ------------------------- | -------------------------- |
| Drift detected            | Match Terraform attributes |
| Missing tags              | Add tags in code           |
| Wrong SKU                 | Update code                |
| Provider version mismatch | Lock provider              |

---

## 6️⃣ ARM → Terraform Migration (Template-Based)

### Scenario

Infra deployed using ARM JSON templates.

---

### Step 1: Understand ARM Template

ARM Example:

```json
{
  "type": "Microsoft.Storage/storageAccounts",
  "name": "armstore01",
  "sku": {
    "name": "Standard_LRS"
  }
}
```

---

### Step 2: Convert ARM → Terraform

#### Option A: Manual Conversion (Recommended)

Understand mapping:

* ARM Resource → Terraform Resource
* ARM Parameters → Terraform Variables

Terraform:

```hcl
resource "azurerm_storage_account" "sa" {
  name                     = "armstore01"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

✔ Clean

✔ Maintainable

✔ Enterprise-friendly

---

### Option B: Automated Conversion (Use Carefully)

Tools:

* aztfexport
* Terraformer

Example:

```bash
aztfexport resource-group prod-rg
```

⚠ Output is **not production-ready**
⚠ Requires refactoring

![Image](https://blog.gripdev.xyz/wp-content/uploads/2018/06/armvshcl.png)

![Image](https://blog.teknews.cloud/assets/aztfexport/aztfexportworkflow.png)

---

## 7️⃣ Importing ARM-Deployed Resources

Even ARM-created resources must be **imported**, not recreated.

```bash
terraform import azurerm_virtual_network.vnet <resource-id>
terraform import azurerm_subnet.subnet <resource-id>
```

✔ ARM stops managing

✔ Terraform takes control

---

## 8️⃣ Large-Scale Migration Strategy (Enterprise)

### Recommended Order

1. Resource Groups
2. Networking (VNet, Subnets)
3. Shared Services
4. Compute
5. Databases

### Why?

* Prevent dependency breakage
* Reduce blast radius

![Image](https://miro.medium.com/1%2AlligEQRC9JD65HoTROBLeQ.png)

![Image](https://pbs.twimg.com/media/GywXEpqWoAAF2-B.jpg)

---

## 9️⃣ State Management During Migration

✔ Separate state files per layer

✔ Import resources into correct state

✔ Never mix unrelated resources

```
network.tfstate
compute.tfstate
database.tfstate
```

---

## 🔟 Validation & Safety Checks

After each migration:

```bash
terraform plan
terraform validate
```

Before production:

* Peer review
* Pipeline plan
* Approval gate

---

## 1️⃣1️⃣ What NOT To Do (Interview Traps)

❌ `terraform apply` without import

❌ Import everything at once

❌ Modify Azure portal after import

❌ Ignore drift warnings

---

## 1️⃣2️⃣ Manual vs ARM Migration Summary

| Aspect            | Manual → TF     | ARM → TF      |
| ----------------- | --------------- | ------------- |
| Complexity        | Medium          | Medium–High   |
| Import required   | ✔               | ✔             |
| Conversion effort | Manual          | Manual / Tool |
| Risk              | Low (if phased) | Medium        |

---

## 1️⃣3️⃣ Real-World Usage Insight

Most enterprises:

* **Legacy infra** → Portal
* **Mid-stage infra** → ARM
* **Future infra** → Terraform

Terraform becomes the **single control plane** using tooling from HashiCorp on Azure Resource Manager.

---

## Final Takeaways (Must Remember)

✔ Terraform migration is **adoption, not rebuild**

✔ Import is your safest weapon

✔ Code must match reality

✔ Migration is incremental

✔ State = ownership

---
