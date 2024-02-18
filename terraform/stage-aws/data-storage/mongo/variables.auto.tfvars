assume_role_arn = "arn:aws:iam::309602515679:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-stage-devops"

client      = "TransFast"
client_blob = "transfast"
env         = "stage"

# IN ORDER FOR VAULT TO WORK, AN ENVIRONMENT VARIABLE "VAULT_TOKEN=" OR A FILE "~/.vault-token" NEED TO HAVE A TOKEN.
# THAT TOKEN SHOULD BE OBTAINED FROM A VAULT INTERFACE AND WILL EXPIRE BASED ON THE VAULT SETTINGS
# example:
#      $ export VAULT_TOKEN=12345asdf09876
#
vault_secrets_key = "clients/TransFast/Live/DocumentDBMongo"

vpc_id = "vpc-0988da09e0727ca06"

# Optionally specify overrides for default values that are extracted from existing aws resources
private_subnet_ids        = []               # optional default is []
allow_ingress_cidr_blocks = ["10.18.0.0/16"] # optional - default is []

docdb_engine_version             = "4.0.0"
docdb_param_group_engine_version = "docdb4.0"
param_group_value_change_method  = "pending-reboot"
param_group_tls_value            = "disabled"
storage_encryption               = true
kms_key_arn                      = "arn:aws:kms:eu-west-1:309602515679:key/b0012478-3a66-4881-8986-ec3f8ea3eb2a" # If ser to KMS ARN then storage_encryption must be true
username                         = "Master_username"
password                         = "Master_userpassword" # copy Password from Vault here
mongo_port                       = 27130
cluster_instance_size            = "db.t3.medium"
instances_count                  = 1 # To scale accordingly after testing
backup_window                    = "02:00-07:00"
retention_period                 = 1
instance_maintenance_window      = "sun:02:00-sun:04:00"
auto_minor_version_upgrade       = false
apply_immediately                = true # Keep as false in PROD environment
