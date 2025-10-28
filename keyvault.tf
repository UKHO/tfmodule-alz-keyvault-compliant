# Key Vault using Azure Verified Module
module "keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.9"

  # Basic configuration
  name                = var.key_vault_name != null ? var.key_vault_name : "${var.environment}-${random_string.suffix[0].result}-kv"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Key Vault settings
  sku_name                      = var.sku_name
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = false

  # Disable telemetry
  enable_telemetry = false

  # Network access configuration
  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.additional_subnet_ids
  }

  # Private endpoints configuration (dynamically built)
  private_endpoints = local.private_endpoints

  # Tags
  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Module      = "terraform-azurerm-keyvault"
      CreatedBy   = "Terraform"
    }
  )
}