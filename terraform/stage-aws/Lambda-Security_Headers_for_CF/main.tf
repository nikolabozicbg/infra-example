# Archive a file to be used with Lambda using consistent file mode
data "archive_file" "lambda_zipfile" {
  type             = "zip"
  source_file      = "${path.module}/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/${var.zip_filename}"
}

# Allow AWS and lamabda to assume roles and take actions
resource "aws_iam_role" "iam_for_hsts_lambda" {
  name = "iam_for_hsts_lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# Also IAM to
resource "aws_iam_role_policy_attachment" "executor_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_hsts_lambda.name
}

resource "aws_lambda_function" "lambda_func" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = var.zip_filename
  function_name = var.function_name
  role          = aws_iam_role.iam_for_hsts_lambda.arn
  handler       = var.function_handler
  runtime       = var.labmda_runtime
  timeout       = var.lambda_timeout_increase
  publish       = true

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${var.zip_filename}")

  depends_on = [
    aws_iam_role.iam_for_hsts_lambda,
    aws_iam_role_policy_attachment.executor_attachment,
  ]

  # Lambda For CF and Lambda@Edge cannot have any environment variables
  # environment {
  #   variables = {
  #     NODE_ENV = "production"
  #   }
  # }

  tags = {
    Client      = var.client,
    Environment = var.env,
    CreatedBy   = "Terraform"
  }
}
