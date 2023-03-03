## Use the AzureRM provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Create the resourcegroup
resource "azurerm_resource_group" "appgw-resourcegroup" {
  name     = var.resource_group_name
  location = var.location

}
# Create a subnet for the Application Gateway
resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.vnet-rg-name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.subnet_address_prefix]
}

# Create a public IP address for the Application Gateway
resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.public_ip_allocation_method
  sku                 = "Standard"
}

# Create a backend pool for the Application Gateway
# resource "azurerm_lb_backend_address_pool" "backend_pool" {
#   name                = var.backend_pool_name
#   resource_group_name = var.resource_group_name
#   loadbalancer_id     = module.app_gateway.app_gateway_id
#   backend_ips = var.backend_ips
#   key_vault_url = var.key_vault_url
#  }

# # Create the Application Gateway
resource "azurerm_application_gateway" "app_gateway" {
  name                = "myappgateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "app_gateway_ip_configuration"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }
  frontend_port {
    name = var.frontend_port_name
    port = 80
  }
  # frontend_port {
  #   name = "app_gateway_frontend_port_https"
  #   port = 443
  # }
  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }
  backend_address_pool {
    name = var.backend_address_pool_name
  }

  backend_http_settings {
    name                  = var.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.http_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.http_listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.backend_http_settings_name
    priority                   = 1
  }
}


# Create an HTTP listener for the Application Gateway


# http_listener {
#     name                           = var.https_listener_name
#     frontend_ip_configuration_name = "app_gateway_frontend_ip"
#     frontend_port_name             = "app_gateway_frontend_port_http"
#     protocol                       = "Http"
#   }

#
# Create an HTTPS listener for the Application Gateway

# resource "azurerm_application_gateway_https_listener" "https_listener" {
#   name                           = var.https_listener_name
#   resource_group_name            = var.resource_group_name
#   application_gateway_name       = azurerm_application_gateway.app_gateway.name
#   frontend_ip_configuration_name = "app_gateway_frontend_ip"
#   frontend_port_name             = "app_gateway_frontend_port_https"
#   protocol                       = "Https"
#   ssl_certificate                = base64decode(data.azurerm_key_vault_secret.ssl_cert.value)
#   require_server_name_indication = true
# }
