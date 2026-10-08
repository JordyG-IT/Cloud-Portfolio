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

variable "sql_server_name" {
  description = "Sql servername"
  type        = string
}
variable "location" {
  description = "Location of the SQL Server"
  type        = string
}
variable "resource_group_name" {
  description = "Resource group SQL server goes in"
  type        = string
}
variable "tags" { type = map(string) }