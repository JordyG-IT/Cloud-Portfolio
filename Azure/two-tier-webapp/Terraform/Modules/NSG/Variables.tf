variable "nsg_type" {
  type        = string
  description = "The NSG baseline to apply."

  validation {
    condition     = contains(["public", "private"], var.nsg_type)
    error_message = "nsg_type must be either public or private."
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "network_security_group_name" {
  type = string
}

variable "admin_ips" {
  type = list(string)
}
variable "tags" { type = map(string) }


variable "public_subnet_address_space" {
  type = list(string)
  default = []
}

variable "sql_source_asg_id" {
  type = list(string)
  default = null
}