## Day 42 – Troubleshooting Scenarios (Terraform at Scale)

### State Corruption | Partial Apply | Drift (Azure + Enterprise POV)

Troubleshooting is what **separates a Terraform user from a Terraform engineer**.
In real environments, failures **will happen** — your job is to **recover safely without downtime**.

---

## 1️⃣ Why Troubleshooting Matters in Terraform

In enterprise setups:

* Terraform runs via CI/CD
* Multiple teams touch infrastructure
* Manual portal changes happen
* Network/API failures occur

👉 **State + Reality mismatch is the root of most issues**

---

## 2️⃣ Understanding the Terraform Control Triangle

```
Terraform Code  ↔  Terraform State  ↔  Real Cloud Resources
```

If **any one breaks**, you face:

* Corruption
* Partial apply
* Drift

Keep this mental model — it explains 90% of problems.

---

## 3️⃣ Scenario 1: State Corruption

### What Is State Corruption?

State file (`terraform.tfstate`) becomes:

* Incomplete
* Out of sync
* Accidentally modified
* Overwritten by another apply

### Common Causes

* Manual state editing
* Interrupted `terraform apply`
* No state locking
* Shared local state

---

### Symptoms

* Terraform wants to recreate existing resources
* Errors like:

```text
Resource already exists
Invalid index
Cannot read attribute
```

---

### Immediate Safety Actions 🚨

1. ❌ STOP running `terraform apply`
2. ✔ Take state backup
3. ✔ Inspect state before fixing

```bash
terraform state pull > backup.tfstate
```

---

### Recovery Techniques

#### Option 1: Re-import Resource

```bash
terraform import azurerm_storage_account.sa <resource-id>
```

#### Option 2: Remove Broken Reference (Safe)

```bash
terraform state rm azurerm_storage_account.sa
```

➡ Then import again

#### Option 3: Restore Backup

```bash
terraform state push backup.tfstate
```

![Image](https://www.fosstechnix.com/wp-content/uploads/2025/04/Terraform-State-File-Corruption-Recovery.png)

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/666ca94313bc92617e6eb9fa_AD_4nXe-5_WQu-YNEB3tjjsejMPFliYTzRNjfX5D4sBknnJ9T-25KaQ1UAv3JsxDelee3icN2knxbdR7O6Upx--gqbvpij3hpWqgifxPez8_0ZtHflV45C1BsL3Wzs_tSLjn7WhK9JoiuY6EAd3gAtPfFU3-HaJ-.png)

---

### Prevention (Enterprise Rule)

✔ Remote backend only

✔ State locking enabled

✔ No manual state edits

✔ CI-only applies

---

## 4️⃣ Scenario 2: Partial Apply

### What Is Partial Apply?

Terraform successfully creates **some resources**, then fails.

Example:

* VNet created ✅
* Subnet created ✅
* VM creation failed ❌

Terraform **state is updated only for successful resources**.

---

### Common Causes

* API throttling
* Permission issues
* Quota limits
* Network timeout

---

### What Terraform Does

✔ Keeps successful resources in state

✔ Does NOT roll back automatically

👉 Terraform is **not transactional**

---

### How to Recover Safely

#### Step 1: Identify Failed Resource

```bash
terraform apply
```

Error shows exactly where it failed.

#### Step 2: Fix Root Cause

* Increase quota
* Fix RBAC
* Correct input values

#### Step 3: Re-run Apply

```bash
terraform apply
```

Terraform:

* Skips completed resources
* Continues from failure point

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/11/hashicorp-terraform-workflow-learn-build5nines.jpg)

![Image](https://miro.medium.com/v2/resize%3Afit%3A896/1%2AVCI4qyRnNxWm5cOxJFjRpg.png)

---

### Enterprise Best Practices

✔ Small applies (layered infra)

✔ Separate state per module

✔ CI retry logic

✔ Avoid giant monolithic applies

---

## 5️⃣ Scenario 3: Drift (Most Common in Production)

### What Is Drift?

**Real cloud resources change outside Terraform**.

Example:

* Someone edits VM size in Azure Portal
* Terraform code not updated

---

### How Drift Happens

* Emergency hotfixes
* Manual scaling
* Portal-based debugging
* Auto-scaling tools

---

### Detecting Drift

```bash
terraform plan
```

Example output:

```text
~ vm_size: "Standard_DS1" → "Standard_DS2"
```

✔ Terraform detected a mismatch

❌ Infra no longer matches code

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/666d1cb47b96efb34716e791_AD_4nXea93FasBUuz71-dnR4L8YRpsdDsL1tmNboinkvqFzdzB8l547Y04YDpWxpaOc8ogspABEpnoMlALX3M7t6VyUtc9XA1H_UEaYc3SWZQ__S7JVfg9lRcJMurQtZRjqG55tahJvBkikm7eAZs5y6UxI3vJc.png)

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/666d1cb4548164109d13a214_AD_4nXfWISQaQDc-jBqnuHxHklpoQ4pfZ1EHEHuPqR_Z1vmpryxEHnibGeOcfZK3FnL7rKHAbLvJeEnqFzt3aYoxhw7CugVyv3vA8L0WTqRz9VVKXr5KS8CKe6R4uWaz6siCXlWFTb3jtZRIOLyPtAZPLG8C_YtH.png)

---

### Handling Drift (Decision Matrix)

| Scenario                  | Action                |
| ------------------------- | --------------------- |
| Portal change was mistake | Revert via Terraform  |
| Portal change is valid    | Update Terraform code |
| Emergency fix             | Import & align later  |

---

### Ignoring Known Drift (Advanced)

```hcl
lifecycle {
  ignore_changes = [tags]
}
```

⚠ Use sparingly
⚠ Can hide real issues

---

## 6️⃣ Drift vs State Corruption (Interview Trap)

| Aspect         | Drift      | State Corruption |
| -------------- | ---------- | ---------------- |
| State readable | ✔          | ❌                |
| Plan works     | ✔          | ❌                |
| Fix method     | Align code | Repair state     |
| Severity       | Medium     | High             |

---

## 7️⃣ Real-World Enterprise Incident Example

**Incident**

* Engineer resized VM via Portal
* Next pipeline run failed approval

**Fix**

1. `terraform plan` showed drift
2. Team updated VM size in code
3. Approved apply
4. Drift resolved

✔ Zero downtime

✔ Auditable fix

---

## 8️⃣ Troubleshooting Command Cheat Sheet

```bash
terraform plan
terraform refresh
terraform state list
terraform state show <resource>
terraform import
terraform state rm
```

---

## 9️⃣ Golden Rules for Troubleshooting (Must Remember)

✔ Never panic-apply

✔ Always inspect state

✔ Plan before apply

✔ One issue at a time

✔ Fix root cause, not symptoms

---

## 🔟 Enterprise-Level Prevention Checklist

✔ Remote backend with locking

✔ CI/CD-only applies

✔ Strict RBAC

✔ No portal changes in prod

✔ Drift detection in pipelines

✔ Layered state architecture

---

## Final Takeaways (Interview-Ready)

> **State is the heart of Terraform**
> **Partial apply is expected, not failure**
> **Drift is inevitable — detection matters**

Teams that master troubleshooting **trust Terraform in production**.

---
