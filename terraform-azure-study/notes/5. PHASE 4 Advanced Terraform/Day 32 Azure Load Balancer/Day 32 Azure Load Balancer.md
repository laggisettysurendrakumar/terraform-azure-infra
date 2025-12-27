# 🔵 Day 32 – Azure Load Balancer

**(Internal Load Balancer • Public Load Balancer)**

Azure Load Balancer (ALB) is a **Layer-4 (TCP/UDP)** service that distributes traffic across multiple backends to provide:

* **High availability**
* **Scalability**
* **Fault tolerance**

---

## 🧠 Big Picture: Where Azure Load Balancer Fits

* Works at **Layer 4** (IP + Port)
* Very fast and simple
* Ideal for:

  * VM-based apps
  * Databases
  * Internal services
  * High-throughput workloads

> If you need Layer-7 features (URL routing, SSL termination), that’s **Application Gateway** (covered later).

---

## 1️⃣ Core Components of Azure Load Balancer (MUST KNOW)

Every Azure Load Balancer has these building blocks:

| Component           | Purpose                                |
| ------------------- | -------------------------------------- |
| Frontend IP         | Entry point (public or private IP)     |
| Backend Pool        | Group of VMs / NICs                    |
| Health Probe        | Checks backend health                  |
| Load Balancing Rule | Maps frontend → backend                |
| Inbound NAT Rule    | Port mapping to a single VM (optional) |

---

## 2️⃣ Public Load Balancer (Internet-Facing)

### 🔹 What Is a Public Load Balancer?

* Has a **Public IP**
* Accepts traffic from the **internet**
* Distributes traffic to backend VMs

**Typical use cases**

* Web apps
* Public APIs
* Internet-facing services

---

### 🔹 Traffic Flow (Public LB)

```text
Internet
   ↓
Public IP (Load Balancer)
   ↓
LB Rule (Port 80 / 443)
   ↓
Backend Pool (VMs)
```

---

### 🔹 Terraform Example – Public Load Balancer

#### 1) Public IP

```hcl
resource "azurerm_public_ip" "lb_pip" {
  name                = "pip-public-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
```

#### 2) Load Balancer

```hcl
resource "azurerm_lb" "public_lb" {
  name                = "public-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-public"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}
```

#### 3) Backend Pool

```hcl
resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.public_lb.id
  name            = "backend-pool"
}
```

#### 4) Health Probe

```hcl
resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id = azurerm_lb.public_lb.id
  name            = "http-probe"
  protocol        = "Tcp"
  port            = 80
}
```

#### 5) Load Balancing Rule

```hcl
resource "azurerm_lb_rule" "http_rule" {
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
}
```

> Attach VMs by associating their **NICs** to the backend pool.

---

### 🔍 Visual: Public Load Balancer Architecture

![Image](https://learn.microsoft.com/en-us/azure/load-balancer/media/quickstart-load-balancer-standard-public-portal/public-load-balancer-overview.png)

![Image](https://learn-attachment.microsoft.com/api/attachments/0a804296-965a-4861-9a76-af8f073667ab?platform=QnA)

![Image](https://media.licdn.com/dms/image/v2/D5612AQGkQbj9KB-2-w/article-cover_image-shrink_600_2000/article-cover_image-shrink_600_2000/0/1711778832217?e=2147483647\&t=r1F6rsWmMyh1TeFiRzFR4HMz_VvCmCf_XNj7U5bZSD4\&v=beta)

---

## 3️⃣ Internal Load Balancer (Private / East–West)

### 🔹 What Is an Internal Load Balancer?

* Uses a **private IP**
* Accessible **only inside the VNet**
* Ideal for **internal services**

**Typical use cases**

* App → DB traffic
* Internal APIs
* Microservices
* Private tiers

---

### 🔹 Traffic Flow (Internal LB)

```text
App Tier VM
   ↓
Private IP (Internal LB)
   ↓
Backend Pool (DB / App VMs)
```

---

### 🔹 Terraform Example – Internal Load Balancer

#### 1) Internal Load Balancer

```hcl
resource "azurerm_lb" "internal_lb" {
  name                = "internal-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontend-internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
  }
}
```

#### 2) Backend Pool

```hcl
resource "azurerm_lb_backend_address_pool" "internal_backend" {
  loadbalancer_id = azurerm_lb.internal_lb.id
  name            = "internal-backend"
}
```

#### 3) Health Probe (DB example)

```hcl
resource "azurerm_lb_probe" "tcp_probe" {
  loadbalancer_id = azurerm_lb.internal_lb.id
  name            = "tcp-probe"
  protocol        = "Tcp"
  port            = 1433
}
```

---

### 🔍 Visual: Internal Load Balancer Architecture

![Image](https://learn.microsoft.com/en-us/azure/load-balancer/media/quickstart-load-balancer-standard-internal-portal/internal-load-balancer-resources.png)

![Image](https://learn-attachment.microsoft.com/api/attachments/f9fb8725-45ed-40bd-995f-893cb9eaa95d?platform=QnA)

![Image](https://www.expertnetworkconsultant.com/wp-content/uploads/2022/08/create-azure-standard-load-balancer-with-backend-pools-in-terraform.png)

---

## 4️⃣ Public vs Internal Load Balancer (INTERVIEW GOLD)

| Feature         | Public LB      | Internal LB   |
| --------------- | -------------- | ------------- |
| IP Type         | Public         | Private       |
| Internet Access | ✅ Yes          | ❌ No          |
| Use Case        | Web / API      | App / DB      |
| Security        | NSG + Firewall | NSG only      |
| Exposure        | External       | Internal only |

---

## 5️⃣ Standard vs Basic SKU (IMPORTANT)

Always use **Standard SKU**.

| Feature            | Basic   | Standard |
| ------------------ | ------- | -------- |
| Availability Zones | ❌       | ✅        |
| Secure by default  | ❌       | ✅        |
| Production ready   | ❌       | ✅        |
| Backend types      | Limited | Full     |

👉 **Basic is legacy**.

---

## 6️⃣ NSG & Load Balancer (COMMON CONFUSION)

* Load Balancer **does not replace NSG**
* NSG must allow:

  * Frontend port (80/443/etc.)
  * Health probe traffic

❌ Missing NSG rules = traffic drop

---

## 7️⃣ Common Real-World Patterns

### 🔹 Pattern 1: Internet → Web Tier

* Public LB
* Backend VMs (web)
* Ports 80/443

### 🔹 Pattern 2: Web → App → DB

* Public LB (Web)
* Internal LB (App/DB)

---

## ❌ Common Mistakes (VERY IMPORTANT)

❌ Using Basic SKU

❌ Forgetting health probes

❌ Not associating NICs to backend pool

❌ NSG blocking probe traffic

❌ Using LB for Layer-7 routing

---

## 🧠 Interview Questions (Day 32)

**Q: Difference between Public and Internal LB?**
Public is internet-facing; internal is VNet-only.

**Q: Does Azure Load Balancer work at Layer 7?**
❌ No, Layer 4 only.

**Q: Why health probes are required?**
To send traffic only to healthy backends.

**Q: Can LB replace NSG?**
❌ No.

---

## 🎯 You Are READY When You Can

✅ Explain Public vs Internal LB clearly

✅ Build both using Terraform

✅ Choose correct SKU

✅ Debug probe & NSG issues

---
