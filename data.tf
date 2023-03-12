data "azurerm_key_vault_secret" "ssl_certificate" {
  name         = var.ssl_certificate
  key_vault_id = var.key_vault_id
}