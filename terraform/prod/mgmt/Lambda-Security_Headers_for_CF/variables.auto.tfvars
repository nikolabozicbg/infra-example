assume_role_arn = "arn:aws:iam::458838185766:role/Terraform-Assume-Role"
aws_region      = "us-east-1" # Has to be US East for this to work with CloudFront distribution
aws_profile     = "transfast-devops"

client      = "TransFast"
client_blob = "transfast"
env         = "prod"

function_name    = "HSTS_Headers"
function_handler = "index.handler"
labmda_runtime   = "nodejs14.x"
#lambda_timeout_increase = 3
zip_filename = "HSTS_Headers.zip"
