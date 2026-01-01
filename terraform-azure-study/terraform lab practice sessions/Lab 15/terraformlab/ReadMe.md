# 📘 Testing Terraform Code in Azure with Terratest

## 📌 Overview

Terraform is declarative, but successful deployment does not guarantee that infrastructure **works as expected**.
For example, a Virtual Machine may deploy successfully, but the application hosted on it may not be reachable.

This lab demonstrates how to use **Terratest**, a Go-based testing framework, to:

* Deploy Terraform infrastructure
* Validate real infrastructure behavior
* Automatically clean up resources after testing

Terratest validates Terraform modules by deploying **real Azure infrastructure** and performing functional checks, such as HTTP requests.

---

## 🎯 Learning Objectives

By completing this lab, you will learn how to:

* Write automated tests for Terraform modules using Terratest
* Deploy Terraform infrastructure as part of a test
* Validate infrastructure functionality (HTTP response)
* Retrieve Terraform outputs programmatically
* Clean up test infrastructure automatically
* Prepare Terraform code for CI/CD pipelines

---

## 🧰 Prerequisites

Ensure the following are available:

* Azure CLI (`az`)
* Terraform
* Go (Golang)
* Terratest library
* Active Azure subscription (preferably non-production)

> ⚠️ **Important**
> Terratest should always be executed in a **separate testing subscription**, never in production.

---

## 📁 Project Structure

```
terraformlab
├── main.tf
├── variables.tf
├── outputs.tf
├── examples
│   └── webserver
│       └── main.tf
└── test
    └── webserver_test.go
```

### Folder Purpose

| Folder      | Description                        |
| ----------- | ---------------------------------- |
| Root        | Terraform module source            |
| `examples/` | Example usage of the module        |
| `test/`     | Terratest test cases written in Go |

Terratest runs the **example configuration**, not the module directly.

---

## 🧪 Testing Strategy

### What Not to Test

* Individual Terraform arguments
* Static configuration values

### What to Test

* Conditional logic
* Variable-driven behavior
* Application availability
* Infrastructure functionality

Terratest focuses on **behavioral testing**, not syntax validation.

---

## 📝 Creating the Terratest File

Inside the `test` folder, create a file named:

```
webserver_test.go
```

> Go automatically detects files ending with `_test.go` as test files.

---

## 📦 Importing Required Libraries

The test uses:

* Terraform Terratest module
* HTTP helper for endpoint validation
* Go testing framework

These dependencies are downloaded automatically during test execution.

---

## 🧠 Test Logic Overview

The test performs the following steps:

1. Configure Terraform options
2. Run `terraform init` and `terraform apply`
3. Retrieve the public IP from Terraform outputs
4. Send HTTP requests to the deployed web server
5. Validate HTTP status code and response body
6. Run `terraform destroy` automatically

---

## 🚀 Running the Test

### Step 1: Authenticate with Azure

```bash
az login
```

### Step 2: Navigate to Test Directory

```bash
cd terraformlab/test
```

### Step 3: Download Dependencies

```bash
go get -t -v
```

### Step 4: Execute the Test

```bash
go test -v webserver_test.go
```

---

## 🔄 What Happens During Test Execution

* Terraform deploys the example web server
* Terratest waits for the server to become available
* HTTP requests are retried to handle startup delays
* Response is validated (status code and body)
* All resources are destroyed after test completion
* Test results are displayed in the terminal

---

## ⚠️ Best Practices

* Use Terratest only in **test or QA subscriptions**
* Always clean up infrastructure after tests
* Keep tests focused on **outcomes**, not implementation details
* Integrate Terratest into CI pipelines for automatic validation
* Avoid testing every Terraform attribute

---

## 🔁 CI/CD Integration (Recommended)

Terratest is ideal for:

* Pull request validation
* Preventing broken Terraform changes
* Infrastructure regression testing

A typical CI pipeline runs:

```bash
go test ./test/...
```

---

## ✅ Summary

In this lab, you learned how to:

* Test Terraform modules using Terratest
* Deploy and validate Azure infrastructure programmatically
* Perform real HTTP-based functional testing
* Automatically clean up test resources
* Improve Terraform module reliability

Terratest adds **real confidence** to Terraform by validating **what matters most—working infrastructure**.

---
