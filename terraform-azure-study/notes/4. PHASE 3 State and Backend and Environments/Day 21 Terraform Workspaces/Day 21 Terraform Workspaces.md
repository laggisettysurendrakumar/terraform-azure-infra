# 🟡 Day 21 – Terraform Workspaces

**(Dev / Test / Prod • Limitations • Best Practices)**

Terraform workspaces allow **multiple states from the same codebase**.
They help manage **environments**, but **only when used correctly**.

---

## 🧠 What Is a Terraform Workspace?

A **workspace** is:

* A **separate Terraform state**
* Using the **same configuration**
* With a different **state file**

👉 **Same code, different state**

---

## 🧠 Default Workspace

Terraform always starts with:

```text
default
```

This is just another workspace, **not special**, except:

* Many teams **avoid using it in production**

---

## 1️⃣ Why Workspaces Exist

### 🔹 Problem Without Workspaces

```text
One codebase
One state file
Multiple environments
```

❌ Dev can destroy Prod

❌ Accidental changes

❌ Unsafe collaboration

---

### 🔹 With Workspaces

```text
Same code
Different workspaces
Different state files
```

✔ Safe isolation

✔ Faster setup

✔ Less duplication

---

## 2️⃣ Workspace Commands (MUST KNOW)

### 🔹 List Workspaces

```bash
terraform workspace list
```

---

### 🔹 Create Workspaces

```bash
terraform workspace new dev
terraform workspace new test
terraform workspace new prod
```

---

### 🔹 Switch Workspace

```bash
terraform workspace select dev
```

---

### 🔹 Show Current Workspace

```bash
terraform workspace show
```

---

## 3️⃣ How Workspaces Store State (IMPORTANT)

When using **Azure remote backend**:

```text
tfstate/
├── terraform.tfstate        (default)
├── terraform.tfstate.d/dev
├── terraform.tfstate.d/test
└── terraform.tfstate.d/prod
```

Each workspace = **separate state**

---

## 4️⃣ Using Workspaces in Terraform Code

Terraform exposes the current workspace via:

```hcl
terraform.workspace
```

---

### 🔹 Example: Environment-Based Naming

```hcl
name = "vm-${terraform.workspace}"
```

Results:

* dev → `vm-dev`
* prod → `vm-prod`

---

### 🔹 Example: Environment-Based VM Size

```hcl
size = terraform.workspace == "prod"
  ? "Standard_D2s_v3"
  : "Standard_B2s"
```

✔ One resource

✔ Different behavior

---

## 5️⃣ Real Dev / Test / Prod Example

```hcl
locals {
  env = terraform.workspace
}

resource "azurerm_linux_virtual_machine" "vm" {
  name = "vm-${local.env}"
  size = local.env == "prod" ? "Standard_D2s_v3" : "Standard_B2s"
}
```

---

## 🔍 Visual: How Workspaces Work

![Image](https://k21academy.com/wp-content/uploads/2023/07/TF-WorkSpace-1024x487.webp)

![Image](https://miro.medium.com/1%2AKzo9WDoQAcb8PZDQisKjlw.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AJZV49LQUvk73CYqwcsqMGA.png)

---

## 6️⃣ Workspace + Remote Backend (BEST PRACTICE)

Workspaces are **safe only when used with remote state**.

✔ Azure Blob Storage

✔ State locking

✔ RBAC

❌ Local backend + workspaces (risky)

---

## 7️⃣ Workspace Limitations (VERY IMPORTANT)

### 🚨 Limitation 1: Same Code for All Environments

You **cannot** have:

* Different resources per env easily
* Major structural differences

Workspaces are best for:
✔ Small differences (size, count, tags)

---

### 🚨 Limitation 2: Hard to See Infra at a Glance

You must:

* Switch workspace
* Run `terraform plan`

❌ No single view of all environments

---

### 🚨 Limitation 3: Risky for Large Teams

* Easy to run `apply` in wrong workspace
* Human error risk

👉 This is why **many enterprises avoid workspaces for prod**

---

## 8️⃣ When to Use Workspaces (AND WHEN NOT)

### ✅ Use Workspaces When:

✔ Same infra shape

✔ Minor differences

✔ Small teams

✔ Non-critical environments

Examples:

* Dev / Test
* Sandboxes
* PoCs

---

### ❌ Avoid Workspaces When:

❌ Large enterprise environments

❌ Prod vs Non-prod separation

❌ Different infra per env

❌ Strong compliance required

---

## 9️⃣ Better Alternative (Preview)

Most enterprises prefer:

```text
environments/
├── dev/
├── test/
└── prod/
```

Each with:

* Separate backend
* Separate variables
* Clear ownership

👉 **Covered in Day 22**

---

## ❌ Common Workspace Mistakes

❌ Using `default` for prod

❌ Forgetting to check active workspace

❌ Mixing workspace + tfvars poorly

❌ Using workspaces for very different infra

---

## 🧠 Interview Questions (Day 21)

**Q: What is a Terraform workspace?**
Separate state under the same code.

**Q: Does workspace mean separate code?**
❌ No, only separate state.

**Q: Can workspaces replace environments folder?**
❌ Not for large systems.

**Q: Best practice for prod?**
Use separate backends & folders.

---

## 🎯 You Are READY When You Can

✅ Create & switch workspaces confidently

✅ Use `terraform.workspace` correctly

✅ Explain workspace limitations clearly

✅ Decide when NOT to use workspaces

---

