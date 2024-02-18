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
  default = "syllo"
  type    = string
}

variable "client_blob" {
  default = "syllo"
  type    = string
}

variable "env" {
  default = "testing"
  type    = string
}

variable "function_name" {
  description = "The name of the lambda function that wil be created in AWS"
  type        = string
  default     = "test-lambda"
}

variable "function_handler" {
  description = "Provide the name of the function to invoke when the Lambda is triggered."
  type        = string
  default     = "index.handler"
}

variable "labmda_runtime" {
  description = "What runtime env to run this Lambda within. At the momment supports up to Node14 and python3.8"
  type        = string
  default     = "nodejs14.x"
}

variable "lambda_timeout_increase" {
  description = "By defaučt, Lambdas only run for a max of 3 sec. Provide total number of seconds, that are required, here."
  type        = number
  default     = 3
}

variable "zip_filename" {
  description = "File name of a zip file that should be pushed to AWS"
  type        = string
  default     = "test-lambda.zip"
}
