# 🔵 Day 30 – Module Versioning

**(Reusability • Git-Based Modules • Version Control Strategy)**

Module versioning is what prevents this nightmare:

> ❌ “We updated a module and broke production everywhere.”

---

## 🧠 Why Module Versioning Is CRITICAL

Without versioning:

* A small change breaks all environments
* No rollback path
* Teams fear refactoring

With versioning:

✔ Safe upgrades

✔ Controlled rollouts

✔ Easy rollback

✔ Team confidence

👉 **Enterprise Terraform = Modules + Versioning**

---

## 1️⃣ What Is Module Reusability?

A reusable module:

* Works across **dev / test / prod**
* Has **no hardcoded values**
* Is consumed by **multiple projects**
* Evolves without breaking users

---

### 🔹 Bad (Non-Reusable Module)

```hcl
resource_group_name = "rg-dev"
location            = "East US"
```

❌ Tied to one environment

---

### ✅ Good (Reusable Module)

```hcl
variable "resource_group_name" {}
variable "location" {}
```

✔ Environment-agnostic

✔ Safe reuse

---

## 2️⃣ How Terraform Loads Modules

Terraform supports modules from:

* Local paths
* Git repositories
* Terraform Registry

Today’s focus: **Git-based modules**

---

## 3️⃣ Git-Based Modules (REAL-WORLD STANDARD)

### 🔹 Why Git?

* Version control
* Tags & releases
* Rollback
* Collaboration

👉 Most companies store modules in **GitHub / Azure Repos / GitLab**

---

### 🔹 Example: Git Repo for Modules

```text
terraform-modules/
│
├── vnet/
├── vm/
└── README.md
```

Each folder = one module

---

## 4️⃣ Using a Git-Based Module (WITHOUT VERSION – BAD)

```hcl
module "vnet" {
  source = "git::https://github.com/org/terraform-modules.git//vnet"
}
```

❌ Always pulls latest

❌ Risky for prod

---

## 5️⃣ Using a Git-Based Module WITH VERSION (BEST PRACTICE)

### 🔹 Use Git Tags

```hcl
module "vnet" {
  source = "git::https://github.com/org/terraform-modules.git//vnet?ref=v1.0.0"
}
```

✔ Stable

✔ Predictable

✔ Rollback friendly

---

## 🔍 Visual: Git-Based Module Versioning

![Image](https://raftech.nl/wp-content/uploads/2023/05/terraform-automated-workflows-high-level.jpg)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AImAloMAnMekwJeD-8l9RcA.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1370/0%2Ao1aJIQCjnzCgETWo)

---

## 6️⃣ Semantic Versioning (MUST KNOW)

Terraform modules should follow **Semantic Versioning**:

```text
MAJOR.MINOR.PATCH
```

| Version | Meaning                     |
| ------- | --------------------------- |
| MAJOR   | Breaking change             |
| MINOR   | Backward-compatible feature |
| PATCH   | Bug fix                     |

---

### 🔹 Examples

| Change                | Version |
| --------------------- | ------- |
| Fix typo              | 1.0.1   |
| Add optional variable | 1.1.0   |
| Rename variable       | 2.0.0   |

---

### 🔹 Why This Matters

* Consumers know risk level
* CI/CD can auto-approve patch updates
* Prod upgrades are controlled

---

## 7️⃣ Real Upgrade Workflow (ENTERPRISE)

### 🔹 Step 1: Release New Version

```bash
git tag v1.1.0
git push origin v1.1.0
```

---

### 🔹 Step 2: Upgrade in Dev

```hcl
source = "git::https://github.com/org/terraform-modules.git//vm?ref=v1.1.0"
```

```bash
terraform init -upgrade
terraform plan
terraform apply
```

---

### 🔹 Step 3: Promote to Test → Prod

✔ Validate in dev

✔ Promote gradually

✔ Avoid surprises

---

## 8️⃣ Rollback Strategy (VERY IMPORTANT)

If new version breaks:

```hcl
source = "git::https://github.com/org/terraform-modules.git//vm?ref=v1.0.0"
```

```bash
terraform init -upgrade
terraform apply
```

👉 **Instant rollback**

---

## 🔍 Visual: Module Upgrade & Rollback Flow

![Image](https://developer.hashicorp.com/_next/image?dpl=dpl_Ct3wvStEAibWr46WRAWGXmBpbfGA\&q=75\&url=https%3A%2F%2Fcontent.hashicorp.com%2Fapi%2Fassets%3Fproduct%3Dtutorials%26version%3Dmain%26asset%3Dpublic%252Fimg%252Fvalidated-patterns%252Fupgrade-and-refactor-terraform-modules%252Fmodule-upgrade.png%26width%3D787%26height%3D963\&w=1920)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AjIuhyFOU8oQq6zrVEwRqQw.png)

---

## 9️⃣ Version Pinning Best Practices

✔ Always pin module versions

✔ Never use `main` or `master`

✔ Upgrade intentionally

✔ Test before prod

✔ Document changes in README

---

## 🔟 Multiple Environments + Versions (REAL PATTERN)

```text
dev   → v1.2.0
test  → v1.1.0
prod  → v1.0.3
```

✔ Safe experimentation

✔ Stable production

---

## ❌ Common Mistakes (VERY IMPORTANT)

❌ Using unpinned Git modules

❌ Breaking module inputs without MAJOR bump

❌ No CHANGELOG

❌ Upgrading prod directly

❌ Sharing env logic inside module

---

## 🧠 Interview Questions (Day 30)

**Q: How do you version Terraform modules?**
Using Git tags with semantic versioning.

**Q: Why not use latest module version?**
Risky; may introduce breaking changes.

**Q: How do you roll back a broken module?**
Change Git ref and re-apply.

**Q: Where should modules live?**
In a separate Git repo or shared registry.

---

## 🎯 You Are READY When You Can

✅ Create reusable modules

✅ Use Git-based modules

✅ Pin versions safely

✅ Upgrade & roll back confidently

---
