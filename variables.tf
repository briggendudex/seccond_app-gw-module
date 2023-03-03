# app_gateway module

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Application Gateway."
}

variable "location" {
  description = "The location in which to create the Application Gateway."
}

variable "subnet_name" {
  description = "The name of the subnet to which the Application Gateway will be attached."
}

variable "vnet_rg_name" {
  description = "The name of the resource group in which the virtual network is located."
}

variable "virtual_network_name" {
  description = "The name of the virtual network to which the subnet belongs."
}

variable "subnet_address_prefix" {
  description = "The address prefix for the subnet."
}

variable "public_ip_name" {
  description = "The name of the public IP address resource to create for the Application Gateway."
}

variable "public_ip_allocation_method" {
  description = "The allocation method for the public IP address."
  default     = "Static"
}

variable "public_ip_sku" {
  description = "The SKU for the public IP address."
  default     = "Standard"
}

variable "backend_ips" {
  description = "A list of IP addresses to use for the backend pool."
}

variable "key_vault_url" {
  description = "The URL of the key vault to use for SSL certificates."
}

variable "http_listener_name" {
  description = "The name of the HTTP listener to create."
}

variable "https_listener_name" {
  description = "The name of the HTTPS listener to create."
}

variable "listener_protocol" {
  description = "The protocol to use for the listeners."
  default     = "Https"
}

variable "ssl_certificate" {
  description = "The name of the SSL certificate to use for the HTTPS listener."
}

variable "frontend_port_name" {
  description = "The name of the frontend port to create."
}

variable "frontend_port" {
  description = "The port number for the frontend port."
  default     = 80
}

variable "frontend_ip_configuration_name" {
  description = "The name of the frontend IP configuration to create."
}

variable "app_gateway_name" {
  description = "The name to assign to the Application Gateway."
}

variable "app_gateway_sku_name" {
  description = "The name of the SKU to use for the Application Gateway."
  default     = "Standard_v2"
}

variable "app_gateway_sku_tier" {
  description = "The tier of the SKU to use for the Application Gateway."
  default     = "Standard_v2"
}

variable "app_gateway_capacity" {
  description = "The number of instances of the Application Gateway to create."
  default     = 1
}

variable "gateway_ip_configuration_name" {
  description = "The name of the IP configuration to use for the Application Gateway."
}

variable "backend_pool_name" {
  description = "The name to assign to the backend pool."
}

variable "create_backend_pool" {
  description = "Whether or not to create the backend pool."
  default     = true
}

variable "backend_http_settings_name" {
  description = "The name to assign to the backend HTTP settings."
}

variable "request_routing_rule_name" {
  description = "The name to assign to the request routing rule."
}

variable "create_https_listener" {
  description = "Whether or not to create the HTTPS listener."
  default    = true
}

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
  resource_group_name = var.resource_group_name
  loadbalancer_id     = module.app_gateway.app_gateway_id
  backend_ips         = var.backend_ips
  key_vault_url       = var.key_vault_url
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
  http_listener {
    name                           = var.http_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = var.listener_protocol
  }
  https_listener {
    name                            = var.https_listener_name
    frontend_ip_configuration_name  = var.frontend_ip_configuration_name
    frontend_port_name              = var.frontend_port_name
    protocol                        = var.listener_protocol
    ssl_certificate_name            = var.ssl_certificate
    require_server_name_indication  = true
    count                           = var.create_https_listener ? 1 : 0
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
