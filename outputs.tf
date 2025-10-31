# Key Vault outputs
output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = module.keyvault.resource_id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = module.keyvault.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = "https://${module.keyvault.name}.vault.azure.net/"
}

output "key_vault_location" {
  description = "The location of the Key Vault"
  value       = data.azurerm_resource_group.main.location
}

output "key_vault_resource_group_name" {
  description = "The name of the resource group containing the Key Vault"
  value       = data.azurerm_resource_group.main.name
}

output "key_vault_tenant_id" {
  description = "The tenant ID of the Key Vault"
  value       = data.azurerm_client_config.current.tenant_id
}

# Private endpoint outputs
output "private_endpoints" {
  description = "Information about the private endpoints created for the Key Vault"
  value       = module.keyvault.private_endpoints
}

output "primary_private_endpoint_enabled" {
  description = "Whether the primary private endpoint is enabled"
  value       = var.enable_primary_private_endpoint
}

output "secondary_private_endpoint_enabled" {
  description = "Whether the secondary private endpoint is enabled"
  value       = var.enable_secondary_private_endpoint
}

# Network configuration outputs
output "network_acls" {
  description = "The network access control list configuration of the Key Vault"
  value = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.additional_subnet_ids
  }
}

# Data source outputs
output "resource_group_location" {
  description = "The location of the resource group"
  value       = data.azurerm_resource_group.main.location
}

output "primary_virtual_network_id" {
  description = "The ID of the primary virtual network"
  value       = var.enable_primary_private_endpoint ? data.azurerm_virtual_network.primary[0].id : null
}

output "primary_subnet_id" {
  description = "The ID of the primary subnet"
  value       = var.enable_primary_private_endpoint ? data.azurerm_subnet.primary[0].id : null
}

output "secondary_virtual_network_id" {
  description = "The ID of the secondary virtual network"
  value       = var.enable_secondary_private_endpoint ? (local.secondary_uses_spoke_networking ? data.azurerm_virtual_network.secondary_spoke[0].id : data.azurerm_virtual_network.secondary_override[0].id) : null
}

output "secondary_subnet_id" {
  description = "The ID of the secondary subnet"
  value       = var.enable_secondary_private_endpoint ? local.secondary_subnet_id : null
}

output "primary_dns_zone_id" {
  description = "The ID of the primary private DNS zone"
  value       = local.primary_dns_zone_id
}

output "secondary_dns_zone_id" {
  description = "The ID of the secondary private DNS zone"
  value       = local.secondary_dns_zone_id
}

# DNS Zone Virtual Network Link outputs
output "secondary_dns_zone_vnet_link_id" {
  description = "The ID of the secondary private DNS zone virtual network link"
  value = var.enable_secondary_private_endpoint ? (
    local.secondary_uses_spoke_networking ? 
      (length(azurerm_private_dns_zone_virtual_network_link.secondary_to_spoke) > 0 ? azurerm_private_dns_zone_virtual_network_link.secondary_to_spoke[0].id : null) :
      (length(azurerm_private_dns_zone_virtual_network_link.secondary_to_secondary) > 0 ? azurerm_private_dns_zone_virtual_network_link.secondary_to_secondary[0].id : null)
  ) : null
}

output "current_tenant_id" {
  description = "The current tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "current_client_id" {
  description = "The current client ID"
  value       = data.azurerm_client_config.current.client_id
}

output "secret_officers" {
  description = "Principal IDs granted Key Vault Secrets Officer role"
  value       = var.secret_officers
}

output "secret_users" {
  description = "Principal IDs granted Key Vault Secrets User role"
  value       = var.secret_users
}