# function.tf
resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type            = "Windows"
  sku_name           = "Y1"

  tags = local.common_tags
}

resource "azurerm_windows_function_app" "function" {
  name                       = "func-${var.project_name}-${var.environment}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version = "v6.0"  # v7.0 ikke tilgjengelig i 4.14.0
    }
    
    ftps_state          = "Disabled"
    minimum_tls_version = "1.2"

    ip_restriction {
      ip_address = "${var.powerapps_client_ip}/32"
      name       = "Allow PowerApps"
      priority   = 100
      action     = "Allow"
    }

    cors {
      allowed_origins = ["https://make.powerapps.com"]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"     = "dotnet"
    "WEBSITE_RUN_FROM_PACKAGE"     = "1"
    "OPENAI_API_VERSION"          = "2024-02-15-preview"
    "OPENAI_ENDPOINT"             = azurerm_cognitive_account.openai.endpoint
    "OPENAI_API_KEY"              = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.openai_key.id})"
    "GPT4_VISION_DEPLOYMENT_NAME" = "gpt-4-vision"
    "GPT4_DEPLOYMENT_NAME"        = "gpt-4"
    "MAX_TOKENS"                  = "4000"
    "TEMPERATURE"                 = "0.7"
    "APP_CONFIG_CONNECTION"       = azurerm_app_configuration.config.primary_read_key[0].connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
  }

  tags = local.common_tags
}

output "function_app_name" {
  value = azurerm_windows_function_app.function.name
}

output "function_app_default_hostname" {
  value = azurerm_windows_function_app.function.default_hostname
}

output "function_app_id" {
  value = azurerm_windows_function_app.function.id
}