variable "assume_role_arn" {
  description = "Role to assume for AWS API calls"
  type        = string
}

variable "aws_region" {
  description = "Specify AWS Region"
  type        = string
}

variable "aws_profile" {
  description = "Specify AWS profile with propper credentials"
  type        = string
}

variable "client" {
  type = string
}

variable "client_blob" {
  type = string
}

variable "env" {
  type = string
}

variable "ipset_name" {
  type = string
}

variable "ipset_description" {
  type = string
}

variable "ip_address_list" {
  type = list(string)
}

variable "waf_rule_group_name" {
  type        = string
  description = "Descriptive vame for the WAF group"
  default     = "test_waf_rule_group"
}

variable "waf_group_description" {
  description = "A friendly description of the rule group."
  type        = string
}

variable "waf_scope" {
  type        = string
  description = "Is this for an AWS CloudFront distribution or for a regional application [CLOUDFRONT or REGIONAL]. For CloudFront, the region on the AWS provider must be us-east-1 (N. Virginia)."
  default     = "REGIONAL"
}

# WAF Capacily Costs List:
# https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statements-list.html
variable "waf_capacity" {
  type        = number
  description = "The web ACL capacity units (WCUs) required for this rule group. AWS WAF uses WCUs to calculate and control the operating resources that are used to run rules, rule groups, and web ACLs. AWS WAF calculates capacity differently for each rule type."
}

variable "waf_allow_country_codes" {
  type        = list(string)
  description = "List of 2 character country codes to allow acces from"
  default     = []
}

variable "waf_web_acl_name" {
  type = string
}
