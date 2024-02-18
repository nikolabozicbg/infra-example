cert_arn = "arn:aws:acm:us-east-1:458838185766:certificate/dab02d4f-52f2-4d2a-930c-7ec27c880a71"
cert_validation_params = <<EOT
The domain to be validated: transfast.pannovate.net
The region for the domain to be validated: us-east-1 - Global
The method for the validation: DNS

EOT
cert_validation_params_vals = toset([
{
"domain_name" = "transfast.pannovate.net"
"resource_record_name" = "_db980f1c6562e85d04db5002d04543ec.transfast.pannovate.net."
"resource_record_type" = "CNAME"
"resource_record_value" = "_73359bfe249bdefa5117832e11e2aacd.yzdtlljtvc.acm-validations.aws."
},
])
cert_validation_status = "ISSUED"
