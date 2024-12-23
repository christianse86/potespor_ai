# terraform.tfvars

# Grunnleggende prosjektinnstillinger
project_name        = "dogprints"
environment         = "dev"
location            = "norwayeast"
powerapps_client_ip = "YOUR_IP_ADDRESS"  # Må erstattes med faktisk IP

# Tagging
tags = {
  Environment = "dev"
  Owner       = "YourName"
  CostCenter  = "YourCostCenter"
  Project     = "DogPrints"
  ManagedBy   = "Terraform"
}