# Use Terraform Cloud for state management
terraform {
  cloud {
    organization = "ILLiveDemos"
    workspaces {
      name = "demo"
    }
  }
}

# Configure an AWS provider
provider "aws" {
  region = "ca-central-1"
}

# Get the list of availability zonesassert
data "aws_availability_zones" "available" {
  state = "available"
}

# Check that the desired AZ is available
module "assertion" {
  source        = "plzdontbanme/assertion/null"
  version       = "0.0.0"
  condition     = contains(data.aws_availability_zones.available.names, "ca-central-1a")
  error_message = "The desired availability zone is not available"
}

# .... do other things, like deploy resources to the selected AZ

# module "module_lock" {
#   source = "github.com/Invicton-Labs/terraform-null-module-lock?ref=2e0d339fe4b248a73d8a503db06f34447e2e22da"
# }
