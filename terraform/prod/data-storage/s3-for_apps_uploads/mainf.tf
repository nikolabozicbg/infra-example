
locals {
  bucket_name = "s3-bucket-${var.bucket_name_id}"

  common_tags = {
    Client      = var.client
    Environment = var.env
    CreatedBy   = "Terraform"
    # CreationDate = timestamp()
    CreationDate         = "2022-09-08T11:32:51Z"
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
      identifiers = [var.clster_role_arn]
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
      identifiers = ["${var.allow_user_arn}"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]

    sid = "PolicyToAllowUploadForUser"
  }
}

# I think, becouse Policy has to be serialized, it updates this
# resource every time tf plan or apply is run!
resource "aws_s3_bucket_policy" "define_access_to_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "bucket-public-block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycles" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.s3_bucket_versioning]

  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    id      = "CleanUp-Downloads-Reports-after-1d"

    filter {
      prefix  = "downloads/reports/"
    }

    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    # After 1 day delete the expired files
    expiration {
      days                         = 1
      expired_object_delete_marker = false
    }

    noncurrent_version_expiration {
      # newer_noncurrent_versions = 1
      noncurrent_days                      = 1
    }
  }
}
