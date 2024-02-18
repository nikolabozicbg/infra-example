assume_role_arn = "arn:aws:iam::458838185766:role/Terraform-Assume-Role"
#aws_region      = "us-east-1" # Globalmust be set for CloudFront
aws_region  = "eu-west-1" # Local to the region of the app if it is not CloudFront
aws_profile = "transfast-devops"

client                    = "transfast"
env                       = "prod"
domain_name               = "api.transfast.pannovate.net"
subject_alternative_names = ["api.transfast.pannovate.net"]
