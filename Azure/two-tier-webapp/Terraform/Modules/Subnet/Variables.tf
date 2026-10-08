variable "name" {
  type = string
}

variable "address_prefix" {
  type = list(string)
}
variable "resource_group_name" {
  type = string
}
variable "virtual_network_name" {
  type = string
}
variable "location" {
  type = string
}
variable "nsg_id" {
  type = string
}

variable "private_endpoint_network_policies" {
  type = string
  default = "Disabled"
  validation {
      condition = contains(["Enabled","Disabled","NetworkSecurityGroupEnabled","RouteTableEnabled" ],var.private_endpoint_network_policies)
      error_message = " Must contain Enabled, Disabled, NetworkSecurityGroupEnabled, RouteTableEnabled."
    }
}