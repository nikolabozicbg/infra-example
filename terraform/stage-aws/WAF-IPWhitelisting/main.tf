resource "aws_wafv2_ip_set" "waf2_ipset" {
  name               = var.ipset_name
  description        = var.ipset_description
  ip_address_version = "IPV4"
  addresses          = var.ip_address_list
  scope              = var.waf_scope

  tags = {
    Client      = var.client
    Environment = var.env
    CreatedBy   = "terraform"
  }
}

resource "aws_wafv2_rule_group" "waf2_rule_group" {
  depends_on  = [aws_wafv2_ip_set.waf2_ipset]
  name        = var.waf_rule_group_name
  description = var.waf_group_description
  scope       = var.waf_scope
  capacity    = var.waf_capacity

  rule {
    name     = "rule-allow-ips"
    priority = 0

    action {
      allow {}
    }

    statement {
      # and_statement {
      # statement {
      # IP Match 0 1 WCU Cost or 5 WCU cost for fw-ed IPS and position of ANY
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.waf2_ipset.arn
        #ip_set_forwarded_ip_config = # Definitions Here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_rule_group#ipset-forwarded-ip-config
      }
      # }

      # statement {
      # IP Match 0 1 WCU Cost or 5 WCU cost for fw-ed IPS and position of ANY
      # ip_set_reference_statement {
      # arn = aws_wafv2_ip_set.waf2_ipset.arn
      #ip_set_forwarded_ip_config = # Definitions Here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_rule_group#ipset-forwarded-ip-config
      # ip_set_forwarded_ip_config {
      # fallback_behavior = "NO_MATCH"
      # header_name       = "X-Forwarded-For"
      # position          = "FIRST"
      # }
      # }
      # }
      # }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.client_blob}-rule-allow_ips-metric"
      sampled_requests_enabled   = false
    }
  }

  # rule {
  #   name     = "rule-allow-counrtys"
  #   priority = 1

  #   action {
  #     allow {}
  #   }

  #   statement {
  #     # Geo match = 1 WCU cost
  #     geo_match_statement {
  #       country_codes = var.waf_allow_country_codes
  #     }
  #   }

  #   visibility_config {
  #     cloudwatch_metrics_enabled = false
  #     metric_name                = "${var.client_blob}-rule-allow_counrtys-metric"
  #     sampled_requests_enabled   = false
  #   }
  # }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.client_blob}-waf-rules-metrics"
    sampled_requests_enabled   = false
  }

  tags = {
    Client      = var.client
    Environment = var.env
    CreatedBy   = "terraform"
  }
}

resource "aws_wafv2_web_acl" "waf2_web_acl" {
  name  = var.waf_web_acl_name
  scope = var.waf_scope

  default_action {
    block {}
  }

  rule {
    name     = "${var.client_blob}-web-acl-rule1"
    priority = 0

    override_action {
      # count {}
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.waf2_rule_group.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.client_blob}-waf-acl_rule1-metrics"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Client      = var.client
    Environment = var.env
    CreatedBy   = "terraform"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.client_blob}-waf-acl_rules-metrics"
    sampled_requests_enabled   = false
  }
}
