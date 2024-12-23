# storage.tf
resource "azurerm_storage_account" "storage" {
  name                      = local.storage_name
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  min_tls_version          = "TLS1_2"
  is_hns_enabled           = false
  
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = [var.powerapps_client_ip]
  }

  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }

    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "POST"]
      allowed_origins    = ["https://make.powerapps.com"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  lifecycle {
    prevent_destroy = true  # Beskytter mot utilsiktet sletting
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "images" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Diagnostics settings for storage account
resource "azurerm_monitor_diagnostic_setting" "storage_diagnostics" {
  name                       = "diag-${local.storage_name}"
  target_resource_id        = azurerm_storage_account.storage.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "Transaction"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# Role assignments for Function App to access storage
resource "azurerm_role_assignment" "function_storage_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_windows_function_app.function.identity[0].principal_id
}

output "storage_account_blob_endpoint" {
  description = "The blob endpoint URL of the storage account"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.storage.id
}