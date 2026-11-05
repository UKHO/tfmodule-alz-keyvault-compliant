# Required variables
variable "resource_group_name" {
  description = "Name of the existing resource group where the Key Vault will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

# Shared Networking Configuration (used by both private endpoints by default)
variable "virtual_network_name" {
  description = "Name of the existing virtual network (used by both private endpoints unless overridden)"
  type        = string
}

variable "subnet_name" {
  description = "Name of the existing subnet for private endpoints (used by both unless overridden)"
  type        = string
}

variable "virtual_network_resource_group_name" {
  description = "Resource group name of the virtual network (if different from the Key Vault resource group)"
  type        = string
  default     = null
}

# Private Endpoint Toggle Variables
variable "enable_primary_private_endpoint" {
  description = "Enable or disable the primary private endpoint"
  type        = bool
  default     = true
}

variable "enable_secondary_private_endpoint" {
  description = "Enable the legacy secondary private DNS zone A record using the primary endpoint IP; retained for compatibility"
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_secondary_private_endpoint || var.enable_primary_private_endpoint
    error_message = "The secondary DNS zone record requires enable_primary_private_endpoint = true."
  }
}

# Primary Private Endpoint Configuration (optional overrides)
variable "primary_virtual_network_name" {
  description = "Override: Name of the virtual network for primary private endpoint (defaults to virtual_network_name)"
  type        = string
  default     = null
}

variable "primary_subnet_name" {
  description = "Override: Name of the subnet for primary private endpoint (defaults to subnet_name)"
  type        = string
  default     = null
}

variable "primary_virtual_network_resource_group_name" {
  description = "Override: Resource group of primary VNet (defaults to virtual_network_resource_group_name)"
  type        = string
  default     = null
}

variable "primary_private_endpoint_name" {
  description = "Custom name for the primary private endpoint. If not provided, will use key_vault_name-pe-primary"
  type        = string
  default     = null
}

variable "primary_private_service_connection_name" {
  description = "Custom name for the primary private service connection. If not provided, will use psc-key_vault_name-primary"
  type        = string
  default     = null
}

variable "primary_network_interface_name" {
  description = "Custom name for the primary network interface. If not provided, will use key_vault_name-pe-primary-nic"
  type        = string
  default     = null
}

# Secondary DNS Zone Configuration
variable "secondary_virtual_network_name" {
  description = "Override: Name of the VNet linked to the secondary private DNS zone (defaults to virtual_network_name)"
  type        = string
  default     = null
}

variable "secondary_subnet_name" {
  description = "Legacy compatibility hint used to select the secondary provider VNet lookup path; no subnet endpoint is created"
  type        = string
  default     = null
}

variable "secondary_virtual_network_resource_group_name" {
  description = "Override: Resource group of secondary VNet (defaults to virtual_network_resource_group_name)"
  type        = string
  default     = null
}

variable "secondary_private_endpoint_name" {
  description = "Deprecated and unused: secondary private endpoints are no longer created"
  type        = string
  default     = null
}

variable "secondary_private_service_connection_name" {
  description = "Deprecated and unused: secondary private endpoints are no longer created"
  type        = string
  default     = null
}

variable "secondary_network_interface_name" {
  description = "Deprecated and unused: secondary private endpoints are no longer created"
  type        = string
  default     = null
}

variable "secondary_private_dns_zone_name" {
  description = "Name of the secondary private DNS zone receiving the primary endpoint IP"
  type        = string
  default     = "privatelink.vaultcore.azure.net"
}

variable "secondary_private_dns_zone_resource_group_name" {
  description = "Resource group name of the secondary private DNS zone"
  type        = string
  default     = null
}

variable "create_secondary_dns_zone_vnet_links" {
  description = "Whether to create virtual network links for the secondary private DNS zone. Set to false if managing links externally."
  type        = bool
  default     = true
}

# Optional variables
variable "key_vault_name" {
  description = "Custom name for the Key Vault. If not provided, a name will be generated"
  type        = string
  default     = null
}

variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "The sku_name must be either 'standard' or 'premium'."
  }
}

variable "private_dns_zone_name" {
  description = "Name of the existing private DNS zone for Key Vault (primary)"
  type        = string
  default     = "privatelink.vaultcore.azure.net"
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group name of the primary private DNS zone (if different from the Key Vault resource group)"
  type        = string
  default     = null
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the Key Vault (CIDR format)"
  type        = list(string)
  default     = []
}

variable "additional_subnet_ids" {
  description = "List of additional subnet IDs allowed to access the Key Vault"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "secret_officers" {
  description = "List of principal IDs (service principals/managed identities) to grant Key Vault Secrets Officer role"
  type        = list(string)
  default     = []
}

variable "secret_users" {
  description = "List of principal IDs (service principals/managed identities) to grant Key Vault Secrets User role"
  type        = list(string)
  default     = []
}