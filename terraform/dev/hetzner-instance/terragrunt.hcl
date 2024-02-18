include {
	path = find_in_parent_folders()
}

generate "versions" {
	path = "versions.tf"
	if_exists = "overwrite_terragrunt"
	contents = <<EOF
terraform {
  required_version = ">= 1.1.6"

  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.31.1"
    }

    vault = {
      source = "hashicorp/vault"
      version = "3.3.1"
    }
  }
}
EOF
}

generate provider {
	path = "provider.tf"
	if_exists = "overwrite_terragrunt"
	contents = <<EOF
provider "vault" {
	address = var.vault_address
}
EOF
}
