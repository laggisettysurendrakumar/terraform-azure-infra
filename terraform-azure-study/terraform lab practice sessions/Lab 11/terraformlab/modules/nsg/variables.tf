variable "nsg_rule" {
    description = "OS image to deploy"
    type = list(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
  }))
}    


variable "nsgname" {
    type = string
    description = "Name of NSG"
}
variable "rgname" {
    type = string
    description = "Name of resource group"
}
variable "location" {
    type = string
    description = "Azure location of NSG environment"
    default = "westus2"
}
