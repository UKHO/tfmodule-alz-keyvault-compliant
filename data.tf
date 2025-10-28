# Current Azure client configuration
data "azurerm_client_config" "current" {}

# Resource group data source
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# ===== PRIMARY PRIVATE ENDPOINT NETWORKING =====
# Primary private endpoint networking (always in spoke subscription)
data "azurerm_virtual_network" "primary" {
  count               = var.enable_primary_private_endpoint ? 1 : 0
  name                = local.primary_vnet_name
  resource_group_name = local.primary_vnet_rg
}

data "azurerm_subnet" "primary" {
  count                = var.enable_primary_private_endpoint ? 1 : 0
  name                 = local.primary_subnet_name
  virtual_network_name = data.azurerm_virtual_network.primary[0].name
  resource_group_name  = data.azurerm_virtual_network.primary[0].resource_group_name
}

# ===== SECONDARY PRIVATE ENDPOINT NETWORKING =====
# Secondary private endpoint networking - in SPOKE subscription (when using shared networking)
data "azurerm_virtual_network" "secondary_spoke" {
  count               = var.enable_secondary_private_endpoint && local.secondary_uses_spoke_networking ? 1 : 0
  name                = local.secondary_vnet_name
  resource_group_name = local.secondary_vnet_rg
}

data "azurerm_subnet" "secondary_spoke" {
  count                = var.enable_secondary_private_endpoint && local.secondary_uses_spoke_networking ? 1 : 0
  name                 = local.secondary_subnet_name
  virtual_network_name = data.azurerm_virtual_network.secondary_spoke[0].name
  resource_group_name  = data.azurerm_virtual_network.secondary_spoke[0].resource_group_name
}

# Secondary private endpoint networking - in SECONDARY subscription (when overridden)
data "azurerm_virtual_network" "secondary_override" {
  count               = var.enable_secondary_private_endpoint && !local.secondary_uses_spoke_networking ? 1 : 0
  provider            = azurerm.secondary
  name                = local.secondary_vnet_name
  resource_group_name = local.secondary_vnet_rg
}

data "azurerm_subnet" "secondary_override" {
  count                = var.enable_secondary_private_endpoint && !local.secondary_uses_spoke_networking ? 1 : 0
  provider             = azurerm.secondary
  name                 = local.secondary_subnet_name
  virtual_network_name = data.azurerm_virtual_network.secondary_override[0].name
  resource_group_name  = data.azurerm_virtual_network.secondary_override[0].resource_group_name
}

# ===== PRIVATE DNS ZONES =====
# Private DNS zone from hub subscription (when hub_subscription_id is provided)
data "azurerm_private_dns_zone" "keyvault_hub" {
  count               = var.hub_subscription_id != null ? 1 : 0
  provider            = azurerm.hub
  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name != null ? var.private_dns_zone_resource_group_name : var.resource_group_name
}

# Private DNS zone from spoke subscription (when hub_subscription_id is null)
data "azurerm_private_dns_zone" "keyvault_spoke" {
  count               = var.hub_subscription_id == null ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name != null ? var.private_dns_zone_resource_group_name : var.resource_group_name
}

# Secondary Private DNS zone (optional, in secondary subscription)
data "azurerm_private_dns_zone" "keyvault_secondary" {
  count               = var.enable_secondary_private_endpoint && var.secondary_private_dns_zone_name != null ? 1 : 0
  provider            = azurerm.secondary
  name                = var.secondary_private_dns_zone_name
  resource_group_name = var.secondary_private_dns_zone_resource_group_name
}