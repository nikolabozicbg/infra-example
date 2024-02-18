# Outputs

aws_iam-policy_id = "arn:aws:iam::458838185766:policy/AllowS3BucketUploads"
aws_iam_user = <<EOT
User ARN: arn:aws:iam::458838185766:user/transfast-s3-fs-bucket-acces
User ID: transfast-s3-fs-bucket-acces
User UniqueID: AIDAWVVHDC4TBZVG2ZXOP
User Name: transfast-s3-fs-bucket-acces
User Access Key ID: AKIAWVVHDC4TAHSF7W6L
User Access Key Secret: This value is in 'aws_iam_user_access_key_secret'
Get it with: 'terraform output -raw aws_iam_user_access_key_secret'

EOT
aws_iam_user_access_key_secret = <sensitive>
