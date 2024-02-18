locals {
  bucket_name  = var.bucket_name_id
  s3_origin_id = var.s3_origin

  hsts_lambda_arn = length(var.hsts_lambda_arn) > 0 ? [var.hsts_lambda_arn] : []

  common_tags = {
    Client      = var.client
    Environment = var.env
    CreatedBy   = "Terraform"
  }
}

###############################
#### STATIC WEBSITE BUCKET ####
###############################

resource "aws_s3_bucket" "static_website" {
  bucket = local.bucket_name

  tags = merge(local.common_tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket_acl" "static_website-acl" {
  bucket = aws_s3_bucket.static_website.bucket
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "static_website_config" {
  bucket = aws_s3_bucket.static_website.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "static_website_versioning" {
  bucket = aws_s3_bucket.static_website.bucket
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_cors_configuration" "static_website_cors" {
  bucket = aws_s3_bucket.static_website.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [
      "GET",
      "PUT",
      "POST",
      "DELETE",
      "HEAD"
    ]
    allowed_origins = length(var.allow_extra_origins) > 0 ? concat(var.allow_extra_origins, var.cf_aliases, [aws_cloudfront_distribution.static_website.domain_name]) : concat(var.cf_aliases, [aws_cloudfront_distribution.static_website.domain_name])

    expose_headers = [
      "x-amz-server-side-encryption",
      "x-amz-request-id",
      "x-amz-id-2"
    ]
    max_age_seconds = 3000
  }
}


#################################
#### WEBSITES LOGGING BUCKET ####
#################################

resource "aws_s3_bucket" "log_bucket" {
  count  = length(var.existing_log_bucket_id) > 0 ? 0 : 1
  bucket = "${var.client_blob}-${var.env}-websites-logs-bucket"

  tags = merge(
    local.common_tags, {
      Name = "${var.client_blob}-${var.env}-websites-logs-bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  count  = length(var.existing_log_bucket_id) > 0 ? 0 : 1
  bucket = aws_s3_bucket.log_bucket[0].bucket
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  count  = length(var.existing_log_bucket_id) > 0 ? 0 : 1
  bucket = aws_s3_bucket.log_bucket[0].bucket
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_enc" {
  count  = length(var.existing_log_bucket_id) > 0 ? 0 : 1
  bucket = aws_s3_bucket.log_bucket[0].bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycles" {
  count  = length(var.existing_log_bucket_id) > 0 ? 0 : 1
  bucket = aws_s3_bucket.log_bucket[0].bucket

  rule {
    id     = "logs_retention-transition_rule"
    status = "Enabled"

    # After 180 days (6 months) delete the logs
    expiration {
      days                         = var.data_retention_days
      expired_object_delete_marker = true
    }

    # To save some budget, transition objects likely to use less often to AWS Glacier.
    # Glacier is a lot cheaper than S3 but comes with slower access times.
    transition {
      days          = var.move_to_glacier
      storage_class = "GLACIER"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.static_website.id}/*"
    },
    {
      "Sid": "AllowRegisteredAll",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${var.assume_role_arn}",
          "${var.s3_acces_role_arn}"
        ]
      },
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.static_website.id}/*"
    }
  ]
}
POLICY
}

resource "aws_cloudfront_distribution" "static_website" {
  enabled             = var.cf_enabled
  is_ipv6_enabled     = var.cf_enable_ipv6
  aliases             = length(var.cf_cert_arn) > 0 ? var.cf_aliases : []
  comment             = var.cf_comment
  default_root_object = "index.html"
  web_acl_id          = var.web_acl_id

  origin {
    domain_name = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  custom_error_response {
    error_caching_min_ttl = 900 # 15m
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  # This is becouse /login returns error object not found
  custom_error_response {
    error_caching_min_ttl = 900 # 15m
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      cookies {
        forward = "none"
      }

      headers = ["Origin"]

      query_string = false
    }

    dynamic "lambda_function_association" {
      for_each = local.hsts_lambda_arn
      content {
        event_type   = "origin-response"
        lambda_arn   = var.hsts_lambda_arn
        include_body = false
      }
    }

    min_ttl                = 0
    default_ttl            = 900  # 15m
    max_ttl                = 3600 #1h
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    target_origin_id = local.s3_origin_id

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    forwarded_values {
      query_string = false

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }

    dynamic "lambda_function_association" {
      for_each = local.hsts_lambda_arn
      content {
        event_type   = "origin-response"
        lambda_arn   = var.hsts_lambda_arn
        include_body = false
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    path_pattern           = "index.html"
    smooth_streaming       = false
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"
    trusted_key_groups     = []
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # If required it can be whitelisted to certain countries
      # restriction_type = "whitelist"
      # locations = ["CA", "DE", "GB", "RS", "US"]
    }
  }

  tags = merge(local.common_tags, {
    Name = var.cf_name
  })

  viewer_certificate {
    acm_certificate_arn            = var.cf_cert_arn
    cloudfront_default_certificate = length(var.cf_cert_arn) > 0 ? false : true
    minimum_protocol_version       = var.cf_minimum_protocol_version
    ssl_support_method             = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = "${length(var.existing_log_bucket_id) > 0 ? var.existing_log_bucket_id : aws_s3_bucket.log_bucket[0].id}.s3.amazonaws.com"
    prefix          = "${local.s3_origin_id}-cf_log/"
  }
}

# Below is when usig Route53 for DNS records

# data "aws_route53_zone" "myzone" {
#   name = "example.com"
# }

# resource "aws_route53_record" "www-a" {
#   zone_id = data.aws_route53_zone.myzone.zone_id
#   name    = "www.example.com"
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.static_website.domain_name
#     zone_id                = aws_cloudfront_distribution.static_website.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "www-aaa" {
#   zone_id = data.aws_route53_zone.myzone.zone_id
#   name    = "www.example.com"
#   type    = "AAAA"

#   alias {
#     name                   = aws_cloudfront_distribution.static_website.domain_name
#     zone_id                = aws_cloudfront_distribution.static_website.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
