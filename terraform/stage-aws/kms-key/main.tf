resource "aws_kms_key" "kms-key" {
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "${var.client_blob}-${var.environment_tag}-key"
  enable_key_rotation      = "false"
  is_enabled               = "true"
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = <<EOF
{
  "Id": "key-consolepolicy-3",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.client_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access for Key Administrators",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.client_id}:role/OrganizationAccountAccessRole",
          "arn:aws:iam::${var.client_id}:user/${var.aws_profile}"
        ]
      },
      "Action": [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.client_id}:role/OrganizationAccountAccessRole",
          "arn:aws:iam::${var.client_id}:user/${var.aws_profile}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.client_id}:role/OrganizationAccountAccessRole",
          "arn:aws:iam::${var.client_id}:user/${var.aws_profile}"
        ]
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
EOF

  tags = {
    Client = "${var.client_blob}-${var.environment_tag}"
    Name   = "${var.client_blob}-${var.environment_tag}-key"
  }

}

resource "aws_kms_alias" "kms-key-alias" {
  name          = "alias/${var.client_blob}-${var.environment_tag}-key"
  target_key_id = aws_kms_key.kms-key.key_id
}
