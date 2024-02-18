assume_role_arn = "arn:aws:iam::458838185766:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-devops"

client_tag      = "TransFast"
client_blob     = "transfast"
environment_tag = "prod"

ami = "ami-09e2d756e7d78558d" # Amazon Linux 2

vpc_id             = "vpc-0a0196639a8b5bfe0"
availability_zone  = "eu-west-1b"
subnet_id          = "subnet-03991943587995128"
security_group_ids = []
instance_type      = "t3a.micro"
key_pair_name      = "transfast-aws_ed25519"
# This is automatically imported "transfast-stage-aws_ed25519" key pair during EKSCTL cluster creation
# key_pair_name               = "eksctl-transfast-stage-nodegroup-managed-ng-v3-QTyEA4iZ3Dlwl9ouk5ntMqOFHJBVHPARKOS3Xiy0HxU"
associate_public_ip_address = true
private_ip                  = "10.16.32.122"
secondary_private_ips       = []
source_dest_check           = false
iam_instance_profile        = "InstanceProfile"
cpu_credits                 = "unlimited"
volume_size_gb              = 8
