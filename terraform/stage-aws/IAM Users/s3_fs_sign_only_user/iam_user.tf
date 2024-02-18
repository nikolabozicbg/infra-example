locals {
  common_tags = {
    Client       = var.client_tag
    Environment  = var.environment_tag
    CreatedBy    = "Terraform"
    CreationDate = timestamp()
    # CreationDate = "2021-11-24T10:56:52Z"
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
  name        = "AllowS3BucketObjectSigning"
  path        = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.uploads_bucket_name}/*",
        "arn:aws:s3:::${var.uploads_bucket_name}"
      ],
      "Sid": "AllowGetAndSigninObjects"
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
