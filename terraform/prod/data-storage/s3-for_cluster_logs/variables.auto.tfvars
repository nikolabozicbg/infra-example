assume_role_arn = "arn:aws:iam::458838185766:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-devops"

client      = "TransFast"
client_blob = "transfast"
env         = "prod"

bucket_name_id        = "prod-cluster-logs"
nodeinstance_role_arn = "arn:aws:iam::458838185766:role/eksctl-transfast-nodegroup-manage-NodeInstanceRole-1I38DW2G0YY69"
clster_role_arn       = "arn:aws:iam::458838185766:role/eksctl-transfast-cluster-ServiceRole-1RSDDR12Y3RTR"

data_retention_days = 180
move_to_glacier     = 45 # after 15 days move data to glacier before deletion
