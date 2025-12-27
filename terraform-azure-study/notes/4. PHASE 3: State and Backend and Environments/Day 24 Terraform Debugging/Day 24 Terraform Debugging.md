# 🟡 Day 24 – Terraform Debugging

**(Logs • Common Errors • State Mismatch / Drift)**

Terraform debugging is about answering **one core question**:

> ❓ *Why is Terraform behaving this way?*

---

## 🧠 Why Debugging Is Critical

In real projects:

* `terraform apply` fails at 80%
* State doesn’t match Azure
* Terraform wants to destroy working resources
* CI/CD pipelines break without clear errors

👉 A good Terraform engineer **knows how to debug calmly and safely**.

---

## 1️⃣ Terraform Logs (PRIMARY DEBUG TOOL)

### 🔹 What Are Terraform Logs?

Terraform logs show:

* Provider calls
* API requests
* Internal decisions
* Errors hidden from normal output

By default: ❌ **Logs are OFF**

---

## 2️⃣ Enable Terraform Debug Logs

### 🔹 Basic Debug Logging

```bash
export TF_LOG=DEBUG
terraform plan
```

---

### 🔹 Log Levels (IMPORTANT)

| Level | Use                 |
| ----- | ------------------- |
| TRACE | Deepest, very noisy |
| DEBUG | Most useful         |
| INFO  | High-level info     |
| WARN  | Warnings            |
| ERROR | Only errors         |

👉 **Use `DEBUG` first**

---

### 🔹 Save Logs to a File (BEST PRACTICE)

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log
terraform apply
```

✔ Easy to share

✔ Easy to search

✔ CI/CD friendly

---

## 🔍 Visual: Terraform Debug Flow

![Image](https://images.prismic.io/turing/659810ae531ac2845a272984_Terraform_debugging_and_logging_techniques_11zon_e2de5ad997.webp?auto=format%2Ccompress)

![Image](https://cdn.prod.website-files.com/66180915331413723d2ca037/664487cdd17b535ec4e30511_debugging-e1621501420978.gif)

![Image](https://developer.hashicorp.com/_next/image?dpl=dpl_AfXN3fbGqAojMmK9StgVYth2DCPP\&q=75\&url=https%3A%2F%2Fcontent.hashicorp.com%2Fapi%2Fassets%3Fproduct%3Dtutorials%26version%3Dmain%26asset%3Dpublic%252Fimg%252Fterraform%252Ftroubleshooting%252Ftf-layers.png%26width%3D2400%26height%3D810\&w=3840)

---

## 3️⃣ Reading Terraform Errors (SKILL, NOT TOOL)

Terraform errors usually contain **three parts**:

```text
Error type
↳ Resource
↳ Reason
```

---

### 🔹 Example Error

```text
Error: AuthorizationFailed
```

Interpretation:

* ❌ Terraform problem? No
* ❌ Code syntax? No
* ✅ Azure permission issue

👉 Debug = **understand where the failure lives**

---

## 4️⃣ Common Terraform Errors (REAL WORLD)

---

### ❌ 1. Authentication Errors

```text
Error: AuthorizationFailed
```

**Cause**

* Wrong RBAC
* Expired secret
* Wrong subscription

**Fix**

```bash
az account show
az role assignment list --assignee <CLIENT_ID>
```

---

### ❌ 2. Provider Version Errors

```text
Error: Unsupported argument
```

**Cause**

* Old provider
* New argument used

**Fix**

```bash
terraform init -upgrade
```

---

### ❌ 3. Resource Already Exists

```text
Error: Resource already exists
```

**Cause**

* Resource created manually
* Terraform unaware

**Fix**

* Import resource

```bash
terraform import ...
```

---

### ❌ 4. Dependency Errors

```text
Error: Resource not found
```

**Cause**

* Wrong order
* Missing dependency

**Fix**

* Use correct references
* Rarely: `depends_on`

---

## 5️⃣ Terraform Plan Is Your Best Debug Tool

### 🔹 Golden Rule

> **Never run `terraform apply` without understanding `terraform plan`**

---

### 🔹 Plan Shows You

* What Terraform thinks exists
* What it wants to create/update/destroy
* Where mismatch exists

---

### 🔹 Dangerous Plan Example

```text
-/+ azurerm_linux_virtual_machine.vm
```

👉 Means:

* Destroy VM
* Recreate VM

⚠️ **STOP and investigate**

---

## 6️⃣ State Mismatch / Drift (VERY IMPORTANT)

### 🔹 What Is Drift?

**Drift = Azure reality ≠ Terraform state**

Causes:

* Manual portal changes
* Partial failures
* External automation

---

### 🔹 Drift Example

* VM size changed in portal
* Terraform still thinks old size

---

### 🔹 Detect Drift

```bash
terraform plan
```

Terraform compares:

```text
State ↔ Azure
```

---

## 🔍 Visual: State Drift Concept

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/666d1cb47b96efb34716e791_AD_4nXea93FasBUuz71-dnR4L8YRpsdDsL1tmNboinkvqFzdzB8l547Y04YDpWxpaOc8ogspABEpnoMlALX3M7t6VyUtc9XA1H_UEaYc3SWZQ__S7JVfg9lRcJMurQtZRjqG55tahJvBkikm7eAZs5y6UxI3vJc.png)

![Image](https://miro.medium.com/1%2AlmYNNT40GBPaVEL2K4zzNg.png)

---

## 7️⃣ Fixing State Mismatch (SAFE METHODS)

---

### ✅ Option 1: Accept Azure Change

If portal change is correct:

```bash
terraform apply
```

Terraform updates state.

---

### ✅ Option 2: Revert Azure Change

If portal change is wrong:

* Terraform will fix Azure automatically

---

### ❌ Option 3: Edit State Manually

🚫 **NEVER DO THIS**
(Except extreme cases with backup)

---

## 8️⃣ Debugging Using State Commands

### 🔹 Inspect State

```bash
terraform state list
```

---

### 🔹 Remove Broken Resource

```bash
terraform state rm <resource>
```

Use when:

* Resource deleted manually
* State is broken

---

## 9️⃣ CI/CD Debugging (REAL WORLD)

In pipelines:

* You don’t have terminal access
* Logs are your only help

### 🔹 Best Practices

✔ Enable `TF_LOG=INFO`

✔ Save logs as artifacts

✔ Use `terraform plan` step

✔ Fail fast on errors

---

## 10️⃣ Debugging Checklist (PRINT THIS 🧠)

Before panicking:

1. ❓ Which command failed?
2. ❓ Auth, code, provider, or Azure?
3. ❓ Check `terraform plan`
4. ❓ Check state vs Azure
5. ❓ Enable debug logs
6. ❓ Fix root cause, not symptom

---

## ❌ Common Debugging Mistakes

❌ Blindly running `apply`

❌ Ignoring plan output

❌ Editing state file

❌ Overusing `depends_on`

❌ Debugging without logs

---

## 🧠 Interview Questions (Day 24)

**Q: How do you debug Terraform issues?**
Using plan output, logs, and state inspection.

**Q: What is drift?**
Mismatch between state and real infra.

**Q: How to detect drift?**
`terraform plan`.

**Q: Should you edit state manually?**
No, except rare recovery scenarios.

---

## 🎯 You Are READY When You Can

✅ Enable and read Terraform logs

✅ Identify common error categories

✅ Detect and fix state drift safely

✅ Debug CI/CD failures confidently

---
