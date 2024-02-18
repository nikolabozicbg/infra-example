assume_role_arn = "arn:aws:iam::309602515679:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-stage-devops"

billing_code_tag = "TransFast"
client           = "TransFast"
client_blob      = "transfast"
environment_tag  = "stage"

repos_list     = ["api-gateway", "as", "config", "cs", "els", "fs", "kyc", "mps", "ps", "pubsub", "webhook"]
scan_on_push   = true
tag_mutability = "MUTABLE"
enc_type       = "AES256"
enc_key        = "" # optional
