assume_role_arn = "arn:aws:iam::458838185766:role/Terraform-Assume-Role"
aws_region      = "eu-west-1"
aws_profile     = "transfast-devops"

client = "transfast"
env    = "prod"

vpc_id = "vpc-0a0196639a8b5bfe0"

# Optionally specify overrides for default values that are extracted from existing aws resources
allow_ingress_cidr_blocks = ["10.16.0.0/16"] # optional - default is []

replication_group_id         = "transfast-redis-cluster"
node_type                    = "cache.t3.micro"
number_of_clusters           = "1"
auto_failover                = false
replication_group_desc       = "Syllo Elasticache Redis Cluster"
redis_version                = "6.x"
redis_port                   = 6379
notifications                = ""
retention_period             = 7
apply_now                    = true # Change to false once deployed
use_existing_security_groups = false
