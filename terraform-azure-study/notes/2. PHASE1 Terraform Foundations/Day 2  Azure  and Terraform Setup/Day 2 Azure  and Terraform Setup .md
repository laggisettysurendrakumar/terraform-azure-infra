# **Day 2 – Azure + Terraform Setup**

🎯 **Goal of Day-2**
By the end of this day, you will:

* Install Terraform & Azure CLI
* Create an Azure Service Principal
* Authenticate Terraform with Azure securely

---

## **1️⃣ Install Terraform**

### 📌 What is Terraform?

Terraform is a CLI tool used to **provision and manage infrastructure as code**.

---

### 🔹 Step 1: Download Terraform

👉 Download from official site:
[https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)

Choose based on OS:

* **Windows** → `.zip`
* **Linux** → `.zip`
* **macOS** → `.zip`

---

### 🔹 Step 2: Install Terraform

#### **Windows**

1. Extract the `.zip` file
2. Copy `terraform.exe`
3. Paste into:

   ```
   C:\Program Files\Terraform\
   ```
4. Add this path to **Environment Variables → PATH**

---

#### **Linux / macOS**

```bash
unzip terraform_*.zip
sudo mv terraform /usr/local/bin/
```

---

### 🔹 Step 3: Verify Installation

```bash
terraform -version
```

✅ Output should show Terraform version.

---

### 📝 Notes (OneNote Tip)

> Terraform is **not cloud-specific**. Cloud access is handled via providers (Azure, AWS, etc.).

---

## **2️⃣ Install Azure CLI**

### 📌 What is Azure CLI?

Azure CLI (`az`) allows you to:

* Login to Azure
* Create service principals
* Manage Azure resources via command line

---

### 🔹 Install Azure CLI

👉 Official docs:
[https://learn.microsoft.com/cli/azure/install-azure-cli](https://learn.microsoft.com/cli/azure/install-azure-cli)

---

#### **Windows**

* Download and install `.msi` file

#### **Linux**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

#### **macOS**

```bash
brew install azure-cli
```

---

### 🔹 Verify Installation

```bash
az version
```

---

## **3️⃣ Login to Azure**

```bash
az login
```

* Browser will open
* Login using your Azure account
* Subscription details will be displayed

---

### 🔹 Set Default Subscription (Important)

```bash
az account list --output table
az account set --subscription "<SUBSCRIPTION_ID>"
```

---

### 📝 Notes

> Always confirm the correct subscription before creating resources.

---

## **4️⃣ Create Azure Service Principal**

### 📌 What is a Service Principal?

A **Service Principal (SP)** is like a **non-human user** that Terraform uses to authenticate with Azure.

✅ Secure
✅ CI/CD friendly
✅ No interactive login required

---

### 🔹 Step 1: Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "terraform-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/<SUBSCRIPTION_ID>"
```

---

### 🔹 Step 2: Save Output Securely

You will get output like this:

```json
{
  "appId": "xxxx-xxxx-xxxx",
  "displayName": "terraform-sp",
  "password": "xxxx-xxxx",
  "tenant": "xxxx-xxxx"
}
```

📌 **Save these values** — you will need them.

---

### 🔐 Values Meaning

| Field          | Used As         |
| -------------- | --------------- |
| appId          | client_id       |
| password       | client_secret   |
| tenant         | tenant_id       |
| subscriptionId | subscription_id |

---

## **5️⃣ Authenticate Terraform with Azure**

Terraform needs **4 values** to authenticate:

* Subscription ID
* Client ID
* Client Secret
* Tenant ID

---

### 🔹 Option 1 (Recommended): Environment Variables ✅

#### **Windows (PowerShell)**

```powershell
$env:ARM_SUBSCRIPTION_ID="xxxx"
$env:ARM_CLIENT_ID="xxxx"
$env:ARM_CLIENT_SECRET="xxxx"
$env:ARM_TENANT_ID="xxxx"
```

---

#### **Linux / macOS**

```bash
export ARM_SUBSCRIPTION_ID="xxxx"
export ARM_CLIENT_ID="xxxx"
export ARM_CLIENT_SECRET="xxxx"
export ARM_TENANT_ID="xxxx"
```

---

### 🔹 Option 2: Provider Block (Not recommended for prod)

```hcl
provider "azurerm" {
  features {}

  subscription_id = "xxxx"
  client_id       = "xxxx"
  client_secret   = "xxxx"
  tenant_id       = "xxxx"
}
```

⚠️ **Never commit secrets to GitHub**

---

## **6️⃣ Validate Terraform + Azure Setup**

### 🔹 Create Test File

Create `main.tf`:

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-terraform-day2"
  location = "Central India"
}
```

---

### 🔹 Run Terraform Commands

```bash
terraform init
terraform plan
terraform apply
```

✅ If resource group is created → setup is successful 🎉

---

## **Day-2 Summary**


✔ Terraform installed

✔ Azure CLI installed

✔ Azure authenticated

✔ Service Principal created

✔ Terraform connected to Azure


---
