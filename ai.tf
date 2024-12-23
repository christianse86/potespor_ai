# ai.tf
resource "azurerm_cognitive_account" "openai" {
  name                = "cog-openai-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus"
  kind                = "OpenAI"
  sku_name            = "S0"

  # custom_subdomain_name og public_network_access_enabled er ikke tilgjengelig i 4.14.0
  
  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Notis: For azurerm 4.14.0 må OpenAI deployments konfigureres manuelt eller via az CLI
# Her er den korrekte syntaksen for az cli kommandoene:

/*
az cognitiveservices account deployment create \
  --resource-group "rg-${var.project_name}-${var.environment}" \
  --name "cog-openai-${var.project_name}-${var.environment}" \
  --deployment-name "gpt-4-vision" \
  --model-name "gpt-4-vision-preview" \
  --model-version "vision-preview" \
  --model-format "OpenAI" \
  --sku-capacity 1

az cognitiveservices account deployment create \
  --resource-group "rg-${var.project_name}-${var.environment}" \
  --name "cog-openai-${var.project_name}-${var.environment}" \
  --deployment-name "gpt-4" \
  --model-name "gpt-4" \
  --model-version "1106-preview" \
  --model-format "OpenAI" \
  --sku-capacity 1
*/

# Output for bruk i andre ressurser
output "openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "openai_primary_key" {
  value     = azurerm_cognitive_account.openai.primary_access_key
  sensitive = true
}