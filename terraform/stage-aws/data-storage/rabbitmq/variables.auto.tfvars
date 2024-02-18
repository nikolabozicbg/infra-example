assume_role_arn = "arn:aws:iam::309602515679:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-stage-devops"

client = "transfast"
env    = "stage"

vault_secrets_key = "clients/TransFast/Live/RabbitMQ"

# REQUIRED
broker_name = "TransFast-RabbitMQ-Broker" # Required
# engine_type = "RabbitMQ" # {ActiveMQ | RabbitMQ } Required
engine_version = "3.9.24"                # Required see AmazonMQ Broker Engine docs: https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/broker-engine.html
instance_type  = "mq.t3.micro"           # { mq.t3.micro | mq.m5.large | ... } Required
username       = "syllo_mquser_name"     # Required
password       = "syllo_mquser_password" # Required - cannot contain special characters

# OPTIONAL
apply_now                    = true              # Optional. Change to false once deployed. AWS default: false
auto_minor_version_upgrade   = false              # Optional. AWS default: true
deployment_mode              = "SINGLE_INSTANCE" # { SINGLE_INSTANCE | ACTIVE_STANDBY_MULTI_AZ | CLUSTER_MULTI_AZ } Optional. AWS default: SINGLE_INSTANCE
publicly_accessible          = false             # Optional
vpc_id                       = "vpc-0988da09e0727ca06"
allow_ingress_cidr_blocks    = ["10.18.0.0/16"] # optional - default is [] which auto-selects VPCs CIDR
use_custom_port              = 5671
use_existing_security_groups = false
security_groups              = [] # Optional
subnet_ids                   = [] # Optional. One or more IDs

maintenance_window_start = {
  day_of_week = "SUNDAY", # MONDAY, TUESDAY, WEDNESDAY ....
  time_of_day = "04:00",  # Time, in 24-hour format, e.g., 02:00.
  time_zone   = "UTC"     # Time zone in either the Country/City format or the UTC offset format, e.g., CET.
}

additional_tags = {} # Optional

custom_kms_arn = "" # Optional. If left empty, use_aws_owned_key will be left true and will use AWS generated KMS. If this is set to custom ARN, use_aws_owned_key has to be set to false.

