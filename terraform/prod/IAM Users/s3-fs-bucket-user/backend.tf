# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "transfast-tf-state"
    dynamodb_table = "transfast-state-lock"
    encrypt        = true
    key            = "prod/IAM Users/s3-fs-bucket-user/terraform.tfstate"
    region         = "eu-west-1"
  }
}
