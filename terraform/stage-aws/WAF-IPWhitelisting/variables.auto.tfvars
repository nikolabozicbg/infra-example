assume_role_arn = "arn:aws:iam::309602515679:role/Terraform-Assume-Role"
aws_region      = "us-east-1" # Has to be US East for this to work with CloudFront distribution
aws_profile     = "transfast-stage-devops"

client      = "TransFast"
client_blob = "transfast"
env         = "stage"

ipset_name        = "transfast-admin-ipset"
ipset_description = "The list of IP addresses to be allowed to access CloudFront distribution"
ip_address_list = [
  "91.143.218.42/32",
  "88.99.219.54/32",
  "64.39.96.0/20",
  "139.97.112.0/23",
  "95.110.145.75/32",
  "178.238.234.156/32",
  "18.156.183.223/32",
  "18.158.162.164/32",
  "18.184.0.228/32",
  "18.196.224.124/32"
]                        # P8 VPN & P8 Alpha, then, 1 for PenTesters
waf_scope = "CLOUDFRONT" # REGIONAL or CLOUDFRONT

waf_rule_group_name   = "transfast-admin-rules"
waf_group_description = "Rules to inspect and control web requests in WebACL."
waf_capacity          = 10
#waf_allow_country_codes = ["RS", "GB"]

waf_web_acl_name = "transfast-admin-acl"
