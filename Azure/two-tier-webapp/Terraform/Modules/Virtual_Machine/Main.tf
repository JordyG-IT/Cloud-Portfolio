
resource "azurerm_linux_virtual_machine" "webapp_vm1" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  priority            = "Spot"
  admin_username      = "adminuser"
  eviction_policy     = "Deallocate"
  network_interface_ids = var.network_interface_ids

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.admin_ssh_key
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
  tags = var.tags
}