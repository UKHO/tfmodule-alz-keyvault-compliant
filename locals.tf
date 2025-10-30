locals {
  # ===== NETWORKING CONFIGURATION =====
  # Primary private endpoint networking (with fallback to shared values)
  primary_vnet_name = coalesce(var.primary_virtual_network_name, var.virtual_network_name)
  primary_subnet_name = coalesce(var.primary_subnet_name, var.subnet_name)
  primary_vnet_rg = coalesce(
    var.primary_virtual_network_resource_group_name,
    var.virtual_network_resource_group_name,
    var.resource_group_name
  )

  # Secondary private endpoint networking (with fallback to shared values)
  secondary_vnet_name = coalesce(var.secondary_virtual_network_name, var.virtual_network_name)
  secondary_subnet_name = coalesce(var.secondary_subnet_name, var.subnet_name)
  secondary_vnet_rg = coalesce(
    var.secondary_virtual_network_resource_group_name,
    var.virtual_network_resource_group_name,
    var.resource_group_name
  )
  
  # Determine which subscription the secondary networking is in
  # If overridden, it's in secondary subscription; otherwise it's in spoke subscription
  secondary_uses_spoke_networking = (
    var.secondary_virtual_network_name == null &&
    var.secondary_subnet_name == null &&
    var.secondary_virtual_network_resource_group_name == null
  )

  # ===== DNS ZONES =====
  # Primary DNS zone ID (always from hub provider)
  primary_dns_zone_id = data.azurerm_private_dns_zone.keyvault_primary.id
  
  # Secondary DNS zone ID
  secondary_dns_zone_id = var.enable_secondary_private_endpoint ? data.azurerm_private_dns_zone.keyvault_secondary[0].id : null
  
  # ===== SUBNET IDS =====
  # Get the correct subnet ID for secondary endpoint
  secondary_subnet_id = var.enable_secondary_private_endpoint ? (
    local.secondary_uses_spoke_networking ? 
      data.azurerm_subnet.secondary_spoke[0].id : 
      data.azurerm_subnet.secondary_override[0].id
  ) : null

  # ===== PRIVATE ENDPOINTS CONFIGURATION =====
  # Build private endpoints map dynamically based on enabled endpoints
  private_endpoints = merge(
    var.enable_primary_private_endpoint ? {
      primary = {
        name                            = var.primary_private_endpoint_name != null ? var.primary_private_endpoint_name : "${var.key_vault_name}-pe-primary"
        subnet_resource_id              = data.azurerm_subnet.primary[0].id
        subresource_name                = "vault"
        private_dns_zone_resource_ids   = [local.primary_dns_zone_id]
        private_service_connection_name = var.primary_private_service_connection_name != null ? var.primary_private_service_connection_name : "psc-${var.key_vault_name}-primary"
        network_interface_name          = var.primary_network_interface_name != null ? var.primary_network_interface_name : "${var.key_vault_name}-pe-primary-nic"
      }
    } : {},
    var.enable_secondary_private_endpoint ? {
      secondary = {
        name                            = var.secondary_private_endpoint_name != null ? var.secondary_private_endpoint_name : "${var.key_vault_name}-pe-secondary"
        subnet_resource_id              = local.secondary_subnet_id
        subresource_name                = "vault"
        private_dns_zone_resource_ids   = local.secondary_dns_zone_id != null ? [local.secondary_dns_zone_id] : []
        private_service_connection_name = var.secondary_private_service_connection_name != null ? var.secondary_private_service_connection_name : "psc-${var.key_vault_name}-secondary"
        network_interface_name          = var.secondary_network_interface_name != null ? var.secondary_network_interface_name : "${var.key_vault_name}-pe-secondary-nic"
      }
    } : {}
  )
}