# OUTPUT

```json
cert_arn = "arn:aws:acm:eu-west-1:309602515679:certificate/3defb1b0-44bb-4352-a80b-7cfaaa434d82"
cert_validation_params = <<EOT
  The domain to be validated: *.pen.pannovate.net
  The region for the domain to be validated: eu-west-1
  The method for the validation: DNS

EOT
cert_validation_params_vals = toset([
  {
    "domain_name" = "*.pannovate.net"
    "resource_record_name" = "_cd4735133c89b67eedb695c280a76391.pannovate.net."
    "resource_record_type" = "CNAME"
    "resource_record_value" = "_b8c3a462f386ac33397d966c21bc3d5b.sggfvksfyf.acm-validations.aws."
  },
  {
    "domain_name" = "*.pen.pannovate.net"
    "resource_record_name" = "_f6be7d399c216c75443bd41d730a8599.pen.pannovate.net."
    "resource_record_type" = "CNAME"
    "resource_record_value" = "_3fcf69d86895aaf3a810ab357bb663ce.sggfvksfyf.acm-validations.aws."
  },
])
cert_validation_status = "ISSUED"
cert_validity_period_END = "2024-04-28T23:59:59Z"
cert_validity_period_START = "2023-03-31T00:00:00Z"
```
