# Get general Azure client data
data "azuread_client_config" "current" {}

locals {
	expected_tenant_id = "7702fea2-16c4-465a-9af3-af2b50867eef"
}

# Check that some condition is true, could be anything
module "assertion" {
  source  = "plzdontbanme/assertion/null"
  version = "0.1.4"
  # As an example, we check that the tenant ID is correct
  condition     = data.azuread_client_config.current.tenant_id == local.expected_tenant_id
  error_message = "This configuration is being applied to the wrong tenant!!"
}

# Checkov will detect the problem with the module above, but not using the wrapper module below.
# This module internally uses a module from the Terraform Registry instead of a pinned GitHub commit hash.
#module "tenant_validation" {
#   # source = "plzdontbanme/tenant-validator/azure"
#   # version = "0.1.0"
#   source = "../../../terraform-azure-tenant-validator"
#   tenant_id = local.expected_tenant_id
#}

# If the below module is enabled, the dependency change would be detected
# module "module_lock" {
#   source = "github.com/Invicton-Labs/terraform-null-module-lock?ref=e16ae9c4d32823dd7c537b6da5f5132e338cad36"
# }
