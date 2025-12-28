location            = "eastus"
resource_group_name = "rg-terraform-labs"

vnet_address_space  = ["10.10.0.0/16"]
subnet_address_space = ["10.10.1.0/24"]

vm_name        = "tf-vm-01"
admin_username = "terraformadmin"
admin_password = "StrongPassword@123"

os_image = {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
  version   = "latest"
}
