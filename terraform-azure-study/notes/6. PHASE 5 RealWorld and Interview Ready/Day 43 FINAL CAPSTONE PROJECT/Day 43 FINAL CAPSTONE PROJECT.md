# 🏆 Day 43 – FINAL CAPSTONE PROJECT (DEEP DIVE)


Since this is the **MAJOR capstone project of the course**, below is a **very detailed, step-by-step, enterprise-grade implementation** that covers:

✅ **Azure Infrastructure (Terraform)**

✅ **ASP.NET Core Microservice Development**

✅ **Secure Secrets with Key Vault**

✅ **VM Scale Set + Load Balancer hosting**

✅ **CI/CD for Infra + App**

✅ **Real-world architecture reasoning**


## 📌 Project Title

**Enterprise Azure Microservices Platform using Terraform & ASP.NET Core**

---

## 🧠 What You Are Building (End Result)

A **production-grade ASP.NET Core microservice** deployed on **Azure VM Scale Set**, fronted by a **Load Balancer**, fully managed using **Terraform**, secured with **Key Vault**, and deployed via **CI/CD pipelines**.

---

## 1️⃣ High-Level Architecture (Mental Model)

```
User
 ↓
Azure Load Balancer (Public)
 ↓
VM Scale Set (ASP.NET Core Microservice)
 ↓
Private Subnet
 ↓
Azure Key Vault (Secrets)
 ↓
Azure Storage (Terraform Remote State)
```

This is how **real enterprises host backend services**.

![Image](https://miro.medium.com/0%2Au81MIp4malseGRFk)

![Image](https://azure.microsoft.com/en-us/blog/wp-content/uploads/2022/07/51685553-5faa-4be1-a347-c13da55dd322.webp)

---

## 2️⃣ Infrastructure Design – WHY Each Component Exists

| Component     | Why It Exists         |
| ------------- | --------------------- |
| VNet          | Network isolation     |
| Subnets       | Security & separation |
| Load Balancer | High availability     |
| VM Scale Set  | Auto-scaling          |
| Key Vault     | Secure secrets        |
| Remote State  | Team safety           |
| CI/CD         | Governance            |

---

## 3️⃣ Terraform Project Structure (FINAL FORM)

```
terraform-azure-capstone/
├── modules/
│   ├── network/
│   ├── loadbalancer/
│   ├── compute-vmss/
│   └── keyvault/
│
├── envs/
│   ├── dev/
│   └── prod/
│
├── backend.tf
├── providers.tf
├── variables.tf
└── outputs.tf
```

✔ Used by **Platform Teams**

✔ Easy to extend

✔ Enterprise compliant

---

## 4️⃣ STEP 1: Remote State (Mandatory Foundation)

### Why?

* Prevents corruption
* Enables collaboration
* Enables locking

### Terraform Backend

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatecapstone01"
    container_name       = "prod"
    key                  = "infra.tfstate"
  }
}
```

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2Aq2enyfjQ5Y_qYER6hhA6IA.png)

![Image](https://iamachs.com/images/posts/azure-terraform/part-4/terraform-state-workflow.jpg)

---

## 5️⃣ STEP 2: VNet & Subnet Design (Networking Layer)

### Address Plan

```
VNet: 10.0.0.0/16
 ├── public-subnet (10.0.1.0/24)
 ├── private-subnet (10.0.2.0/24)
 └── management-subnet (10.0.3.0/24)
