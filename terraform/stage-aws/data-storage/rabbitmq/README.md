# Amazon MQ aws_mq_broker

Provides an Amazon MQ broker resource. This resources also manages users for the broker.

> NOTE:
> Amazon MQ currently places limits on RabbitMQ brokers. For example, a RabbitMQ broker cannot have: instances with an associated IP address of an ENI attached to the broker, an associated LDAP server to authenticate and authorize broker connections, storage type EFS, audit logging, or configuration blocks. Although this resource allows you to create RabbitMQ users, RabbitMQ users cannot have console access or groups. Also, Amazon MQ does not return information about RabbitMQ users so drift detection is not possible.

## Outputs

RabbitMQ_arn = "arn:aws:mq:eu-west-1:309602515679:broker:TransFast-RabbitMQ-Broker:b-683420d5-f4dd-4541-b6b9-180b716e94af"
RabbitMQ_console_URL = tolist([
"https://b-683420d5-f4dd-4541-b6b9-180b716e94af.mq.eu-west-1.amazonaws.com",
])
RabbitMQ_endpoint = tolist([
"amqps://b-683420d5-f4dd-4541-b6b9-180b716e94af.mq.eu-west-1.amazonaws.com:5671",
])
RabbitMQ_id = "b-683420d5-f4dd-4541-b6b9-180b716e94af"
RabbitMQ_instance_IPs = tolist([
"",
])
Subnet-IDs = tolist([
"subnet-04202eaa8e6b2cbb7",
"subnet-0abf5d6a9be5a0d48",
"subnet-082de3cb9f7f09749",
])
