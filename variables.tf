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

