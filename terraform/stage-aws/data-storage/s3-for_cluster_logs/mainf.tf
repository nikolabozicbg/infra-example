locals {
  bucket_name = "${var.client_blob}-${var.bucket_name_id}"

  common_tags = {
    Client      = var.client
    Environment = var.env
    CreatedBy   = "Terraform"
    # CreationDate = timestamp()
    CreationDate = "2022-09-06T23:26:53Z"
    LastModificationDate = timestamp()
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(local.common_tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket" "s3_bucket" {

  bucket        = local.bucket_name
  force_destroy = false

  tags = merge(local.common_tags, {
    Name = local.bucket_name
  })

  # This was disabled temporary for apps access to files without the key
  #
  #  server_side_encryption_configuration = {
  #    rule = {
  #      apply_server_side_encryption_by_default = {
  #        sse_algorithm = "aws:kms"
  #      }
  #    }
  #  }

}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]

    sid = "PolicyToAllowAllWithAssumedRole"
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        var.clster_role_arn,
        var.nodeinstance_role_arn
        ]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]

    sid = "PolicyToAllowUploadForCLuster"
  }

  statement {

    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::156460612806:root"] # ID of the AWS ELB account for Ireland
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/alb-access-logs/*",
    ]

    sid = "PolicyToAllowLoadBalancersLogging"
  }
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

# I think, becouse Policy has to be serialized, it updates this
# resource every time tf plan or apply is run!
resource "aws_s3_bucket_policy" "define_access_to_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_public_access_block" "bucket-public-block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      # kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycles" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.s3_bucket_versioning]

  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    id      = "logs_retention-transition_rule"

    # filter {
    #   prefix  = "logs"
    # }

    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    # After 1 day delete the expired files
    expiration {
      days                         = var.data_retention_days
      expired_object_delete_marker = false
    }

    # To save some budget, transition objects likely to use less often to AWS Glacier.
    # Glacier is a lot cheaper than S3 but comes with slower access times.
    transition {
      days          = var.move_to_glacier
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
