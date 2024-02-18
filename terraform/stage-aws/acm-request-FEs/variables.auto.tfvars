assume_role_arn = "arn:aws:iam::309602515679:role/Terraform-Assume-Role"
#aws_region      = "us-east-1" # Globalmust be set for CloudFront
aws_region  = "us-east-1" # Local to the region of the app if it is not CloudFront
aws_profile = "transfast-stage-devops"

client                    = "transfast"
env                       = "pen"
domain_name               = "*.pen.pannovate.net"
subject_alternative_names = ["*.pannovate.net"]
