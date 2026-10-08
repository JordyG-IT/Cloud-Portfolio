resource "azurerm_virtual_network" "virtual_network_1" {
  name                = "${var.environment}-WebApp"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.network_cidr
  tags                = var.tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                = "${var.environment}-vnet_link"
  private_dns_zone_id = var.private_dns_zone_id
  virtual_network_id  = azurerm_virtual_network.virtual_network_1.id
  registration_enabled = var.registration_enabled
}
variable "tags" { type = map(string) }