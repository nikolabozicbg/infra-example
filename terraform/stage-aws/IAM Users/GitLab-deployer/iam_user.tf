locals {
  common_tags = {
    Client       = var.client_tag
    Environment  = var.environment_tag
    CreatedBy    = "Terraform"
    # CreationDate = timestamp()
    CreationDate = "2022-09-08T10:36:31Z"
    LastModificationDate = timestamp()
  }
}

resource "aws_iam_group" "iam-group" {
  name = var.group_name
  path = "/"
}

resource "aws_iam_user" "iam-user" {
  force_destroy = "false"
  name          = var.user_name
  path          = "/"

  tags = local.common_tags
  tags_all = local.common_tags
}

resource "aws_iam_access_key" "iam-user-key" {
  user = aws_iam_user.iam-user.name
}

resource "aws_iam_user_group_membership" "group-membership" {
  groups = [aws_iam_group.iam-group.name]
  user   = aws_iam_user.iam-user.name
}

resource "aws_iam_policy" "iam-policy" {
  description = "Allow putting objects - Deployment to specified S3 buckets"
  name        = "DeployToS3Buckets"
  path        = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "s3:GetBucketPublicAccessBlock",
        "s3:ListBucketMultipartUploads",
        "s3:GetBucketTagging",
        "s3:GetBucketWebsite",
        "s3:GetObjectVersionTagging",
        "s3:GetBucketLogging",
        "s3:PutObjectVersionTagging",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetBucketAcl",
        "s3:GetBucketNotification",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:GetBucketCORS",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging",
        "s3:GetBucketLocation",
        "s3:GetObjectVersion"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.admin_site_bucket_name}/*",
        "arn:aws:s3:::${var.admin_site_bucket_name}",
        "arn:aws:s3:::${var.web_site_bucket_name}/*",
        "arn:aws:s3:::${var.web_site_bucket_name}"
      ],
      "Sid": "AllowActionsToSpecificS3Buckets"
    },
    {
      "Action": "s3:ListAllMyBuckets",
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "AlowListingOfAllBuckets"
    },
    {
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:kms:eu-west-1:${var.account_id}:key/*"
      ],
      "Sid": "AllowKeyGenerationAndReadingInSpecifiedAccount"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  tags = local.common_tags
  tags_all = local.common_tags
}

resource "aws_iam_group_policy_attachment" "attach_AmazonEC2ContainerRegistryFullAccess" {
  group      = aws_iam_group.iam-group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_group_policy_attachment" "attach_AmazonEKSClusterPolicy" {
  group      = aws_iam_group.iam-group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_group_policy_attachment" "custom-policy-attachment" {
  group      = aws_iam_group.iam-group.name
  policy_arn = aws_iam_policy.iam-policy.arn
}
