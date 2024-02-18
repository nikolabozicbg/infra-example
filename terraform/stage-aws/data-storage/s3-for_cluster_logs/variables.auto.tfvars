assume_role_arn = "arn:aws:iam::309602515679:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-stage-devops"

client      = "TransFast"
client_blob = "transfast"
env         = "stage"

bucket_name_id        = "cluster-logs"
clster_role_arn = "arn:aws:iam::309602515679:role/eksctl-transfast-stage-cluster-ServiceRole-1AX2VIBFRBIK1"
nodeinstance_role_arn = "arn:aws:iam::309602515679:role/eksctl-transfast-stage-nodegroup-NodeInstanceRole-MD57VT1R68MF"

data_retention_days = 180
move_to_glacier     = 45 # after 15 days move data to glacier before deletion
