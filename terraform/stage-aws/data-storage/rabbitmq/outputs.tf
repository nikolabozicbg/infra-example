output "Subnet-IDs" {
  value       = data.aws_subnets.private.ids
  description = "Private subnets ID"
}

output "RabbitMQ_arn" {
  description = "ARN of the RabbitMQ broker."
  value       = aws_mq_broker.rabbitmq.arn
}

output "RabbitMQ_id" {
  description = "ID of the RabbitMQ broker."
  value       = aws_mq_broker.rabbitmq.id
}

output "RabbitMQ_console_URL" {
  description = "The URL of the broker's RabbitMQ Web Console"
  value       = aws_mq_broker.rabbitmq.instances.*.console_url
}

output "RabbitMQ_endpoint" {
  description = "Broker's wire-level protocol endpoint"
  value       = aws_mq_broker.rabbitmq.instances[0].endpoints
}

output "RabbitMQ_instance_IPs" {
  description = "IP Address of the RabbitMQ broker"
  value       = aws_mq_broker.rabbitmq.instances.*.ip_address
}
