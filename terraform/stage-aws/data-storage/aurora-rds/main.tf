
locals {

  # Common tags to be assigned to all resources
  common_tags = {
    Client       = var.client
    Environment  = var.env
    CreatedBy    = "Terraform"
    CreationDate = timestamp()
  }
}

data "vault_generic_secret" "vault_secrets" {
  path = var.vault_secrets_key
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Name = "*Private*"
  }
}

module "rds-aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "5.3.0"

  name = var.rds_cluster_name

  engine                          = var.aurora_engine
  engine_version                  = var.aurora_engine_version
  subnets                         = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : data.aws_subnets.private.ids
  vpc_id                          = var.vpc_id
  replica_count                   = var.replica_count
  replica_scale_enabled           = true
  replica_scale_min               = var.replica_scale_min
  replica_scale_max               = var.replica_scale_max
  monitoring_interval             = 60
  instance_type                   = var.main_instance_type
  instance_type_replica           = var.replica_instance_type
  database_name                   = data.vault_generic_secret.vault_secrets.data[var.database_name_val]
  kms_key_id                      = var.kms_key_arn
  create_random_password          = false
  username                        = data.vault_generic_secret.vault_secrets.data[var.master_username_val]
  password                        = data.vault_generic_secret.vault_secrets.data[var.master_password_val]
  apply_immediately               = var.apply_immediately
  skip_final_snapshot             = var.skip_final_snapshot
  #db_parameter_group_name         = aws_db_parameter_group.aurora_db_postgres124_parameter_group.id
  db_parameter_group_name         = aws_db_parameter_group.aurora_db_postgres14_parameter_group.id
  # db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_postgres124_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_postgres14_parameter_group.id
  #  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  tags = merge(local.common_tags, {
    Name = "${var.client}-${var.env}-rds"
  })
}

# resource "aws_db_parameter_group" "aurora_db_postgres124_parameter_group" {
#   name        = "aurora-db-postgres12-parameter-group"
#   family      = "aurora-postgresql12"
#   description = "aurora-db-postgres12-parameter-group"

#   tags = merge(local.common_tags, {
#     Name = "${var.client}-${var.env}-db_pg"
#   })
# }

resource "aws_db_parameter_group" "aurora_db_postgres14_parameter_group" {
  name        = "aurora-db-postgres14-parameter-group"
  family      = "aurora-postgresql14"
  description = "aurora-db-postgres14-parameter-group"

  tags = merge(local.common_tags, {
    Name = "${var.client}-${var.env}-db_pg"
  })
}

# resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres124_parameter_group" {
#   name        = "aurora-postgres12-cluster-parameter-group"
#   family      = "aurora-postgresql12"
#   description = "aurora-postgres12-cluster-parameter-group"

#   tags = merge(local.common_tags, {
#     Name = "${var.client}-${var.env}-rds_pg"
#   })
# }

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres14_parameter_group" {
  name        = "aurora-postgres14-cluster-parameter-group"
  family      = "aurora-postgresql14"
  description = "aurora-postgres14-cluster-parameter-group"

  tags = merge(local.common_tags, {
    Name = "${var.client}-${var.env}-rds_pg"
  })
}

#### Security group settings ####

resource "aws_security_group_rule" "allow_access" {
  description = "Allow inbound from VPC"
  type        = "ingress"

  from_port         = module.rds-aurora.rds_cluster_port # this_rds_cluster_port
  to_port           = module.rds-aurora.rds_cluster_port # this_rds_cluster_port
  protocol          = "tcp"
  cidr_blocks       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  security_group_id = module.rds-aurora.security_group_id # this_security_group_id
  # source_security_group_id = aws_security_group.app_servers.id
}

resource "aws_security_group_rule" "allow_egress" {
  description = "Allow all towards VPC"
  type        = "egress"

  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  security_group_id = module.rds-aurora.security_group_id # this_security_group_id
}

# resource "aws_security_group" "app_servers" {
#   name        = var.rds_sg_name
#   description = "For application servers"
#   vpc_id      = var.vpc_id

#   tags = merge(local.common_tags, {
#     Name = var.rds_sg_name
#   })
# }

# resource "aws_security_group_rule" "egress" {
#   description       = "Allow outbound traffic from existing cidr blocks"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = [data.aws_vpc.selected.cidr_block]
#   security_group_id = aws_security_group.app_servers.id
#   type              = "egress"
# }

# resource "aws_security_group_rule" "ingress_cidr_blocks" {
#   description       = "Allow inbound traffic from CIDR blocks"
#   from_port         = module.rds-aurora.this_rds_cluster_port
#   to_port           = module.rds-aurora.this_rds_cluster_port
#   protocol          = "tcp"
#   cidr_blocks       = [data.aws_vpc.selected.cidr_block]
#   security_group_id = aws_security_group.app_servers.id
#   type              = "ingress"
# }
