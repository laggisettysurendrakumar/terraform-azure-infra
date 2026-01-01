
variable "resource_group_name" {
  type        = string
  description = "Existing Lab Resource Group"
}

variable "location" {
  type    = string
  default = "westus"
}

variable "vm_name" {
  type    = string
  default = "terraform-vm"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "VM admin password"
}
