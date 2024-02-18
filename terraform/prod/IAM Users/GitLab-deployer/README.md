# Outputs

aws_iam-policy_id = "arn:aws:iam::458838185766:policy/DeployToS3Buckets"
aws_iam_group = <<EOT
Group ID: Deployers
Group UniqueID: AGPAWVVHDC4TCSPAOJERX
Group Name: Deployers

EOT
aws_iam_user = <<EOT
User ID: transfast-gitlab-deployer
User UniqueID: AIDAWVVHDC4TC7ALFR4OL
User Name: transfast-gitlab-deployer
User Access Key ID: AKIAWVVHDC4TFSX32GXU
User Access Key Secret: This value is in 'aws_iam_user_access_key_secret'
Get it with: 'terraform output -raw aws_iam_user_access_key_secret'

EOT
aws_iam_user_access_key_secret = <sensitive>
