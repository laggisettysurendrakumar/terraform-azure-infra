# Testing Terraform Code in Azure Using Terratest

Terraform is declarative, but that does **not** mean testing is unnecessary.
While Terraform will fail if a resource cannot be created, it **does not validate behavior**—such as whether an application is reachable, a condition works as expected, or outputs are correct.

**Terratest** fills this gap by allowing you to:

* Deploy real infrastructure
* Validate functionality (not just syntax)
* Automatically clean up resources

In this lab, you’ll write a **Terratest test in Go** to deploy a Terraform module and verify a web application using an **HTTP check**.

---

## 1️⃣ What Should Be Tested in Terraform?

![Image](https://www.hashicorp.com/_next/image?q=75\&url=https%3A%2F%2Fwww.datocms-assets.com%2F2885%2F1705090944-configuration_testing.png\&w=3840)

![Image](https://cloudlad.io/assets/images/2020_05_13_terratest_terraform.png)

![Image](https://www.datocms-assets.com/2885/1614617558-terraformtestingpyramid.png)

❌ What **not** to test:

* Individual Terraform arguments
* Static configuration values

✅ What **to** test:

* Conditional logic
* Variable-driven behavior
* Infrastructure functionality
* End-to-end outcomes (e.g., HTTP response)

Terratest focuses on **real behavior by deploying real infrastructure**.

---

## 2️⃣ Project Structure Overview

![Image](https://media.beehiiv.com/cdn-cgi/image/fit%3Dscale-down%2Cformat%3Dauto%2Conerror%3Dredirect%2Cquality%3D80/uploads/asset/file/a70941e1-5fb2-4a29-a70b-a671150e9298/directory_2.png?t=1730702773)

![Image](https://cdn.prod.website-files.com/67f9776b8553224cbb897cd7/685b2d5f6c5961f88b772241_1_HVEnTj7db4Hiduo5gL8b0w.webp)

![Image](https://d2908q01vomqb2.cloudfront.net/7719a1c782a1ba91c031a682a0a2f8658209adbf/2024/04/05/TF_MODULE_VALIDATION_PIPELINE_BASIC_WITH_KEY_NEW_UPDATED-2.png)

This project follows a **community-standard Terraform module layout**:

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

| Folder      | Purpose                       |
| ----------- | ----------------------------- |
| Root        | Terraform module code         |
| `examples/` | How users deploy the module   |
| `test/`     | Terratest tests written in Go |

Terratest runs the **example code**, not the module directly.

---

## 3️⃣ Creating the Terratest File

![Image](https://blog.jpalardy.com/assets/go-test-pkg-name/all-files.png)

![Image](https://opengraph.githubassets.com/514e0de5c45ad50d59d955b7bbf97fd29a76603ef147b30a7d8093216949e91f/gruntwork-io/terratest)

![Image](https://blogs.halodoc.io/content/images/2022/12/2.-test_add_func.png)

Inside the `test` folder, create a new file:

```text
webserver_test.go
```

📌 **Important**
Go test files must end with `_test.go`.
Go automatically detects and executes them during testing.

---

## 4️⃣ Importing Required Go Packages

![Image](https://cloudlad.io/assets/images/2020_05_13_terratest_terraform.png)

![Image](https://miro.medium.com/1%2AK-0ifMbtqUC4RhGyYX1rqA.png)

![Image](https://opengraph.githubassets.com/b4b3c11276d0ddef3432413ffbed2aaea880171dc198ac12055e745840e884c6/gruntwork-io/terratest)

Add the following imports:

```go
package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)
```

### What These Packages Do

| Package       | Purpose                 |
| ------------- | ----------------------- |
| `testing`     | Go test framework       |
| `terraform`   | Run Terraform commands  |
| `http-helper` | Validate HTTP endpoints |
| `fmt`, `time` | Utility functions       |

---

## 5️⃣ Defining the Test Function

![Image](https://blogs.halodoc.io/content/images/2022/12/2.-test_add_func.png)

![Image](https://blog.jpalardy.com/assets/go-test-pkg-name/all-files.png)

![Image](https://miro.medium.com/1%2AZygduhtZJ8uWFAbM79WvAg.png)

Create a test function:

```go
func TestWebServerDeployment(t *testing.T) {

}
```

📌 **Rule**
Test functions must:

* Start with `Test`
* Accept `*testing.T` as a parameter

---

## 6️⃣ Configuring Terraform Options

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AenwEui2I8rSM1dRTaeRr2g%402x.jpeg)

![Image](https://miro.medium.com/1%2AkGpAi6ka3kN1LW1W3T8CWA.png)

Inside the test function, configure Terraform:

```go
terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
	TerraformDir: "../examples/webserver",

	Vars: map[string]interface{}{
		"server_name": "test-webserver",
	},
})
```

### What This Does

* Points Terratest to example Terraform code
* Passes variables using `-var`
* Automatically retries common transient errors

---

## 7️⃣ Deploying and Cleaning Up Infrastructure

![Image](https://opengraph.githubassets.com/05cfb6157e65931c9d4452663e1f62ebdc12bb0e52ac1466920e819021f3319d/gruntwork-io/terratest/issues/511)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AenwEui2I8rSM1dRTaeRr2g%402x.jpeg)

![Image](https://media.licdn.com/dms/image/v2/D5622AQEbwd9LxfFzCQ/feedshare-shrink_800/B56ZkTx4MyHQAk-/0/1756973467358?e=2147483647\&t=dQrcsj4_oDIZ71OsK9u9n2xNNkyNHCX2MD6ficQbUIQ\&v=beta)

Add Terraform execution logic:

```go
terraform.InitAndApply(t, terraformOptions)
defer terraform.Destroy(t, terraformOptions)
```

### Why `defer` Is Important

* Cleanup **always runs**
* Resources are removed even if the test fails
* Prevents leaked cloud infrastructure

---

## 8️⃣ Validating Infrastructure Functionality

![Image](https://opengraph.githubassets.com/9d1c11227706e9e71817924a3d7414e4cf5f275d1545f709b8fe1a757e49406f/gruntwork-io/terratest/issues/768)

![Image](https://d2908q01vomqb2.cloudfront.net/7719a1c782a1ba91c031a682a0a2f8658209adbf/2024/04/05/TF_MODULE_VALIDATION_PIPELINE_BASIC_WITH_KEY_NEW_UPDATED-2.png)

![Image](https://miro.medium.com/1%2AkGpAi6ka3kN1LW1W3T8CWA.png)

Retrieve output and validate the web server:

```go
publicIP := terraform.Output(t, terraformOptions, "public_ip")

url := fmt.Sprintf("http://%s:8080", publicIP)

http_helper.HttpGetWithRetry(
	t,
	url,
	nil,
	200,
	"Welcome to Test Server",
	30,
	5*time.Second,
)
```

### What This Test Validates

* Web server is reachable
* HTTP status is `200`
* Response body contains expected content
* Retries allow time for startup delays

---

## 9️⃣ Final Test File (Complete)

![Image](https://terratest.gruntwork.io/assets/img/terratest_video_frame.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A888/1%2Afe92h06zjFwBlOTAuQVPpA.png)

![Image](https://i0.wp.com/blog.nashtechglobal.com/wp-content/uploads/2024/06/Screenshot-from-2024-06-05-14-15-48.png?fit=1345%2C784\&ssl=1)

```go
package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestWebServerDeployment(t *testing.T) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/webserver",
		Vars: map[string]interface{}{
			"server_name": "test-webserver",
		},
	})

	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	publicIP := terraform.Output(t, terraformOptions, "public_ip")

	url := fmt.Sprintf("http://%s:8080", publicIP)
	http_helper.HttpGetWithRetry(
		t,
		url,
		nil,
		200,
		"Welcome to Test Server",
		30,
		5*time.Second,
	)
}
```

---

## 🔟 Running the Test

![Image](https://miro.medium.com/1%2AZygduhtZJ8uWFAbM79WvAg.png)

![Image](https://terratest.gruntwork.io/assets/img/docs/debugging-interleaved-test-output/circleci-logs.png)

![Image](https://d2908q01vomqb2.cloudfront.net/7719a1c782a1ba91c031a682a0a2f8658209adbf/2024/04/05/TF_MODULE_VALIDATION_PIPELINE_BASIC_WITH_KEY_NEW_UPDATED-2.png)

### Authenticate with Azure

```bash
az login
```

### Download Go dependencies

```bash
cd terraformlab/test
go get -t -v
```

### Execute the test

```bash
go test -v webserver_test.go
```

Terratest will:

1. Deploy infrastructure
2. Wait for application readiness
3. Perform HTTP validation
4. Destroy all resources
5. Report test results

---

## ⚠️ Best Practices for Terratest

![Image](https://www.cloudbolt.io/wp-content/uploads/terraform-best-practicies-1024x654-1.png)

![Image](https://www.hashicorp.com/_next/image?q=75\&url=https%3A%2F%2Fwww.datocms-assets.com%2F2885%2F1705090944-configuration_testing.png\&w=3840)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AenwEui2I8rSM1dRTaeRr2g%402x.jpeg)

✔ Use a **separate Azure subscription** for tests
✔ Never run Terratest in production
✔ Integrate tests into CI pipelines
✔ Keep tests focused on behavior, not configuration

---

## ✅ Summary

In this lab, you learned how to:

* Write Terratest tests using Go
* Deploy Terraform modules during testing
* Validate infrastructure behavior using HTTP checks
* Automatically clean up resources
* Improve Terraform reliability through testing

Terratest provides **real confidence** in Terraform modules by testing what actually matters—**working infrastructure**.

