# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
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
