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
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Name = "*Private*"
  }
}

resource "aws_docdb_subnet_group" "syllo_sg" {
  name        = join("-", [var.client_blob, var.env, "mongo", "subnet", "group"])
  description = "Private subnet group used for Mongo cluster deployment. Managed by Terraform!"
  subnet_ids  = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : data.aws_subnets.private.ids

  tags = merge(local.common_tags, {
    "Name" = "${var.client}-${var.env}-mongo-subnet-group"
  })
}

resource "aws_docdb_cluster_parameter_group" "syllo_pg" {
  name        = join("-", [var.client_blob, var.env, "mongo", "param", "group"])
  family      = var.docdb_param_group_engine_version
  description = "Parameters group used for Mongo cluster. Managed by Terraform!"

  parameter {
    name  = "tls"
    value = var.param_group_tls_value
  }

  tags = merge(local.common_tags, {
    "Name" = "${var.client}-${var.env}-mongo-param-group"
  })
}

resource "aws_security_group" "mongo_sg" {
  vpc_id = var.vpc_id
  name   = join("-", [var.client, var.env, "mongo", "security", "group"])

  tags = merge(local.common_tags, {
    Name = "${var.client}-${var.env}-mongo-sg"
    }
  )
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow outbound traffic from existing cidr blocks"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.mongo_sg.id
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = var.mongo_port
  to_port           = var.mongo_port
  protocol          = "tcp"
  cidr_blocks       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.mongo_sg.id
  type              = "ingress"
}

resource "aws_docdb_cluster" "syllo" {
  cluster_identifier              = join("-", [var.client_blob, var.env, "mongo", "cluster"])
  db_subnet_group_name            = aws_docdb_subnet_group.syllo_sg.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.syllo_pg.name
  engine_version                  = var.docdb_engine_version
  storage_encrypted               = var.storage_encryption # TODO: To be enabled if needed
  kms_key_id                      = var.kms_key_arn        # TODO: Apply proper key if needed
  master_password                 = data.vault_generic_secret.vault_secrets.data[var.password]
  master_username                 = data.vault_generic_secret.vault_secrets.data[var.username]
  port                            = var.mongo_port
  backup_retention_period         = var.retention_period
  preferred_backup_window         = var.backup_window
  deletion_protection             = true
  skip_final_snapshot             = false
  vpc_security_group_ids          = [aws_security_group.mongo_sg.id]
  apply_immediately               = var.apply_immediately # TODO: Change before going live
  # enabled_cloudwatch_logs_exports = [ "audit", "profiler" ] TODO: Uncomment once live

  tags = merge(local.common_tags, {
    Name = "${var.client}-${var.env}-mongo-cluster"
    }
  )
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count                        = var.instances_count
  cluster_identifier           = aws_docdb_cluster.syllo.id
  identifier_prefix            = "${var.client_blob}-${var.env}-mongo-instance-"
  instance_class               = var.cluster_instance_size
  preferred_maintenance_window = var.instance_maintenance_window
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = var.apply_immediately # TODO: Change before going live

  tags = merge(local.common_tags, {
    Name = "${var.client}-${var.env}-mongo-instance"
    }
  )
}
