locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })
  
  storage_name = "st${lower(replace(var.project_name, "-", ""))}${var.environment}"
}