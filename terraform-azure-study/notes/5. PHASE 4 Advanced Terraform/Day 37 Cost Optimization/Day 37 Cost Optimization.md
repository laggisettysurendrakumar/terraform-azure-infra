# 🔵 Day 37 – Cost Optimization

**(Tagging • Resource Cleanup • Destroy Strategies)**

Cost optimization in Terraform is **design-time + run-time discipline**, not a one-time task.

---

## 🧠 Why Cost Optimization Matters

In real environments:

* Unused resources quietly burn money 💸
* Test environments are forgotten
* No one knows *who owns what*

👉 Terraform gives you **control**—if you use it correctly.

---

## 1️⃣ Tagging Strategy (FOUNDATION OF COST CONTROL)

### 🔹 What Are Tags?

Tags are **key–value metadata** attached to Azure resources.

They help answer:

* Who owns this resource?
* Which environment?
* Why does it exist?
* Can it be deleted?

---

### 🔹 Mandatory Tags (Industry Standard)

| Tag Key       | Purpose           |
| ------------- | ----------------- |
| `Environment` | dev / test / prod |
| `Owner`       | Team or person    |
| `Project`     | Business project  |
| `CostCenter`  | Finance tracking  |
| `CreatedBy`   | Terraform / CI    |

---

### 🔹 Terraform Example – Standard Tags

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = "terraform-training"
    Owner       = "cloud-team"
    CreatedBy  = "terraform"
  }
}
```

Apply tags consistently:

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.environment}"
  location = var.location
  tags     = local.common_tags
}
```

✔ One definition

✔ Applied everywhere

---

### 🔹 Why Tags Reduce Cost

* Azure Cost Management groups by tags
* Easy identification of unused resources
* Enables chargeback / showback

---

## 🔍 Visual: Tagging for Cost Visibility

![Image](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/media/enable-tag-inheritance/tag-example-01.svg)

![Image](https://www.cloudbolt.io/wp-content/uploads/img1-1-1024x670-1.jpg)

![Image](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/media/enable-tag-inheritance/cost-analysis-view-tag.png)

---

## 2️⃣ Resource Cleanup (MOST IGNORED, MOST EXPENSIVE)

### 🔹 Common Cost Leaks

* Unused VMs
* Orphaned disks
* Public IPs not attached
* Old test environments
* Forgotten load balancers

👉 These **continue billing silently**.

---

## 3️⃣ Terraform-Driven Cleanup

### 🔹 Destroy Non-Prod Environments

Terraform makes cleanup **safe and predictable**.

```bash
cd environments/dev
terraform destroy
```

✔ No guessing

✔ No manual deletion

---

### 🔹 Scheduled Cleanup (Common Pattern)

* Dev/test auto-destroy at night or weekends
* Recreate when needed

This is often done via:

* CI/CD pipelines
* Scheduled jobs

---

## 🔍 Visual: Environment Lifecycle

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2Ah6QSwUeudCI8vx24AwwTYQ.png)

![Image](https://www.pynetlabs.com/wp-content/uploads/terraform-workflow-1024x257.jpeg)

![Image](https://www.treasury.act.gov.au/__data/assets/image/0006/2056803/Infrastructure-Investment-Lifecycle.png)

---

## 4️⃣ Destroy Strategies (CRITICAL SAFETY + COST)

Destroying infra **saves cost**, but must be **controlled**.

---

### 🔹 Strategy 1: Full Destroy (Non-Prod)

Best for:

* Dev
* Test
* Sandboxes

```bash
terraform destroy
```

✔ Maximum cost saving

✔ Zero idle resources

---

### 🔹 Strategy 2: Partial Destroy (Advanced)

Remove only expensive parts:

```bash
terraform destroy -target=azurerm_linux_virtual_machine.vm
```

⚠️ Use carefully
⚠️ Not recommended for beginners

---

### 🔹 Strategy 3: Prevent Destroy for Prod

Protect critical resources:

```hcl
resource "azurerm_storage_account" "prod" {
  name = "stproddata"

  lifecycle {
    prevent_destroy = true
  }
}
```

✔ Prevents accidental deletion

✔ Essential for prod data

---

## 5️⃣ Environment-Based Cost Controls

### 🔹 Different Sizes per Environment

```hcl
variable "vm_size" {
  default = {
    dev  = "Standard_B1s"
    prod = "Standard_D4s_v3"
  }
}
```

```hcl
size = var.vm_size[var.environment]
```

✔ Cheap dev

✔ Powerful prod

---

## 6️⃣ Cost Optimization via Design

### 🔹 Common Design Decisions That Save Cost

| Decision                           | Impact       |
| ---------------------------------- | ------------ |
| Right-size VMs                     | Huge savings |
| Disable public IPs when not needed | Medium       |
| Use Standard LB only when needed   | Medium       |
| Destroy test envs                  | High         |
| Tag everything                     | Foundational |

---

## 🔍 Visual: Cost-Aware Architecture

![Image](https://cdn.prod.website-files.com/62d91693928cb952bfa2a6af/66ddb9de32194f6e0ea929b7_MicrosoftAzure.png)

![Image](https://controlmonkey.io/wp-content/uploads/2025/07/11-Strategies-Terraform-AWS-Cost-Optimization-1024x512-1.webp)

![Image](https://www.missioncloud.com/hubfs/Imported_Blog_Media/63696e65ed18c1b6a3548cd6_Screen%20Shot%202022-11-07%20at%2012_43_50%20PM-3.png)

---

## 7️⃣ CI/CD + Cost Control (REAL WORLD)

### 🔹 Pipeline Guards

* Plan shows cost-impacting changes
* Approval required for prod
* Destroy jobs restricted to non-prod

Example:

```text
dev  → auto destroy allowed
prod → destroy blocked
```

---

## ❌ Common Cost Mistakes (VERY IMPORTANT)

❌ No tags

❌ Same VM size everywhere

❌ Never destroying test infra

❌ Orphaned resources

❌ No ownership clarity

---

## 🧠 Interview Questions (Day 37)

**Q: How does Terraform help with cost optimization?**
Through tagging, controlled lifecycle, and safe destroy.

**Q: Why tagging is important for cost?**
It enables cost tracking, ownership, and cleanup.

**Q: Should prod infra be destroyed?**
No—use `prevent_destroy` and approvals.

**Q: Biggest source of cloud waste?**
Unused and forgotten resources.

---

## 🎯 You Are READY When You Can

✅ Design cost-aware Terraform code

✅ Enforce tagging standards

✅ Safely destroy non-prod infra

✅ Protect prod while optimizing cost

---
