variable "name" {
 type = string 
}
variable "location" {
 type = string 
}
variable "resource_group_name" {
 type = string 
}
variable "network_interface_ids" {
 type = list(string)
}

variable "vm_size"{
    type        = string
    description = "VM size tier, available size are: Standard_B2s , Standard_D2s_v3 "

    validation {
    condition     = contains(["Standard_B2s", "Standard_D2s_v3"], var.vm_size)
    error_message = "vm_type must be one of: Standard_B2s, Standard_D2s_v3"
  }
}
variable "admin_ssh_key" {
 type = string
}
variable "tags" { type = map(string) }