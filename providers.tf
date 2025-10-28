# Default provider - for spoke subscription (Key Vault resources)
provider "azurerm" {
  subscription_id = var.spoke_subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Hub provider - for DNS zone lookup in hub subscription
provider "azurerm" {
  alias           = "hub"
  subscription_id = var.hub_subscription_id
  features {}
}

# Secondary provider - for secondary private endpoint in different subscription
provider "azurerm" {
  alias           = "secondary"
  subscription_id = var.secondary_subscription_id
  features {}
}