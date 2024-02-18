assume_role_arn = "arn:aws:iam::458838185766:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-devops"

client      = "TransFast"
client_blob = "transfast"
env         = "prod"

cluster_role_arn = "arn:aws:iam::458838185766:role/eksctl-transfast-cluster-ServiceRole-1RSDDR12Y3RTR"

cf_enabled                  = true
cf_name                     = "transfast.pannovate.net"
cf_aliases                  = ["transfast.pannovate.net"]
cf_comment                  = "TransFast Client Portal"
cf_cert_arn                 = "arn:aws:acm:us-east-1:458838185766:certificate/dab02d4f-52f2-4d2a-930c-7ec27c880a71"
cf_minimum_protocol_version = "TLSv1.2_2021"
cf_enable_ipv6              = false # Must be FALSE if IPv4 whitelisting is used
allow_extra_origins         = []    # Add here any additional urls that will acces the bucket
bucket_name_id              = "transfast.pannovate.net"
existing_log_bucket_id      = "transfast-prod-websites-logs-bucket" # created when admin CF was initialized
s3_origin                   = "transfast-website-s3"
s3_acces_role_arn           = "arn:aws:iam::458838185766:user/transfast-gitlab-deployer"
data_retention_days         = 180
move_to_glacier             = 15 # after 15 days move data to glacier before deletion

# For WAFv2 use ARN and for WAF use ID
#web_acl_id = "arn:aws:wafv2:us-east-1:638127564853:global/webacl/ab-admin-acl/4bb78c70-822b-49df-9e8c-333baa855ff7"

# For aditional HSTS Security headers Lambda@edge has to be used
hsts_lambda_arn = "arn:aws:lambda:us-east-1:458838185766:function:HSTS_Headers:1"
