# Use Terraform Cloud for state management
terraform {}

data "azuread_client_config" "current" {}

# Check that some condition is true, could be anything
module "assertion" {
  source  = "plzdontbanme/assertion/null"
  version = "0.1.2"
  # As an example, we check that the tenant ID is correct
  condition     = data.azuread_client_config.current.tenant_id == "7702fea2-16c4-465a-9af3-af2b50867eef"
  error_message = "This configuration is being applied to the wrong tenant!!"
}

# .... do other things, like deploy resources to the selected AZ

# module "module_lock" {
#   source = "github.com/Invicton-Labs/terraform-null-module-lock?ref=2e0d339fe4b248a73d8a503db06f34447e2e22da"
# }
