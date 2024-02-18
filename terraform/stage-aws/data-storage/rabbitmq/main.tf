locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Client      = var.client
    Environment = var.env
    CreatedBy   = "Terraform"
    # CreationDate = timestamp()
    CreationDate = "2021-12-09T20:58:41Z"
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

data "aws_subnet" "private_1a" {
  filter {
    name   = "tag:Name"
    values = ["*Private*1A*"]
  }
}

#[ for s in data.aws_subnet.from_private : s.id][0]

resource "aws_mq_broker" "rabbitmq" {
  broker_name = var.broker_name

  # Configuration is not supported by AWS for Rabbit MQ
  # configuration {
  #   id       = aws_mq_configuration.test.id
  #   revision = aws_mq_configuration.test.latest_revision
  # }

  engine_type                = var.engine_type
  engine_version             = var.engine_version
  host_instance_type         = var.instance_type
  apply_immediately          = var.apply_now
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  deployment_mode            = var.deployment_mode
  publicly_accessible        = var.publicly_accessible
  security_groups            = (var.use_existing_security_groups == true && length(var.security_groups) > 0) ? var.security_groups : [aws_security_group.sgr[0].id]
  subnet_ids                 = length(var.subnet_ids) > 0 ? var.subnet_ids : [data.aws_subnet.private_1a.id]
  #storage_type               = ""

  # NOTE:
  # AWS currently does not support updating RabbitMQ users.
  # Updates to users can only be in the RabbitMQ UI.
  user {
    username = data.vault_generic_secret.vault_secrets.data[var.username]
    password = data.vault_generic_secret.vault_secrets.data[var.password]
    # Applies to engine_type of ActiveMQ only.
    # console_access = false # (Optional) Whether to enable access to the ActiveMQ Web Console for the user.
    # groups = [] # (Optional) List of groups (20 maximum) to which the ActiveMQ user belongs.
  }

  # NOTE:
  # Amazon MQ currently does not support updating the maintenance window.
  # Changes to the maintenance window start time will force a new broker to be created.
  maintenance_window_start_time {
    day_of_week = var.maintenance_window_start.day_of_week
    time_of_day = var.maintenance_window_start.time_of_day
    time_zone   = var.maintenance_window_start.time_zone
  }

  # encryption_options {
  #   kms_key_id        = var.custom_kms_arn
  #    use_aws_owned_key = length(var.custom_kms_arn) > 0 ? false : true
  # }

  logs { #   Audit logging is not supported for RabbitMQ brokers.
    general = true
    #audit   = false
  }

  tags = merge(
    local.common_tags,
    var.additional_tags
  )
}

resource "aws_security_group" "sgr" {
  count  = (var.use_existing_security_groups == false || length(var.security_groups) == 0) ? 1 : 0
  vpc_id = var.vpc_id
  name   = join("-", ["rabbitmq", "security", "group"])

  tags = merge(local.common_tags, {
    Name = "${var.client}-${var.env}-rabbitmq-sg"
  })
}

resource "aws_security_group_rule" "egress_sg_rl" {
  count             = (var.use_existing_security_groups == false || length(var.security_groups) == 0) ? 1 : 0
  description       = "Allow outbound traffic from existing cidr blocks"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  security_group_id = join("", aws_security_group.sgr.*.id)
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

resource "aws_security_group_rule" "ingress_sr_rl" {
  count             = var.use_existing_security_groups == false ? 1 : 0
  description       = "Allow RabbitMQ inbound traffic from CIDR blocks"
  from_port         = var.use_custom_port
  to_port           = var.use_custom_port
  protocol          = "tcp"
  cidr_blocks       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  security_group_id = join("", aws_security_group.sgr.*.id)
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_sr_rl_https" {
  count             = var.use_existing_security_groups == false ? 1 : 0
  description       = "Allow HTTPS inbound traffic from CIDR blocks"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  security_group_id = join("", aws_security_group.sgr.*.id)
  type              = "ingress"
}
