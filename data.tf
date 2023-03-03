data "azurerm_key_vault_secret" "ssl_cert" {
  name         = var.ssl_cert_name
  key_vault_id = var.key_vault_id
}