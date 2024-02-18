output "aws_iam-policy_id" {
  value = aws_iam_policy.iam-policy.id
}

output "aws_iam_user" {
  value = <<USER
  User ARN: ${aws_iam_user.iam-user.arn}
  User ID: ${aws_iam_user.iam-user.id}
  User UniqueID: ${aws_iam_user.iam-user.unique_id}
  User Name: ${aws_iam_user.iam-user.name}
  User Access Key ID: ${aws_iam_access_key.iam-user-key.id}
  User Access Key Secret: This value is in 'aws_iam_user_access_key_secret'
                          Get it with: 'terraform output -raw aws_iam_user_access_key_secret'
  USER
}

output "aws_iam_user_access_key_secret" {
  value     = aws_iam_access_key.iam-user-key.secret != null ? aws_iam_access_key.iam-user-key.secret : "This user was probably imported so state holds no data.\n"
  sensitive = true
}
