# Outputs

cert_arn = "arn:aws:acm:us-east-1:458838185766:certificate/8c7ef61f-8582-45ad-80dc-13c2620d1510"
cert_validation_params = <<EOT
The domain to be validated: admin-transfast.pannovate.net
The region for the domain to be validated: us-east-1 - Global
The method for the validation: DNS

EOT
cert_validation_params_vals = toset([
{
"domain_name" = "admin-transfast.pannovate.net"
"resource_record_name" = "_b8a2593c8b49553869d94b09ba981a81.admin-transfast.pannovate.net."
"resource_record_type" = "CNAME"
"resource_record_value" = "_ed83752dc9fae21aa86ee9289cdda357.yzdtlljtvc.acm-validations.aws."
},
])
cert_validation_status = "ISSUED"
