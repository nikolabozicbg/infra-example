# OUTPUT

```json
cert_arn = "arn:aws:acm:eu-west-1:458838185766:certificate/4fecd36b-e481-4240-b6da-ba86e03a1f03"
cert_validation_params = <<EOT
  The domain to be validated: api.transfast.pannovate.net
  The region for the domain to be validated: eu-west-1
  The method for the validation: DNS

EOT
cert_validation_params_vals = toset([
  {
    "domain_name" = "api.transfast.pannovate.net"
    "resource_record_name" = "_2c7ad21e1ff4a10e2b5c2ce975452d9c.api.transfast.pannovate.net."
    "resource_record_type" = "CNAME"
    "resource_record_value" = "_7211faef28f41e44edac9dffdbb58dd9.crxktfrmng.acm-validations.aws."
  },
])
cert_validation_status = "ISSUED"
cert_validity_period_END = "2023-12-07T23:59:59Z"
cert_validity_period_START = "2022-11-08T00:00:00Z"
```
