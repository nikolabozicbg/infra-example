locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Client       = var.client
    Environment  = var.env
    CreatedBy    = "Terraform"
    CreationDate = timestamp()
    # CreationDate = "2022-09-08T12:07:35Z"
    LastModificationDate = timestamp()
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "*Private*"
  }
}

resource "aws_security_group" "redis_sg" {
  count  = var.use_existing_security_groups == false ? 1 : 0
  vpc_id = var.vpc_id
  name   = join("-", [var.replication_group_id, "security", "group"])

  tags = merge(local.common_tags, {
    Name = "${var.client}-${var.env}-redis-sg"
  })
}

resource "aws_security_group_rule" "egress_sg_rl" {
  count             = var.use_existing_security_groups == false ? 1 : 0
  description       = "Allow outbound traffic from existing cidr blocks"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  security_group_id = join("", aws_security_group.redis_sg.*.id)
  type              = "egress"
}

# resource "aws_security_group_rule" "ingress_security_groups" {
#   count                    = module.this.enabled && var.use_existing_security_groups == false ? length(var.allowed_security_groups) : 0
#   description              = "Allow inbound traffic from existing Security Groups"
#   from_port                = var.port
#   to_port                  = var.port
#   protocol                 = "tcp"
#   source_security_group_id = var.allowed_security_groups[count.index]
#   security_group_id        = join("", aws_security_group.default.*.id)
#   type                     = "ingress"
# }

resource "aws_security_group_rule" "ingress_sg_rl" {
  count             = var.use_existing_security_groups == false ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = var.redis_port
  to_port           = var.redis_port
  protocol          = "tcp"
  cidr_blocks       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  security_group_id = join("", aws_security_group.redis_sg.*.id)
  type              = "ingress"
}

resource "aws_elasticache_subnet_group" "this" {
  name       = join("-", [var.replication_group_id, "subnet", "group"])
  subnet_ids = data.aws_subnets.private.ids
}

resource "aws_elasticache_replication_group" "syllo_redis_cluster" {
  replication_group_id       = var.replication_group_id
  description                = var.replication_group_desc
  node_type                  = var.node_type
  num_cache_clusters         = var.number_of_clusters
  automatic_failover_enabled = var.auto_failover
  auto_minor_version_upgrade = false
  engine_version             = var.redis_version
  port                       = var.redis_port
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  maintenance_window         = "sun:03:00-sun:05:00"
  notification_topic_arn     = var.notifications
  snapshot_window            = "02:00-03:00"
  snapshot_retention_limit   = var.retention_period
  apply_immediately          = var.apply_now
  security_group_ids         = [aws_security_group.redis_sg[0].id]

  tags = merge(local.common_tags, {
    Name = "${var.client}-${var.env}-rg"
  })
}

