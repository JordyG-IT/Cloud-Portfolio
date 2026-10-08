#SQL Server and Db


resource "azurerm_mssql_server" "sql_webapp" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_pass
  public_network_access_enabled = false
  tags = var.tags
}