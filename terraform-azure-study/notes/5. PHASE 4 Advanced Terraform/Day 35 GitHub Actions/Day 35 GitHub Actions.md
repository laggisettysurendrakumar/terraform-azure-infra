# 🔵 Day 35 – GitHub Actions (Optional)

**(CI Pipeline • PR-Based Validation for Terraform)**

GitHub Actions is widely used for:

* Open-source projects
* GitHub-centric teams
* Lightweight but powerful CI/CD

👉 For Terraform, GitHub Actions is mainly used for **CI (validation + plan)**, not blind production apply.

---

## 🧠 Big Picture: Why GitHub Actions for Terraform?

Using **GitHub** Actions allows you to:

* Validate Terraform on every PR
* Catch errors **before merge**
* Prevent dangerous infra changes
* Maintain a clean audit trail

This is **shift-left security** for IaC.

---

## 1️⃣ CI vs CD in GitHub Actions (IMPORTANT)

| Stage | Purpose           | Terraform Action              |
| ----- | ----------------- | ----------------------------- |
| CI    | Validate & review | `fmt`, `validate`, `plan`     |
| CD    | Deploy infra      | `apply` (manual / restricted) |

👉 **Best practice**

* PR → CI only
* Merge → Optional CD (with approval)

---

## 2️⃣ PR-Based Terraform Validation (CORE CONCEPT)

### 🔹 What Happens on a Pull Request?

```text
Developer opens PR
   ↓
GitHub Actions runs
   ↓
Terraform fmt
Terraform validate
Terraform plan
   ↓
Plan reviewed in PR
   ↓
PR approved or rejected
```

👉 **No infra changes happen on PRs**

---

## 🔍 Visual: PR-Based Terraform Workflow

![Image](https://skundunotes.com/wp-content/uploads/2023/07/78-image-1-1.png)

![Image](https://netmemo.github.io/post/tf-gha-nsxt-cicd/tf-gha-cicd-nsx.png)

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D420%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Feirbeslg5xo1km2rjsyj.png)

---

## 3️⃣ Authentication in GitHub Actions

### 🔹 How Terraform Authenticates to Azure

Same principles as Azure DevOps:

* Service Principal
* Environment variables
* Stored as **GitHub Secrets**

---

### 🔹 Required Secrets (Repo → Settings → Secrets)

```text
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
ARM_SUBSCRIPTION_ID
```

✔ Encrypted

✔ Masked in logs

✔ Not visible to contributors

---

## 4️⃣ Basic GitHub Actions Workflow (Terraform CI)

### 🔹 File Location

```text
.github/workflows/terraform-ci.yml
```

---

### 🔹 Terraform CI Pipeline (PR Validation)

```yaml
name: Terraform CI

on:
  pull_request:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.6.0

    - name: Terraform Init
      run: terraform init
      working-directory: environments/dev

    - name: Terraform Format
      run: terraform fmt -check
      working-directory: environments/dev

    - name: Terraform Validate
      run: terraform validate
      working-directory: environments/dev

    - name: Terraform Plan
      run: terraform plan
      working-directory: environments/dev
```

---

## 5️⃣ Why Each Step Matters (INTERVIEW GOLD)

| Step         | Why                            |
| ------------ | ------------------------------ |
| `fmt -check` | Enforces code standards        |
| `validate`   | Catches syntax & config errors |
| `plan`       | Shows real infra impact        |
| PR trigger   | Prevents unsafe merges         |

👉 This pipeline **blocks bad Terraform** from merging.

---

## 6️⃣ Showing Plan Output in PR (ADVANCED)

You can:

* Save plan output as artifact
* Comment plan summary on PR

This helps reviewers understand:

* What will be created
* What will be destroyed
* What will be modified

---

## 🔍 Visual: Plan Review in PR

![Image](https://skundunotes.com/wp-content/uploads/2023/07/78-image-1-1.png)

![Image](https://i0.wp.com/thomasthornton.cloud/wp-content/uploads/2024/01/image-3.png?fit=919%2C810\&ssl=1)

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/11/hashicorp-terraform-workflow-learn-build5nines.jpg)

---

## 7️⃣ Multi-Environment PR Strategy (REAL WORLD)

### 🔹 Common Pattern

| Branch    | Environment |
| --------- | ----------- |
| feature/* | dev         |
| main      | test        |
| release   | prod        |

PR pipeline runs:

* Dev plan for feature PRs
* Test plan for main PRs
* Prod plan for release PRs

---

### 🔹 Example Condition

```yaml
if: github.base_ref == 'main'
```

---

## 8️⃣ Why GitHub Actions Is Often CI-Only

Reasons teams avoid auto-apply in GitHub Actions:

* Less granular approvals than Azure DevOps
* Risk of accidental prod apply
* External contributors (forks)

👉 **Recommended**

* GitHub Actions → CI
* Azure DevOps / Manual → CD

---

## 9️⃣ Best Practices (PRODUCTION)

✔ Run only `plan` on PRs

✔ Never auto-apply on PR

✔ Protect `main` branch

✔ Require PR approval

✔ Pin Terraform version

✔ Use remote state

---

## ❌ Common Mistakes

❌ Running `terraform apply` on PR

❌ Storing secrets in repo

❌ No branch protection

❌ No plan visibility

❌ Using same workflow for all envs blindly

---

## 🧠 Interview Questions (Day 35)

**Q: How do you validate Terraform using GitHub Actions?**
Using PR-triggered pipelines with fmt, validate, and plan.

**Q: Should Terraform apply run on PRs?**
No. Only plan.

**Q: How are secrets handled in GitHub Actions?**
Using GitHub encrypted secrets.

**Q: GitHub Actions vs Azure DevOps for Terraform?**
GitHub Actions is great for CI; Azure DevOps is stronger for controlled CD.

---

## 🎯 You Are READY When You Can

✅ Create PR-based Terraform CI

✅ Prevent unsafe merges

✅ Secure credentials properly

✅ Explain CI strategy confidently

---
