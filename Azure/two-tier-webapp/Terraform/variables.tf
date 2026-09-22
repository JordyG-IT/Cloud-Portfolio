#Variable Definitions
variable "subnet_address_space" {
  description = "Subnet address space"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
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