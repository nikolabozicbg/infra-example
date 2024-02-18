assume_role_arn = "arn:aws:iam::458838185766:role/Terraform-Assume-Role"
aws_region      = "us-east-1" # For CloudFront, this has to be in 'us-east-1' regiao and not in the region of the CLient
aws_profile     = "transfast-devops"

client      = "transfast"
env         = "prod"
domain_name = "admin-transfast.pannovate.net"
