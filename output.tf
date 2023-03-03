output "public_ip_address" {
  value = azurerm_public_ip.app_gateway_public_ip.ip_address
}
