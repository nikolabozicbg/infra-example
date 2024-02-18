assume_role_arn = "arn:aws:iam::458838185766:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-devops"

client = "TransFast"
env    = "prod"

# IN ORDER FOR VAULT TO WORK, AN ENVIRONMENT VARIABLE "VAULT_TOKEN=" OR A FILE "~/.vault-token" NEED TO HAVE A TOKEN.
# THAT TOKEN SHOULD BE OBTAINED FROM A VAULT INTERFACE AND WILL EXPIRE BASED ON THE VAULT SETTINGS
# example:
#      $ export VAULT_TOKEN=12345asdf09876
#
vault_secrets_key = "clients/TransFast/Live/AuroraRDS"


vpc_id = "vpc-0a0196639a8b5bfe0"

# Optionally specify overrides for default values that are extracted from existing aws resources
private_subnet_ids        = []               # optional default is []
allow_ingress_cidr_blocks = ["10.16.0.0/16"] # optional - default is []

replica_count         = 1
replica_scale_min     = 1
replica_scale_max     = 5
rds_cluster_name      = "transfast-rds"
database_name_val     = "DB_Name"
master_username_val   = "Master_Username"
master_password_val   = "Master_Password"
apply_immediately     = true # Change to false once deployed
skip_final_snapshot   = false
main_instance_type    = "db.t3.medium"
replica_instance_type = "db.t3.medium"
aurora_engine         = "aurora-postgresql"
aurora_engine_version = "14.3"
kms_key_arn           = "arn:aws:kms:eu-west-1:458838185766:key/646ae6bb-a109-485c-805e-4b8e743016f9"
rds_sg_name           = "rds-transfast-sg"
