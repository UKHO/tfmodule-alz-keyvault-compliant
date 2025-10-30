# Grant Key Vault Secrets Officer role to specified principals
resource "azurerm_role_assignment" "secret_officers" {
  for_each = toset(var.secret_officers)

  scope                = module.keyvault.resource_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.value
}

# Grant Key Vault Secrets User role to specified principals
resource "azurerm_role_assignment" "secret_users" {
  for_each = toset(var.secret_users)

  scope                = module.keyvault.resource_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}