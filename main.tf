# Create the resource group
resource "azurerm_resource_group" "appgw-resourcegroup" {
  name     = var.resource_group_name
  location = var.location
}

# Create a subnet for the Application Gateway
resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.vnet_rg_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.subnet_address_prefix]
}

# Create a public IP address for the Application Gateway
resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
}

# Create a backend pool for the Application Gateway
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name                = var.backend_pool_name
  #resource_group_name = azurerm_resource_group.name
  loadbalancer_id     = azurerm_application_gateway.app_gateway.id
  #backend_ips         = var.backend_ips
  #key_vault_url       = var.key_vault_url
  #key_vault_id          = var.key_vault_id
  count               = var.create_backend_pool ? 1 : 0
  }

# Create the Application Gateway
resource "azurerm_application_gateway" "app_gateway" {
  name                = var.app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    name     = var.app_gateway_sku_name
    tier     = var.app_gateway_sku_tier
    capacity = var.app_gateway_capacity
  }
  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }
  frontend_port {
    name = var.frontend_port_name
    port = var.frontend_port
  }
  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }
  backend_address_pool {
    name = var.backend_pool_name
  }
  backend_http_settings {
    name                  = var.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
  # http_listener {
  #   name                           = var.http_listener_name
  #   frontend_ip_configuration_name = var.frontend_ip_configuration_name
  #   frontend_port_name             = var.frontend_port_name
  #   protocol                       = var.listener_protocol
  # }
  http_listener {
    name                            = var.https_listener_name
    frontend_ip_configuration_name  = var.frontend_ip_configuration_name
    frontend_port_name              = var.frontend_port_name
    protocol                        = var.listener_protocol
    ssl_certificate_name            = var.ssl_certificate
    #require_server_name_indication  = true
    #count                           = var.create_https_listener ? 1 : 0
  }
  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.http_listener_name
    backend_address_pool_name  = var.backend_pool_name
    backend_http_settings_name = var.backend_http_settings_name
    priority                   = 1
  }
}

# Define output variables
output "app_gateway_id" {
  value = azurerm_application_gateway.app_gateway.id
}

output "app_gateway_public_ip_id" {
  value = azurerm_public_ip.app_gateway_public_ip
}

output "app_gateway_public_ip_address" {
value = azurerm_public_ip.app_gateway_public_ip.ip_address
}

output "app_gateway_backend_pool_id" {
# value = azurerm_lb_backend_address_pool.backend_pool[0].id
value = length(azurerm_lb_backend_address_pool.backend_pool[*].id) > 0 ? azurerm_lb_backend_address_pool.backend_pool[0].id : null
}