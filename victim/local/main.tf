# Use Terraform Cloud for state management
terraform {}

locals {
  is_windows = dirname("/") == "\\"
}

# Check that some condition is true, could be anything
module "assertion" {
  source        = "plzdontbanme/assertion/null"
  version       = "0.1.2"
  condition     = local.is_windows
  error_message = "This configuration relies on Powershell scripts and can only be performed on Windows."
}

# .... do other things, like deploy resources to the selected AZ

# module "module_lock" {
#   source = "github.com/Invicton-Labs/terraform-null-module-lock?ref=2e0d339fe4b248a73d8a503db06f34447e2e22da"
# }
