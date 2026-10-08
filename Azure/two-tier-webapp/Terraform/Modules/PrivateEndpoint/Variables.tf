variable "endpoint_name" {
 type = string
}
variable "location" {
 type = string
}

variable "resource_group_name" {
 type = string
}
variable "subnet_id" {
 type = string

}
variable "service_connection_name" {
 type = string
}
variable "target_resource_id" {
 type = string
}
variable "subresource_name" {
 type = string
    validation {
      condition = contains(["sqlServer"],var.subresource_name)
      error_message = "The subresource name must be sqlServer"
    }
}

variable "dns_zone_group_name" {
 type = string
}
variable "private_dns_zone_id" {
 type = string
}
variable "tags" { type = map(string) }