```

### Subnet Terraform Code

```hcl
resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
```

![Image](https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/_images/hub-spoke.png)

![Image](https://learn.microsoft.com/en-us/azure/well-architected/service-guides/_images/v-net.png)

---

## 6️⃣ STEP 3: Azure Load Balancer (Traffic Gateway)

### Components

* Public IP
* Frontend config
* Backend pool
* Health probe
* Rule (HTTP 80)

```hcl
resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = "Http"
  port            = 80
  request_path    = "/health"
}
```

✔ Health-based routing

✔ Zero downtime

---

## 7️⃣ STEP 4: VM SCALE SET (CORE COMPUTE)

### Why VMSS?

* Auto-scaling
* Fault tolerance
* Rolling updates

### VMSS Terraform Snippet

```hcl
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "aspnet-vmss"
  instances           = 2
  sku                 = "Standard_DS2_v2"
  admin_username      = "azureuser"

  network_interface {
    primary = true
    ip_configuration {
      subnet_id = var.private_subnet_id
      load_balancer_backend_address_pool_ids = [
        var.lb_backend_pool_id
      ]
    }
  }
}
```

![Image](https://k21academy.com/wp-content/uploads/2020/09/VM-Scale-set-e1603966905633-1024x410.png)

![Image](https://www.cloudnativedeepdive.com/content/images/size/w960/2025/02/vnss.svg)

---

## 8️⃣ STEP 5: Azure Key Vault (Security Layer)

### Why Key Vault?

❌ No secrets in Git

❌ No secrets in Terraform state

```hcl
resource "azurerm_key_vault_secret" "db_password" {
  name         = "DbPassword"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.kv.id
}
```

✔ Accessed using **Managed Identity**

![Image](https://learn.microsoft.com/en-us/azure/app-service/media/tutorial-connect-msi-key-vault/architecture.png)

![Image](https://learn.microsoft.com/en-us/azure/application-gateway/media/key-vault-certs/ag-kv.png)

---

# 🚀 APPLICATION DEVELOPMENT (ASP.NET CORE MICROSERVICE)

---

## 9️⃣ ASP.NET Core Microservice – Overview

### Tech Stack

* **ASP.NET Core**
* REST API
* Health endpoint
* Environment-based config

### Example Use Case

**Product Service**

* `/api/products`
* `/health`

---

## 🔟 Create ASP.NET Core Microservice

```bash
dotnet new webapi -n ProductService
cd ProductService
dotnet run
```

---

## 1️⃣1️⃣ Controller Example

```csharp
[ApiController]
[Route("api/products")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new[] {
            new { Id = 1, Name = "Laptop" },
            new { Id = 2, Name = "Phone" }
        });
    }
}
```

---

## 1️⃣2️⃣ Health Endpoint (CRITICAL)

```csharp
app.MapGet("/health", () => Results.Ok("Healthy"));
```

✔ Used by Load Balancer probe

✔ Mandatory in production

---

## 1️⃣3️⃣ Read Secrets from Azure Key Vault

```csharp
builder.Configuration.AddAzureKeyVault(
    new Uri("https://capstonekv01.vault.azure.net/"),
    new DefaultAzureCredential());
```

✔ No passwords in code

✔ Enterprise security

---

## 1️⃣4️⃣ Dockerize the Microservice

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /app
COPY . .
ENTRYPOINT ["dotnet", "ProductService.dll"]
```

---

## 1️⃣5️⃣ VMSS Startup Script (Cloud-Init)

```bash
#!/bin/bash
docker run -d -p 80:80 productservice:latest
```

✔ Auto-deploys on every VM

✔ Scales automatically

![Image](https://labresources.whizlabs.com/391a18a3eebf32fc6e566ec5de369a58/cse.png)

![Image](https://miro.medium.com/0%2Au81MIp4malseGRFk)

---

## 1️⃣6️⃣ CI/CD – INFRA + APP PIPELINES

### Infra Pipeline

```
terraform init
terraform validate
terraform plan
terraform apply
```

### App Pipeline

```
dotnet build
docker build
docker push
vmss rolling upgrade
```

![Image](https://media.licdn.com/dms/image/v2/D4D12AQH0XtuZXrBC3g/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1688963664295?e=2147483647\&t=hHKsZQtKceA4TjVXy3_rMjzsNjH5Zhj7zXBsD9PJ7gk\&v=beta)

![Image](https://amanagrawal.blog/wp-content/uploads/2018/12/CI-CD.png)

---

## 1️⃣7️⃣ Scaling Scenario (REAL WORLD)

### Traffic spike?

* Load Balancer distributes load
* VMSS auto-scales to 5 instances
* No downtime

### Terraform Change

```hcl
instances = 5
```

✔ Predictable

✔ Controlled

✔ Auditable

---

## 1️⃣8️⃣ Failure Handling (From Day 42)

| Issue         | Solution       |
| ------------- | -------------- |
| VM crash      | VMSS replaces  |
| App bug       | CI rollback    |
| Drift         | terraform plan |
| Partial apply | Re-run         |

---

## 1️⃣9️⃣ Interview Explanation (Say This)

> “I designed and implemented an enterprise Azure microservices platform using Terraform with remote state, modular architecture, VM Scale Sets behind a Load Balancer, secrets secured using Key Vault, and CI/CD-driven deployments. I also built an ASP.NET Core microservice deployed on VMSS with health probes and autoscaling.”

---

## 🏁 FINAL OUTCOME

✔ Enterprise-grade Terraform

✔ Secure Azure architecture

✔ Real microservice deployment

✔ CI/CD-driven infra & app

✔ Interview-ready capstone

---
