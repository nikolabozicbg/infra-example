# Amazon MQ aws_mq_broker

Provides an Amazon MQ broker resource. This resources also manages users for the broker.

> NOTE:
> Amazon MQ currently places limits on RabbitMQ brokers. For example, a RabbitMQ broker cannot have: instances with an associated IP address of an ENI attached to the broker, an associated LDAP server to authenticate and authorize broker connections, storage type EFS, audit logging, or configuration blocks. Although this resource allows you to create RabbitMQ users, RabbitMQ users cannot have console access or groups. Also, Amazon MQ does not return information about RabbitMQ users so drift detection is not possible.

## Outputs

RabbitMQ_arn = "arn:aws:mq:eu-west-1:458838185766:broker:TransFast-RabbitMQ-Broker:b-0cb50ff8-393f-427b-9f86-95ed27160296"
RabbitMQ_console_URL = tolist([
"https://b-0cb50ff8-393f-427b-9f86-95ed27160296.mq.eu-west-1.amazonaws.com",
])
RabbitMQ_endpoint = tolist([
"amqps://b-0cb50ff8-393f-427b-9f86-95ed27160296.mq.eu-west-1.amazonaws.com:5671",
])
RabbitMQ_id = "b-0cb50ff8-393f-427b-9f86-95ed27160296"
RabbitMQ_instance_IPs = tolist([
"",
])
Subnet-IDs = tolist([
"subnet-01fc8617fcef19b03",
"subnet-01540e6643e4aa3aa",
"subnet-03b0ad9701ebe88e9",
])
