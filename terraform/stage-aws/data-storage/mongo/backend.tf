# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "transfast-stage-tf-state"
    dynamodb_table = "transfast-stage-state-lock"
    encrypt        = true
    key            = "data-storage/mongo/terraform.tfstate"
    region         = "eu-west-1"
  }
}
