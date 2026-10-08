#Variable Definitions
variable "network_cidr" {
  description = "Subnet address space"
  type        = list(string)
  default     = ["10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16", "10.3.0.0/16"]
}
variable "public_subnet_address_space" {
  description = "Subnet address space"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnet_address_space" {
  description = "Subnet address space"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "admin_ip" {
  description = "Allowed Management IP Addresses"
  type        = list(string)
  default     = [""]
}
variable "sql_admin_login" {
  description = "Sql admin login"
  type        = string
  sensitive   = true
}

variable "sql_admin_pass" {
  description = "Sql admin login"
  type        = string
  sensitive   = true
}
variable "environment" {
  description = "Which environment this is deploying to"
  type        = string
  default     = "dev"
}
/*variable "rules" {
  type = map(object({
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_ip[0]
    destination_address_prefix = azurerm_network_interface.public_NIC.private_ip_address

  }))
}
*/