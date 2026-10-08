variable "name" {
  description = "sql db name"
  type        = string
}

variable "server_id" {
  description = "SQL server to attach to"
  type        = string
}

  variable "tags" { type = map(string) }

  variable "sku_name" {
  description = "SQL DB SKU"
  type        = string
  default     = "GP_S_Gen5_2"
}