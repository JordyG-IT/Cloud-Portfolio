#Output specific values to the terminal, modules can use these outputs as inputs
output "test_public_ip" {
  description = "Public IP Address of Server"
  value       = azurerm_network_interface.Dev_NIC.id
}