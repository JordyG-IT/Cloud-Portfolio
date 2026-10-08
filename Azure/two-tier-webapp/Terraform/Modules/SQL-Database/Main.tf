resource "azurerm_mssql_database" "sql_db" {
  name                        = var.name
  server_id                   = var.server_id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                 = 2
  sku_name                    = var.sku_name
  min_capacity                = "0.5"
  auto_pause_delay_in_minutes = "15"
  storage_account_type = "Local"
  tags = var.tags
}