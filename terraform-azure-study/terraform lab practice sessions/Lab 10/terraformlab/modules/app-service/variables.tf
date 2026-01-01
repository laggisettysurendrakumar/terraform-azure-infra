variable "plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "resource_group" {
  type        = string
  description = "Azure Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region for deployment (optional)"
  default     = ""
}
