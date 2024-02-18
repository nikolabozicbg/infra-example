# Outputs

aws_iam-policy_id = "arn:aws:iam::309602515679:policy/AllowS3BucketObjectSigning"
aws_iam_user = <<EOT
User ARN: arn:aws:iam::309602515679:user/transfast-s3-fs-sign-only
User ID: transfast-s3-fs-sign-only
User UniqueID: AIDAUQFN7PLP5FPP7ARLL
User Name: transfast-s3-fs-sign-only
User Access Key ID: AKIAUQFN7PLPX5JZHGRQ
User Access Key Secret: This value is in 'aws_iam_user_access_key_secret'
Get it with: 'terraform output -raw aws_iam_user_access_key_secret'

EOT
aws_iam_user_access_key_secret = <sensitive>
