assume_role_arn = "arn:aws:iam::458838185766:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-devops"

client = "transfast"
env    = "prod"

bucket_name_id  = "transfast-prod-syllo-uploads"
clster_role_arn = "arn:aws:iam::458838185766:role/eksctl-transfast-cluster-ServiceRole-1RSDDR12Y3RTR"
allow_user_arn  = "arn:aws:iam::458838185766:user/transfast-s3-fs-bucket-acces"
