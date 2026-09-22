#Commonly used for Infrastructure Components
#Datablocks to get info
data "azurerm_ssh_public_key" "ssh_store" {
  name                = "admin1ssh"
  resource_group_name = "ssh_store"
}

resource "azurerm_resource_group" "RG-Dev" {
  name     = "RG-Dev"
  location = "Eastus2"

  tags = {
    Environment = "Dev"
    Managedby   = "Terraform"
  }
}
#Vnets
resource "azurerm_virtual_network" "virtual_network_1" {
  name                = "Dev-WebApp"
  location            = azurerm_resource_group.RG-Dev.location
  resource_group_name = azurerm_resource_group.RG-Dev.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Dev"
    Managedby   = "Terraform"
  }
}
#Subnets
resource "azurerm_subnet" "dev_subnet_public" {
  name                 = "Dev_Subnet_Public"
  resource_group_name  = azurerm_resource_group.RG-Dev.name
  virtual_network_name = azurerm_virtual_network.virtual_network_1.name
  address_prefixes     = [var.subnet_address_space[0]]
}
resource "azurerm_subnet" "dev_subnet_private" {
  name                              = "Dev_Subnet_Private"
  resource_group_name               = azurerm_resource_group.RG-Dev.name
  virtual_network_name              = azurerm_virtual_network.virtual_network_1.name
  address_prefixes                  = [var.subnet_address_space[1]]
  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}
#NSG
resource "azurerm_network_security_group" "NSG-public" {
  name                = "NSG-Public"
  location            = azurerm_resource_group.RG-Dev.location
  resource_group_name = azurerm_resource_group.RG-Dev.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_ip[0]
    destination_address_prefix = azurerm_network_interface.Dev_NIC.private_ip_address
  }
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.admin_ip[0]
    destination_address_prefix = azurerm_network_interface.Dev_NIC.private_ip_address
  }
  security_rule {
    name                       = "Disallow All"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
    Managedby   = "Terraform"
  }
}
resource "azurerm_network_security_group" "NSG-private" {
  name                = "NSG-Private"
  location            = azurerm_resource_group.RG-Dev.location
  resource_group_name = azurerm_resource_group.RG-Dev.name

  security_rule {
    name                       = "AllowSQL_Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = azurerm_network_interface.Dev_NIC.private_ip_address
    destination_address_prefix = azurerm_private_endpoint.SQL_private_endpoint.private_service_connection[0].private_ip_address
  }
  security_rule {
    name                       = "DenyAll_Inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
    Managedby   = "Terraform"
  }
}
#NSG Mappings
resource "azurerm_subnet_network_security_group_association" "NSG-Public_To_dev_subnet_public" {
  subnet_id                 = azurerm_subnet.dev_subnet_public.id
  network_security_group_id = azurerm_network_security_group.NSG-public.id
}
resource "azurerm_subnet_network_security_group_association" "NSG-private_To_dev_subnet_private" {
  subnet_id                 = azurerm_subnet.dev_subnet_private.id
  network_security_group_id = azurerm_network_security_group.NSG-private.id
}
#Public IPs
resource "azurerm_network_interface" "Dev_NIC" {
  name                = "Dev_NIC"
  location            = azurerm_resource_group.RG-Dev.location
  resource_group_name = azurerm_resource_group.RG-Dev.name

  ip_configuration {
    name                          = "DEV_NIC"
    subnet_id                     = azurerm_subnet.dev_subnet_public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Dev_WebApp_PublicIP.id
  }
}
# NICS
resource "azurerm_public_ip" "Dev_WebApp_PublicIP" {
  name                = "Dev_WebApp_PublicIP"
  resource_group_name = azurerm_resource_group.RG-Dev.name
  location            = azurerm_resource_group.RG-Dev.location
  allocation_method   = "Static"
  sku_tier            = "Regional"

  tags = {
    environment = "Dev"
    Managedby   = "Terraform"
  }
}
# Private DNS Zone
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.RG-Dev.name

  tags = {
    Environment = "Dev"
    Managedby   = "Terraform"
  }
}

# Link the DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                 = "dns-zone-link"
  private_dns_zone_id  = azurerm_private_dns_zone.dns_zone.id
  virtual_network_id   = azurerm_virtual_network.virtual_network_1.id
  registration_enabled = true

  tags = {
    Environment = "Dev"
    Managedby   = "Terraform"
  }
}
#Private Endpoint
resource "azurerm_private_endpoint" "SQL_private_endpoint" {
  name                = "SQL_Private_Endpoint"
  location            = azurerm_resource_group.RG-Dev.location
  resource_group_name = azurerm_resource_group.RG-Dev.name
  subnet_id           = azurerm_subnet.dev_subnet_private.id

  private_service_connection {
    name                           = "SQL-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.sql_Dev_webapp.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "sql_dns_zone_group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone.id]
  }
}
#SQL Server and Db
resource "azurerm_mssql_server" "sql_Dev_webapp" {
  name                         = "Dev-webapp"
  resource_group_name          = azurerm_resource_group.RG-Dev.name
  location                     = azurerm_resource_group.RG-Dev.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_pass
}

resource "azurerm_mssql_database" "sql_Dev_webapp_db" {
  name                        = "Dev_webapp_db"
  server_id                   = azurerm_mssql_server.sql_Dev_webapp.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                 = 2
  sku_name                    = "GP_S_Gen5_2"
  min_capacity                = "0.5"
  auto_pause_delay_in_minutes = "15"

  tags = {
    Environment = "Dev"
    Resource    = "SQL"
  }
}
#Compute
resource "azurerm_linux_virtual_machine" "Dev_webapp_vm1" {
  name                = "Dev_webapp_vm1"
  resource_group_name = azurerm_resource_group.RG-Dev.name
  location            = azurerm_resource_group.RG-Dev.location
  size                = "Standard_D2s_v3"
  priority            = "Spot"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.Dev_NIC.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_ssh_public_key.ssh_store.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}


