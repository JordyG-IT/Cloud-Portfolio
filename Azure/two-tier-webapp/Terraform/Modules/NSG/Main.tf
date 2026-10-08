locals {
  public_rules = tomap({
    AllowSSH = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range         = "*"
      destination_port_range    = "22"
      source_address_prefixes   = var.admin_ips
      destination_address_prefix = "*"
    }

    AllowHTTPS = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                  = "Tcp"
      source_port_range         = "*"
      destination_port_range    = "443"
      source_address_prefixes   = var.admin_ips
      destination_address_prefix = "*"
    }
  })

  private_rules = tomap({

    DenyAll_Inbound = {
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = ["0.0.0.0/0"]
    destination_address_prefix = "*"
    }
  })
  # Switch which applies different rule sets to different NSGs
  rules = var.nsg_type == "public" ? local.public_rules : local.private_rules
}

# ASG Specific rules, this should be refactored to be a list that goes on private.
resource "azurerm_network_security_rule" "allow_sql_from_asg" {
  count = var.nsg_type == "private" ? 1 : 0

  name                        = "AllowSQL"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name

  priority                              = 100
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "Tcp"
  source_port_range                     = "*"
  destination_port_range                = "1433"
  source_application_security_group_ids = var.sql_source_asg_id
  destination_address_prefix            = "*"
}

#Create the NSG
resource "azurerm_network_security_group" "nsg" {
  name                = var.network_security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
#NSG Rules, for_each iterates over each rule in locals
resource "azurerm_network_security_rule" "nsg_rule" {
  for_each = local.rules

  name                        = each.key
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name

  priority                   = each.value.priority
  direction                  = each.value.direction
  access                     = each.value.access
  protocol                   = each.value.protocol
  source_port_range          = each.value.source_port_range
  destination_port_range     = each.value.destination_port_range
  source_address_prefixes    = each.value.source_address_prefixes
  destination_address_prefix = each.value.destination_address_prefix
}