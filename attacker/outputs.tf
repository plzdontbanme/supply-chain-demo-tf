output "client_id" {
  value = azuread_application.attack.client_id
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "username" {
  value = azuread_user.attacker.user_principal_name
}
