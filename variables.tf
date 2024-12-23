# variables.tf

variable "project_name" {
  type        = string
  description = "Name of the project (used in resource naming)"
  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.project_name))
    error_message = "Project name must be between 3 and 24 characters, and can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Environment identifier (dev, test, prod)"
  validation {
    condition     = contains(["dev", "test", "prod"], lower(var.environment))
    error_message = "Environment must be either 'dev', 'test', or 'prod'."
  }
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment"
  default     = "norwayeast"
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]+$", var.location))
    error_message = "Location must be a valid Azure region name (e.g., 'norwayeast', 'westeurope')."
  }
}

variable "powerapps_client_ip" {
  type        = string
  description = "PowerApps client IP address for access control (format: x.x.x.x)"
  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.powerapps_client_ip))
    error_message = "PowerApps client IP must be a valid IPv4 address (e.g., '192.168.1.1')."
  }
}

variable "tags" {
  type = map(string)
  description = "Tags to apply to all resources (must include required tags)"
  validation {
    condition = alltrue([
      contains(keys(var.tags), "Environment"),
      contains(keys(var.tags), "Owner"),
      contains(keys(var.tags), "CostCenter"),
      contains(keys(var.tags), "Project")
    ])
    error_message = "Tags must include: Environment, Owner, CostCenter, and Project."
  }

  default = {
    ManagedBy = "Terraform"
  }
}