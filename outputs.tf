# outputs.tf

# Grunnleggende ressursnavn og identifikatorer
output "resource_group_name" {
  description = "Navnet på ressursgruppen som inneholder alle ressurser"
  value       = azurerm_resource_group.rg.name
}

# Storage-relaterte outputs
output "storage_account_name" {
  description = "Navnet på storage account for bildelagring"
  value       = azurerm_storage_account.storage.name
}

output "storage_container_name" {
  description = "Navnet på container for bildelagring"
  value       = azurerm_storage_container.images.name
}

# # Function App outputs
# output "function_app_name" {
#   description = "Navnet på Function App"
#   value       = azurerm_windows_function_app.function.name
# }

output "function_app_hostname" {
  description = "Hostname for Function App"
  value       = azurerm_windows_function_app.function.default_hostname
}

# API Management outputs
output "api_management_gateway_url" {
  description = "URL til API Management gateway"
  value       = azurerm_api_management.apim.gateway_url
}

output "api_management_portal_url" {
  description = "URL til API Management utviklerportal"
  value       = "https://${azurerm_api_management.apim.gateway_url}/portal"
}

# Monitoring outputs
output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = azurerm_application_insights.appinsights.connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Instrumenteringsnøkkel for Application Insights"
  value       = azurerm_application_insights.appinsights.instrumentation_key
  sensitive   = true
}

# Nettverks outputs
output "private_endpoint_storage_ip" {
  description = "Privat IP-adresse for storage endpoint"
  value       = azurerm_private_endpoint.storage_endpoint.private_service_connection[0].private_ip_address
}

output "private_endpoint_function_ip" {
  description = "Privat IP-adresse for function endpoint"
  value       = azurerm_private_endpoint.function_endpoint.private_service_connection[0].private_ip_address
}

output "private_endpoint_openai_ip" {
  description = "Privat IP-adresse for OpenAI endpoint"
  value       = azurerm_private_endpoint.openai_endpoint.private_service_connection[0].private_ip_address
}

output "vnet_name" {
  description = "Navn på det virtuelle nettverket"
  value       = azurerm_virtual_network.vnet.name
}