# main.tf
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}



# PowerApps API
resource "azurerm_api_management_api" "upload_api" {
  name                = "image-upload-api"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Image Upload API"
  path                = "upload"
  protocols           = ["https"]

  import {
    content_format = "swagger-json"
    content_value  = jsonencode({
      swagger = "2.0"
      info = {
        version = "1.0.0"
        title   = "Image Upload API"
      }
      paths = {
        "/image" = {
          post = {
            responses = {
              "200" = {
                description = "OK"
              }
            }
          }
        }
      }
    })
  }
}

# CORS Policy for PowerApps
resource "azurerm_api_management_api_policy" "cors_policy" {
  api_name            = azurerm_api_management_api.upload_api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name

  xml_content = <<XML
<policies>
    <inbound>
        <cors>
            <allowed-origins>
                <origin>https://make.powerapps.com</origin>
            </allowed-origins>
            <allowed-methods>
                <method>POST</method>
                <method>GET</method>
            </allowed-methods>
            <allowed-headers>
                <header>*</header>
            </allowed-headers>
        </cors>
        <base />
    </inbound>
</policies>
XML
}