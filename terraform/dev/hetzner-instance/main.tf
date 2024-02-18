data "vault_generic_secret" "hcloud_token" {
  path = var.hcloud_token_path
}

provider "hcloud" {
  token = data.vault_generic_secret.hcloud_token.data[var.hcloud_token_name]
}

# Resource random to generate random characters
resource "random_string" "name" {
  length  = 6
  special = false
  upper   = false
}

# The designation of the name, which is built from the variable name + environment terraform + result random
locals {
  instance_name = "${var.client}-${var.project}-${var.env}"
}
