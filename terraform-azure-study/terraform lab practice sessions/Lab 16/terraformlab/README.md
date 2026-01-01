# Terraform Challenge: Deploying a Virtual Machine in Azure

## 📌 Overview

This project demonstrates how to deploy an **Azure Linux Virtual Machine** using **Terraform**, following the principle **“Everything as Code”**.
The infrastructure is fully defined using Terraform configuration files and uses an **Azure Storage Account as a remote backend** for state management.

The solution meets all challenge validation requirements, including VM size, OS type, disk size, region, and Terraform best practices.

---

## 🎯 Challenge Objectives

The goal of this challenge is to:

* Deploy an **Azure Linux Virtual Machine**
* Use **Terraform variables** for reusability
* Store Terraform state in an **Azure Remote Backend**
* Follow enterprise-grade **IaC (Infrastructure as Code)** practices

---

## ✅ Validation Requirements Covered

| Requirement                | Status |
| -------------------------- | ------ |
| VM Size: `Standard_B1s`    | ✅      |
| OS: Ubuntu Linux           | ✅      |
| OS Disk ≤ 30 GB            | ✅      |
| Region: West US            | ✅      |
| Terraform Variables Used   | ✅      |
| Azure Remote State Backend | ✅      |

---

## 🧱 Architecture Components

The Terraform configuration provisions the following Azure resources:

* Existing **Resource Group** (data source)
* Virtual Network (VNet)
* Subnet
* Network Interface (NIC)
* Linux Virtual Machine (Ubuntu 20.04)

---

## 📂 Project Structure

```
terraformlab/
├── main.tf
├── variables.tf
├── terraform.tfvars
└── README.md
```

---

## 🔧 Technologies Used

* **Terraform** v1.x
* **AzureRM Provider** v2.40.0
* **Microsoft Azure**
* **Azure Storage Account** (Remote State Backend)

---

## ⚙️ Terraform Backend Configuration

Terraform state is stored remotely using an **Azure Storage Account**, ensuring:

* State consistency
* Team collaboration readiness
* Safe state locking

Backend configuration includes:

* Resource Group
* Storage Account
* Blob Container
* State file key
* Azure AD authentication

---

## 🔐 Authentication

* Azure authentication is handled using **Azure CLI (`az login`)**
* Remote backend uses **Azure AD authentication**
* VM access is configured using **password authentication** (for lab simplicity)

---

## 🚀 How to Deploy

### 1️⃣ Login to Azure

```bash
az login
```

---

### 2️⃣ Initialize Terraform

```bash
terraform init -reconfigure
```

---

### 3️⃣ Review the Plan

```bash
terraform plan
```

---

### 4️⃣ Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted.

---

## 🖥️ Virtual Machine Details

| Property       | Value               |
| -------------- | ------------------- |
| VM Size        | Standard_B1s        |
| OS             | Ubuntu 20.04 LTS    |
| Disk Size      | 30 GB               |
| Authentication | Username & Password |
| Region         | West US             |

---

## 🧹 Cleanup (Optional)

To remove all deployed resources:

```bash
terraform destroy
```

---

## 🧠 Key Learnings

* How to deploy Azure infrastructure using Terraform
* How to configure and use **Azure Remote State**
* Importance of Terraform variables for reusable code
* Handling Azure Marketplace image availability issues
* Debugging common Terraform & Azure errors

---

## 🏁 Conclusion

This challenge demonstrates a **production-aligned Terraform workflow** while keeping the configuration simple and readable.
It adheres to all validation rules and follows best practices expected from a **Cloud / DevOps Engineer**.

---

✅ **Challenge Status: Successfully Completed**
