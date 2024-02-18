# Variables AREN'T allowed in a backend configuration.
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = "transfast-tf-state" # Edit this

    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1" # Edit this
    encrypt        = true
    dynamodb_table = "transfast-state-lock" # Edit this
  }
}

# Variables ARE allowed in a provider configuration.
generate "provider" {
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
EOF
}

generate "versions" {
  path     = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents =<<EOF
terraform {
  required_version = ">= 1.3.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.38.0"
    }
  }
}
EOF
}
