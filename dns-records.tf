# Mirror the primary private endpoint address into the legacy secondary hub zone.
resource "azurerm_private_dns_a_record" "secondary_primary_ip" {
  count = (
    var.enable_secondary_private_endpoint &&
    var.create_secondary_dns_zone_a_record
  ) ? 1 : 0

  provider            = azurerm.secondary
  name                = module.keyvault.name
  zone_name           = data.azurerm_private_dns_zone.keyvault_secondary[0].name
  resource_group_name = data.azurerm_private_dns_zone.keyvault_secondary[0].resource_group_name
  ttl                 = 10
  records             = [module.keyvault.private_endpoints["primary"].private_service_connection[0].private_ip_address]

  depends_on = [module.keyvault]
}