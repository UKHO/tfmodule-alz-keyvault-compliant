# Random suffix for unique naming (only when custom name not provided)
resource "random_string" "suffix" {
  count   = var.key_vault_name == null ? 1 : 0
  length  = 8
  special = false
  upper   = false
}