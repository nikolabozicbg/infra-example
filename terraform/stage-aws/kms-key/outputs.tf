output "aws_kms_key_id" {
  value = aws_kms_key.kms-key.id
}

output "aws_kms_key_alias_id" {
  value = aws_kms_alias.kms-key-alias.id
}

output "aws_kms_key_arn" {
  value = aws_kms_key.kms-key.arn
}
