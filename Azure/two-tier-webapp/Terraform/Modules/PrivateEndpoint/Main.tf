resource "azurerm_private_endpoint" "SQL_private_endpoint" {
  name                = var.endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
#connects private endpoint to a resource (the sql server)
  private_service_connection {
    name                           = var.service_connection_name
    private_connection_resource_id = var.target_resource_id
    subresource_names              = [var.subresource_name]
    is_manual_connection           = false
  }
  #registers this endpoint's private IP as an A record inside the dns zones passed to it.
  private_dns_zone_group {
    name                 = var.dns_zone_group_name
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
  tags = var.tags
}