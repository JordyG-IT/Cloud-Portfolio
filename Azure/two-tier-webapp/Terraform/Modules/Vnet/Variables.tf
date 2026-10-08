variable "network_cidr" {
  description = "Address space for the VNet"
  type        = list(string)
}

variable "environment" {
  description = "Which environment this is deploying to"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Which resource this is deploying to"
  type        = string
}

variable "location" {
  description = "Which region is this is deploying to"
  type        = string
}
variable "registration_enabled" {
  description = "DNS_Autoregistration_Enabled"
  type        = bool
}
variable "private_dns_zone_id" {
  description = "dns_zone_id, pass from data import"
  type        = string
}