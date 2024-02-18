# Hetzner Instance with Init Scripts

This repo holds a FULL Terraform solution to lift and configure an instance on Hetzner Cloud

For now, just copy all files from here to a subfolder inside clients project.

For example into:
{the_client_name}-infra/Terraform/{dev, stage, qa}/hetzner_instance/.

NOTE:
The `Terraform` folder of the client project should already have:

-  `terragrunt.hcl` file so that the state files can be safely stored in AWS s3.

```terragrunf.hcl
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = "<SOME_NAME>-tfstate-storage"                        # EDIT THIS FOR THE PROJECT

    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"                                  # EDIT THIS FOR THE PROJECT
    encrypt        = true
    dynamodb_table = "<SOME_NAME>_terraform_locks_table"          # EDIT THIS FOR THE PROJECT
  }
}

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
```

-  variables.tf

```variables.tf
variable "assume_role_arn" {
  type        = string
  description = "ARN from AWS for the role to assume"
}

variable "aws_region" {
  description = "Specify AWS Region"
  type        = string
}

variable "aws_profile" {
  description = "Specify AWS profile with propper credentials"
  type        = string
}
```

-  variables.auto.tfvars

```variables.auto.tf
assume_role_arn = "arn:aws:iam::<AWS_ACCOUT_NUMBER>:role/<AWS_IAM_ROLE_NAME>"
aws_region      = "eu-west-1"
aws_profile     = "<AWS_IAM_CLI_PROFILE_NAME>"
```
