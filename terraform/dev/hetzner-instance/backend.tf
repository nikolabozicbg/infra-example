# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "transfast-tf-state"
    dynamodb_table = "transfast-state-lock"
    encrypt        = true
    key            = "dev/hetzner-instance/terraform.tfstate"
    region         = "eu-west-1"
  }
}
