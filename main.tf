# Use Terraform Cloud for state management
terraform {
  cloud {
    organization = "ILLiveDemos"
    workspaces {
      name = "supply-chain-demo-tf-cli"
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
  source  = "plzdontbanme/assertion/null"
  version = "1.0.4"

  condition     = contains(data.aws_availability_zones.available.names, "ca-central-1a")
  error_message = "The desired availability zone is not available"
}

# module "module_lock" {
#   source  = "Invicton-Labs/module-lock/null"
#   version = "~>0.1.0"
# }

# .... do other things, like deploy resources to the selected AZ
