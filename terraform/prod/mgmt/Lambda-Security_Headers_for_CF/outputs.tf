output "lambda_id" {
  value = aws_lambda_function.lambda_func.id
}

output "lambda_arn" {
  value = aws_lambda_function.lambda_func.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.lambda_func.invoke_arn
}

output "lambda_version" {
  value = aws_lambda_function.lambda_func.version
}

output "lambda_version_for_cloud_front_functions" {
  value = "${aws_lambda_function.lambda_func.arn}:${aws_lambda_function.lambda_func.version}"
}
