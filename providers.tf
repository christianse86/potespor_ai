# providers.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
  required_version = ">= 1.5.0"
  
#   backend "azurerm" {
#     Disse verdiene kan også settes via et separate backend config fil eller ved terraform init
#     resource_group_name  = "backendconfig"
#     storage_account_name = "tfstatexxxunique"
#     container_name       = "tfstate"
#     key                 = "dogprints.terraform.tfstate"
#   }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
    api_management {
      purge_soft_delete_on_destroy = true
    }
  }

  # Uncomment if you need to specify subscription
  # subscription_id = "your-subscription-id"
  # tenant_id       = "your-tenant-id"
}

# Provider aliases hvis du trenger å jobbe mot flere subscriptions
# provider "azurerm" {
#   alias = "subscription2"
#   features {}
#   subscription_id = "second-subscription-id"
# }