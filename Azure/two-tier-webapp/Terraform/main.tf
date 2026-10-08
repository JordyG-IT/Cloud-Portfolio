locals {
  env_lower = lower(var.environment)

  common_tags = {
    environment = var.environment
    Managedby   = "Terraform"
  }

  public_subnet_cidr = [var.public_subnet_address_space[0]]
}
#Commonly used for Infrastructure Components
#Datablocks to get info
data "azurerm_ssh_public_key" "ssh_store" {
  name                = "admin1ssh"
  resource_group_name = "ssh_store"
}

data "azurerm_private_dns_zone" "dns_zone_sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = "RG-DNS"
}
resource "azurerm_resource_group" "RG-App" {
  name     = "RG-${var.environment}"
  location = "Eastus2"

  tags = local.common_tags
}
#Vnet, will automatically link to private SQL zone. 
module "virtual_network_1" {
  source               = "./Modules/Vnet"
  network_cidr         = [var.network_cidr[0]]
  resource_group_name  = azurerm_resource_group.RG-App.name
  location             = azurerm_resource_group.RG-App.location
  registration_enabled = false
  private_dns_zone_id  = data.azurerm_private_dns_zone.dns_zone_sql.id
  environment          = var.environment
  tags                 = local.common_tags
}

#Subnets + NSG Mappings
module "public_subnet" {
  source               = "./Modules/Subnet"
  name                 = "public_subnet_${var.environment}"
  resource_group_name  = azurerm_resource_group.RG-App.name
  address_prefix       = local.public_subnet_cidr
  virtual_network_name = module.virtual_network_1.name
  location             = azurerm_resource_group.RG-App.location
  nsg_id               = module.nsg_public.nsg_id
}

module "private_subnet" {
  source                            = "./Modules/Subnet"
  name                              = "private_subnet_${var.environment}"
  resource_group_name               = azurerm_resource_group.RG-App.name
  address_prefix                    = [var.private_subnet_address_space[0]]
  virtual_network_name              = module.virtual_network_1.name
  location                          = azurerm_resource_group.RG-App.location
  nsg_id                            = module.nsg_private.nsg_id
  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}

#NSG
module "nsg_public" {
  source                      = "./Modules/NSG"
  resource_group_name         = azurerm_resource_group.RG-App.name
  network_security_group_name = "public_nsg_${var.environment}"
  location                    = azurerm_resource_group.RG-App.location
  admin_ips                   = var.admin_ip
  nsg_type                    = "public"
  tags                        = local.common_tags
}
module "nsg_private" {
  source                      = "./Modules/NSG"
  resource_group_name         = azurerm_resource_group.RG-App.name
  network_security_group_name = "private_nsg_${var.environment}"
  location                    = azurerm_resource_group.RG-App.location
  admin_ips                   = var.admin_ip
  nsg_type                    = "private"
  public_subnet_address_space = local.public_subnet_cidr
  tags                        = local.common_tags
  sql_source_asg_id           = [azurerm_application_security_group.asg-sql-dev.id]
}
#App Security Groups
resource "azurerm_application_security_group" "asg-sql-dev" {
  name                = "asg-sql-${var.environment}"
  location            = azurerm_resource_group.RG-App.location
  resource_group_name = azurerm_resource_group.RG-App.name
  tags                = local.common_tags
}

#App Sec Association
resource "azurerm_network_interface_application_security_group_association" "asg-association-sql-dev" {
  network_interface_id          = azurerm_network_interface.public_nic.id
  application_security_group_id = azurerm_application_security_group.asg-sql-dev.id
}
#Public IPs

resource "azurerm_network_interface" "public_nic" {
  name                = "${var.environment}_nic"
  location            = azurerm_resource_group.RG-App.location
  resource_group_name = azurerm_resource_group.RG-App.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "${var.environment}_public_nic"
    subnet_id                     = module.public_subnet.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.WebApp_PublicIP.id
  }
}
# NICS

resource "azurerm_public_ip" "WebApp_PublicIP" {
  name                = "${var.environment}_WebApp_PublicIP"
  resource_group_name = azurerm_resource_group.RG-App.name
  location            = azurerm_resource_group.RG-App.location
  allocation_method   = "Static"
  sku_tier            = "Regional"

  tags = local.common_tags
}

#Private Endpoint
module "private_endpoint" {
  source = "./Modules/PrivateEndpoint"

  # References to other resources/modules
  resource_group_name = azurerm_resource_group.RG-App.name
  location            = azurerm_resource_group.RG-App.location
  target_resource_id  = module.sql_server.sql_server_id
  subnet_id           = module.private_subnet.subnet_id
  private_dns_zone_id = data.azurerm_private_dns_zone.dns_zone_sql.id

  # Naming choices
  endpoint_name           = "sql_private_endpoint_${local.env_lower}"
  service_connection_name = "sql-privateserviceconnection"
  dns_zone_group_name     = "sql-dns-zone-group"
  subresource_name        = "sqlServer"

  #tags
  tags = local.common_tags
}

#SQL Server and Db
module "sql_server" {
  source              = "./Modules/SQL-Server"
  resource_group_name = azurerm_resource_group.RG-App.name
  location            = "westus2"
  sql_server_name     = "sql-${local.env_lower}-wus2-37361"
  sql_admin_login     = var.sql_admin_login
  sql_admin_pass      = var.sql_admin_pass
  tags                = local.common_tags
}
module "sql_db" {
  source    = "./Modules/SQL-Database"
  name      = "sqldb-webapp-${local.env_lower}"
  server_id = module.sql_server.sql_server_id
  tags      = local.common_tags
}

#Compute
module "virtual_machine" {
  source                = "./Modules/Virtual_Machine"
  resource_group_name   = azurerm_resource_group.RG-App.name
  name                  = "vm1-${var.environment}"
  location              = azurerm_resource_group.RG-App.location
  vm_size               = "Standard_D2s_v3"
  network_interface_ids = [azurerm_network_interface.public_nic.id]
  admin_ssh_key         = data.azurerm_ssh_public_key.ssh_store.public_key
  tags                  = local.common_tags
}
