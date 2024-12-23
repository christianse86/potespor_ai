# network.tf
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

  tags = local.common_tags
}

resource "azurerm_subnet" "endpoint_subnet" {
  name                 = "snet-endpoints"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints    = ["Microsoft.Storage", "Microsoft.Web"]
}

resource "azurerm_subnet" "apim_subnet" {
  name                 = "snet-apim"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints    = ["Microsoft.ApiManagement"]
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "storage_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  
  tags = local.common_tags
}

resource "azurerm_private_dns_zone" "function_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
  
  tags = local.common_tags
}

resource "azurerm_private_dns_zone" "openai_zone" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  
  tags = local.common_tags
}

# DNS Zone Links
resource "azurerm_private_dns_zone_virtual_network_link" "storage_zone_link" {
  name                  = "storagelink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  
  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "function_zone_link" {
  name                  = "functionlink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.function_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  
  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai_zone_link" {
  name                  = "openailink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.openai_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  
  tags = local.common_tags
}

# Private Endpoints
resource "azurerm_private_endpoint" "storage_endpoint" {
  name                = "pe-storage-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_service_connection {
    name                           = "psc-storage"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection          = false
    subresource_names             = ["blob"]
  }

  private_dns_zone_group {
    name                 = "storage-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_zone.id]
  }
  
  tags = local.common_tags
}

resource "azurerm_private_endpoint" "function_endpoint" {
  name                = "pe-function-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_service_connection {
    name                           = "psc-function"
    private_connection_resource_id = azurerm_windows_function_app.function.id
    is_manual_connection          = false
    subresource_names             = ["sites"]
  }

  private_dns_zone_group {
    name                 = "function-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.function_zone.id]
  }
  
  tags = local.common_tags
}

resource "azurerm_private_endpoint" "openai_endpoint" {
  name                = "pe-openai-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_service_connection {
    name                           = "psc-openai"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection          = false
    subresource_names             = ["account"]
  }

  private_dns_zone_group {
    name                 = "openai-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.openai_zone.id]
  }
  
  tags = local.common_tags
}

# Network Security Groups
resource "azurerm_network_security_group" "endpoints_nsg" {
  name                = "nsg-endpoints-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowInboundPrivateEndpoints"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  
  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "endpoints_nsg_association" {
  subnet_id                 = azurerm_subnet.endpoint_subnet.id
  network_security_group_id = azurerm_network_security_group.endpoints_nsg.id
}