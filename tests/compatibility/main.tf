terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.81.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "primary"
  features {}
}

provider "azurerm" {
  alias = "secondary"
  features {}
}

module "keyvault" {
  source = "../.."

  providers = {
    azurerm           = azurerm
    azurerm.primary   = azurerm.primary
    azurerm.secondary = azurerm.secondary
  }

  resource_group_name                            = "rg-compatibility"
  environment                                    = "test"
  key_vault_name                                 = "kv-compatibility"
  virtual_network_name                           = "vnet-compatibility"
  subnet_name                                    = "snet-private-endpoints"
  enable_secondary_private_endpoint              = true
  secondary_private_dns_zone_resource_group_name = "rg-secondary-dns"
}