include {
  path = find_in_parent_folders()
}

generate provider {
	path = "provider.tf"
	if_exists = "overwrite_terragrunt"
	contents = <<EOF
provider "aws" {
	assume_role {
		role_arn = var.assume_role_arn
	}
	region = var.aws_region
	profile = var.aws_profile
}
provider "vault" {
	address = var.vault_address
}
EOF
}
