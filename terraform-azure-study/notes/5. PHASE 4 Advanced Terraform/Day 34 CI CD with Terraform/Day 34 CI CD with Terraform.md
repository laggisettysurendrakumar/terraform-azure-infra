
# 🔵 Day 34 – CI/CD with Terraform

This day answers a **critical real-world question**:

> ❓ *How do teams run Terraform safely and automatically without logging into servers?*


**(Azure DevOps Pipeline • Terraform Plan & Apply)**

CI/CD with Terraform is what separates:

* ❌ *local experimentation*
  from
* ✅ *enterprise-grade infrastructure delivery*

---

## 🧠 Big Picture: Terraform + CI/CD

In production:

* Terraform is **never run manually**
* Everything goes through **pipelines**
* Changes are **reviewed, approved, and audited**

CI/CD ensures:

✔ Consistency

✔ Safety

✔ Audit trail

✔ Zero human error

---

## 1️⃣ Why CI/CD Is Mandatory for Terraform

### ❌ Problems with Manual Terraform

* Someone runs `terraform apply` on prod
* Wrong workspace/environment
* No approval
* No rollback trace

### ✅ CI/CD Solves This

* Code review before apply
* Plan visibility
* Environment isolation
* Controlled permissions

👉 **Terraform + CI/CD = Safe IaC**

---

## 2️⃣ Azure DevOps + Terraform (Why This Combo)

Using **Azure DevOps** gives:

* Git Repos
* Pipelines (YAML)
* Secure variable storage
* Approval gates
* RBAC integration

Perfect for Terraform workflows.

---

## 3️⃣ Standard Terraform CI/CD Workflow (MUST KNOW)

```text
Commit / PR
   ↓
Terraform Init
   ↓
Terraform Plan
   ↓
Manual Approval (Prod)
   ↓
Terraform Apply
```

👉 **Plan ≠ Apply**
They must be **separate steps**.

---

## 🔍 Visual: Terraform CI/CD Flow

![Image](https://developer.okta.com/assets-jekyll/blog/terraform-ci-cd/architecture-overview-b47c2b972b6fbb7428f620b5ffe855f07e02c41196b5a1074a766a7571f3c199.jpg)

![Image](https://media.licdn.com/dms/image/v2/D4D12AQH0XtuZXrBC3g/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1688963664295?e=2147483647\&t=hHKsZQtKceA4TjVXy3_rMjzsNjH5Zhj7zXBsD9PJ7gk\&v=beta)

![Image](https://www.devopsschool.com/blog/wp-content/uploads/2023/04/terraform-workflow-1-768x384.jpg)

---

## 4️⃣ Authentication in Pipelines (CRITICAL)

### 🔹 How Pipeline Authenticates to Azure

Best practice options:

1. **Service Principal**
2. **Managed Identity** (Azure-hosted agents)

Most common:
👉 **Service Principal + Environment Variables**

---

### 🔹 Azure DevOps Secure Variables

Store these as **pipeline secrets**:

```text
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
ARM_SUBSCRIPTION_ID
```

✔ Encrypted

✔ Masked in logs

✔ Not in code

---

## 5️⃣ Azure DevOps Pipeline – Terraform Plan

### 🔹 Basic Pipeline Structure (`azure-pipelines.yml`)

```yaml
trigger:
- main

pool:
  vmImage: ubuntu-latest

variables:
  TF_VERSION: '1.6.0'

stages:
- stage: Terraform_Plan
  displayName: Terraform Plan
  jobs:
  - job: plan
    steps:
    - task: TerraformInstaller@1
      inputs:
        terraformVersion: $(TF_VERSION)

    - script: |
        terraform init
        terraform plan
      displayName: Terraform Init & Plan
```

---

### 🔹 Why Plan Stage Is Important

* Shows **exact changes**
* Detects destructive actions
* Fails early if errors exist

👉 **Plan output is reviewed before apply**

---

## 6️⃣ Terraform Apply with Approval (PRODUCTION PATTERN)

### 🔹 Add Manual Approval

Use **environments** in Azure DevOps:

```yaml
- stage: Terraform_Apply
  dependsOn: Terraform_Plan
  condition: succeeded()
  jobs:
  - deployment: apply
    environment: prod
    strategy:
      runOnce:
        deploy:
          steps:
          - script: |
              terraform apply -auto-approve
```

---

### 🔹 What This Achieves

✔ Manual approval before prod

✔ Audit trail

✔ Safe deployments

---

## 🔍 Visual: Plan vs Apply Separation

![Image](https://devops.silvanasblog.com/assets/images/terraform_plan_and_apply_diagram-28d0a404f9793ed561f6fed8abf9ab02.png)

![Image](https://phiptech.com/content/images/2023/05/Approval-Workflow.drawio--2-.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A988/0%2Ah1EbAuPyTQj4DZBN)

---

## 7️⃣ Handling Multiple Environments (Dev / Test / Prod)

### 🔹 Folder-Based Environments

```text
environments/
├── dev/
├── test/
└── prod/
```

Pipeline passes environment path:

```yaml
- script: |
    cd environments/dev
    terraform init
    terraform plan
```

---

### 🔹 Promotion Strategy

```text
dev  → auto apply
test → auto apply
prod → manual approval
```

---

## 8️⃣ Remote State in CI/CD (MANDATORY)

Pipelines require:

* Remote backend (Azure Storage)
* State locking
* RBAC-secured access

Why?

* Multiple pipeline runs
* Parallel execution
* No local state

👉 **CI/CD + local state = disaster**

---

## 9️⃣ Best Practices (ENTERPRISE-GRADE)

✔ Separate plan & apply stages

✔ Manual approval for prod

✔ Never store secrets in Git

✔ Use remote backend

✔ Pin Terraform version

✔ Fail pipeline on `plan` errors

---

## ❌ Common CI/CD Mistakes

❌ Auto-apply to prod

❌ Same pipeline for all envs without checks

❌ Hardcoded credentials

❌ No approval gates

❌ Running Terraform from root blindly

---

## 🧠 Interview Questions (Day 34)

**Q: Why separate plan and apply in pipelines?**
To review changes and prevent accidental destruction.

**Q: How does Terraform authenticate in CI/CD?**
Using Service Principal or Managed Identity.

**Q: Should pipelines use local state?**
❌ No, always remote state.

**Q: How do you protect prod deployments?**
Manual approvals + RBAC + separate state.

---

## 🎯 You Are READY When You Can

✅ Design Terraform pipelines

✅ Implement plan & apply safely

✅ Secure credentials properly

✅ Explain CI/CD flow confidently

---
