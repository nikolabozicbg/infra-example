assume_role_arn = "arn:aws:iam::309602515679:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-stage-devops"

client = "transfast"
env    = "stage"

bucket_name_id  = "transfast-syllo-uploads"
clster_role_arn = "arn:aws:iam::309602515679:role/eksctl-transfast-stage-cluster-ServiceRole-1AX2VIBFRBIK1"
allow_user_arn  = "arn:aws:iam::309602515679:user/transfast-s3-fs-bucket-acces"
