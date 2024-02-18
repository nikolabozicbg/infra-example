locals {
  common_tags = {
    Client      = var.client_tag
    Environment = var.environment_tag
    CreatedBy   = "Terraform"
    # CreationDate = timestamp()
    CreationDate         = "2023-01-30T11:37:55Z"
    LastModificationDate = timestamp()
  }
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_security_group" "allow_p8_traffic" {
  name        = "allow_p8_traffic_2023-01-31T11:01:29Z"
  description = "Allow Inbound Traffic from P8 to instance"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "Allow ALL from self subnets"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Allow SSH from P8 VPN"
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      cidr_blocks      = ["91.143.218.42/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow HTTP from anywhere"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow HTTPS from anywhere"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    }
  ]

  egress = [
    {
      description      = "Allow ALL outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = merge(local.common_tags, {
    Name = "allow_p8_traffic"
  })
}

resource "aws_eip" "public-eip" {
  count            = var.reserve_public_eip_address ? 1 : 0
  vpc              = true
  public_ipv4_pool = "amazon"

  tags = merge(local.common_tags, {
    Name      = length(var.instance_name) > 0 ? "${var.instance_name}-eip" : "test-inst-${var.client_blob}-${var.environment_tag}-eip"
  })
}

resource "aws_eip_association" "pub_ip_assoc" {
  instance_id   = aws_instance.ec2-instance.id
  allocation_id = aws_eip.public-eip[0].id
}

resource "aws_instance" "ec2-instance" {
  ami                         = var.ami
  availability_zone           = data.aws_subnet.selected.availability_zone
  ebs_optimized               = false
  instance_type               = var.instance_type
  monitoring                  = false
  key_name                    = var.key_pair_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.allow_p8_traffic.id]
  associate_public_ip_address = var.reserve_public_eip_address || var.automatic_public_ip_address
  private_ip                  = var.private_ip
  secondary_private_ips       = length(var.secondary_private_ips) > 0 ? var.secondary_private_ips : []
  iam_instance_profile        = var.iam_instance_profile
  source_dest_check           = var.source_dest_check

  user_data = file("user_data.sh")

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.volume_size_gb
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = length(var.instance_name) > 0 ? var.instance_name : "test-inst-${var.client_blob}-${var.environment_tag}"
    })
  }

  tags = merge(local.common_tags, {
    Name = length(var.instance_name) > 0 ? var.instance_name : "test-inst-${var.client_blob}-${var.environment_tag}"
  })
}
