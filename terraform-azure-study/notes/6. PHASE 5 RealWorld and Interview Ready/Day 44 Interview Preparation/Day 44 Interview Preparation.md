## Day 44 – **Interview Preparation (Terraform + Azure – Enterprise Level)**

### Common Questions & Scenario-Based Answers (What Interviewers *Really* Test)

This day is about **how you explain**, not just what you know.
Interviewers want to see **decision-making, risk awareness, and production thinking**.

---

## 🎯 How Terraform + Azure Interviews Are Evaluated

Interviewers assess:

* **Concept clarity**
* **Real-world experience**
* **Failure handling**
* **Design trade-offs**
* **Production mindset**

> Knowing commands gets you shortlisted
> Explaining scenarios gets you selected

---

# PART 1️⃣ – COMMON INTERVIEW QUESTIONS (WITH STRONG ANSWERS)

---

## Q1️⃣ What is Terraform and why is it used in Azure?

### ❌ Weak Answer

> Terraform is an IaC tool to create Azure resources.

### ✅ Strong Answer (Say This)

> Terraform is an Infrastructure as Code tool that allows us to provision and manage Azure infrastructure in a **declarative, version-controlled, and automated way**. It enables **consistent deployments across environments**, supports **remote state with locking**, and integrates well with **CI/CD pipelines**, which is critical for enterprise governance.

---

## Q2️⃣ Terraform vs ARM / Bicep – Which one do you choose and why?

### Best Answer (Balanced)

> For **small Azure-only deployments**, ARM or Bicep is fine.
> For **enterprise-scale environments**, I prefer Terraform because it provides **explicit state management, drift detection, modular reuse, multi-environment isolation, and better CI/CD governance**.
> In real projects, platform teams often use Terraform, while app teams may still use Bicep.

![Image](https://i0.wp.com/build5nines.com/wp-content/uploads/2023/01/HashiCorp_Terraform_Provider_Deployment_Diagram.jpg?resize=1080%2C608\&ssl=1)

![Image](https://www.starwindsoftware.com/blog/wp-content/uploads/2021/12/diagram-description-automatically-generated-2.png)

---

## Q3️⃣ What is Terraform state and why is it critical?

### Strong Answer

> Terraform state is the **mapping between Terraform code and real Azure resources**. It allows Terraform to understand what already exists, detect changes, and safely apply updates.
> In enterprise environments, state must be stored remotely with **locking and encryption** to avoid corruption and concurrent access issues.

---

## Q4️⃣ What happens if the state file is deleted?

### Correct Answer

> Terraform loses track of existing infrastructure and may try to recreate resources.
> Recovery involves **re-importing resources** or restoring state from a backup.
> This is why remote backends and state versioning are mandatory in production.

---

## Q5️⃣ How do you manage multiple environments (Dev / Stage / Prod)?

### Strong Answer

> I use **separate state files and environment-specific folders or subscriptions**.
> Each environment has isolated state, credentials, and pipelines, which reduces blast radius and enforces proper access control.

---

# PART 2️⃣ – SCENARIO-BASED QUESTIONS (MOST IMPORTANT)

---

## Scenario 1️⃣ – Someone Changed a Resource in Azure Portal

### Interview Question

> A VM size was changed manually in Azure Portal. What happens next?

### Ideal Answer

> Terraform will detect **drift** during `terraform plan`.
> I will evaluate whether the portal change is valid:

* If accidental → revert using Terraform
* If required → update Terraform code and apply

> Manual portal changes are discouraged in production.

![Image](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/666d1cb47b96efb34716e791_AD_4nXea93FasBUuz71-dnR4L8YRpsdDsL1tmNboinkvqFzdzB8l547Y04YDpWxpaOc8ogspABEpnoMlALX3M7t6VyUtc9XA1H_UEaYc3SWZQ__S7JVfg9lRcJMurQtZRjqG55tahJvBkikm7eAZs5y6UxI3vJc.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AX3JgOElwu9pbXiMi)

---

## Scenario 2️⃣ – Terraform Apply Failed Halfway (Partial Apply)

### Interview Question

> Terraform failed while creating resources. What do you do?

### Correct Answer

> Terraform is **not transactional**. Resources that were successfully created are already in state.
> I identify the failed resource, fix the root cause (permissions, quota, config), and re-run `terraform apply`. Terraform continues from where it failed.

---

## Scenario 3️⃣ – State File Is Corrupted

### Interview Question

> Your pipeline fails with state errors. What’s your approach?

### Best Answer

> I immediately stop apply operations, take a **state backup**, inspect state using `terraform state list`, and recover by re-importing affected resources or restoring a previous state version.
> Prevention includes remote state, locking, and CI-only applies.

---

## Scenario 4️⃣ – Need Zero-Downtime Deployment

### Interview Question

> How do you deploy infra changes without downtime?

### Strong Answer

> I use **Load Balancer + VM Scale Set**, rolling updates, health probes, and small incremental Terraform changes.
> CI/CD approvals ensure changes are reviewed before production rollout.

![Image](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/media/upgrade-policy/rolling-upgrade.png)

![Image](https://cloudopszone.com/wp-content/uploads/2018/04/VM-scale-set.jpg)

---

## Scenario 5️⃣ – Secrets in Terraform Code?

### Interview Question

> Where do you store secrets like DB passwords?

### Perfect Answer

> Secrets should **never be stored in Terraform code or state**.
> I store secrets in **Azure Key Vault**, access them via managed identity, and reference them securely at runtime.

---

# PART 3️⃣ – ADVANCED / SENIOR-LEVEL QUESTIONS

---

## Q️⃣ How do you design Terraform for large teams?

### Senior Answer

> I design Terraform using **modular architecture**, separate state per layer, strict RBAC, pipeline-only applies, policy enforcement, and environment isolation. Terraform becomes a **platform**, not just a tool.

---

## Q️⃣ How do you prevent accidental deletes?

### Strong Answer

> I use:

* `terraform plan` with approvals
* `prevent_destroy` lifecycle where required
* Restricted permissions in prod
* Separate pipelines for prod

---

## Q️⃣ How do you migrate existing Azure resources to Terraform?

### Best Answer

> I write matching Terraform code, import existing resources using `terraform import`, validate with plan, and migrate incrementally to avoid downtime.

---

# PART 4️⃣ – QUICK COMMAND QUESTIONS

| Question      | Expected Answer                      |
| ------------- | ------------------------------------ |
| Plan vs Apply | Preview vs Execute                   |
| Refresh       | Sync state with reality              |
| Import        | Bring existing infra under Terraform |
| State rm      | Remove broken state reference        |

---

## Interview Red Flags (AVOID Saying ❌)

❌ “I usually fix things directly in Azure Portal”

❌ “I keep state locally”

❌ “We don’t use approval gates”

❌ “Terraform rollback is automatic”

---

## Golden Phrases Interviewers Love ✅

* “I follow least-privilege access”
* “We use CI/CD-only Terraform applies”
* “We isolate state per environment”
* “We handle drift via plan and governance”
* “Terraform is our source of truth”

---

## Final Interview Summary (Memorize This)

> “I use Terraform to manage Azure infrastructure in a modular, secure, and CI/CD-driven way. I focus on state safety, environment isolation, drift detection, and zero-downtime deployments. I treat Terraform as a platform, not just a scripting tool.”

---

## 🎯 You’re Interview-Ready 🎉

After Day 44, you can confidently handle:

✔ Terraform + Azure interviews

✔ Real-world scenarios

✔ Senior-level discussions

✔ Architecture questions

---
