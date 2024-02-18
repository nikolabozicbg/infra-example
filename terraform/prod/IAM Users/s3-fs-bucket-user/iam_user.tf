locals {
  common_tags = {
    Client       = var.client_tag
    Environment  = var.environment_tag
    CreatedBy    = "Terraform"
    # CreationDate = timestamp()
    CreationDate = "2022-11-08T19:22:32Z"
    LastModificationDate = timestamp()
  }
}

resource "aws_iam_user" "iam-user" {
  force_destroy = "false"
  name          = var.user_name
  path          = "/"

  tags = local.common_tags
}

resource "aws_iam_access_key" "iam-user-key" {
  user = aws_iam_user.iam-user.name
}

resource "aws_iam_policy" "iam-policy" {
  description = "Allow the uploads to the bucket for app uploads and fs service"
  name        = "AllowS3BucketUploads"
  path        = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "s3:ListBucketMultipartUploads",
        "s3:GetObjectRetention",
        "s3:GetObjectVersionTagging",
        "s3:ListBucketVersions",
        "s3:GetBucketLogging",
        "s3:ListBucket",
        "s3:GetObjectLegalHold",
        "s3:GetBucketAcl",
        "s3:GetBucketNotification",
        "s3:ListMultipartUploadParts",
        "s3:GetObjectVersionTorrent",
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:GetObjectTorrent",
        "s3:GetBucketCORS",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectTagging",
        "s3:GetObjectVersionForReplication",
        "s3:GetBucketLocation",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:PutObjectRetention"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.uploads_bucket_name}/*",
        "arn:aws:s3:::${var.uploads_bucket_name}"
      ],
      "Sid": "AllowRWOnSpecifiedS3Buckets"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  tags = local.common_tags
}

resource "aws_iam_user_policy_attachment" "user-policy-attachment" {
  policy_arn = aws_iam_policy.iam-policy.arn
  user       = aws_iam_user.iam-user.name
}
