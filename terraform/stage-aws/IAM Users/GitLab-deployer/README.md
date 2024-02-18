# Outputs

aws_iam-policy_id = "arn:aws:iam::309602515679:policy/DeployToS3Buckets"
aws_iam_group = <<EOT
Group ID: Deployers
Group UniqueID: AGPAUQFN7PLPTV6FMFIS4
Group Name: Deployers

EOT
aws_iam_user = <<EOT
User ID: transfast-gitlab-deployer
User UniqueID: AIDAUQFN7PLPZEKE2KBGL
User Name: transfast-gitlab-deployer
User Access Key ID: AKIAUQFN7PLPYTGFHKNL
User Access Key Secret: This value is in 'aws_iam_user_access_key_secret'
Get it with: 'terraform output -raw aws_iam_user_access_key_secret'

EOT
aws_iam_user_access_key_secret = This user was probably imported so state holds no data.
