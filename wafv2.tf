resource "aws_wafv2_web_acl" "this" {
    name        = "${local.servicetitle}-wafv2-acl-${local.env}"
    description = "${local.servicetitle} ${local.env} waf acl v2"
    scope       = "REGIONAL"

    default_action {
        allow {}
    }

    rule {
        name     = "AWS-AWSManagedRulesAdminProtectionRuleSet"
        priority = 0
        override_action {
            count {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesAdminProtectionRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled  = true
            metric_name                 = "AWS-AWSManagedRulesAdminProtectionRuleSet"
            sampled_requests_enabled    = true
        }
    }

    rule {
        name     = "AWS-AWSManagedRulesCommonRuleSet"
        priority = 1
        override_action {
            count {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesCommonRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled  = true
            metric_name                 = "AWS-AWSManagedRulesCommonRuleSet"
            sampled_requests_enabled    = true
        }
    }

    rule {
        name     = "AWS-AWSManagedRulesLinuxRuleSet"
        priority = 2
        override_action {
            count {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesLinuxRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled  = true
            metric_name                 = "AWS-AWSManagedRulesLinuxRuleSet"
            sampled_requests_enabled    = true
        }
    }

    rule {
        name     = "AWS-AWSManagedRulesSQLiRuleSet"
        priority = 3
        override_action {
            count {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesSQLiRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled  = true
            metric_name                 = "AWS-AWSManagedRulesSQLiRuleSet"
            sampled_requests_enabled    = true
        }
    }

    rule {
        name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
        priority = 4
        override_action {
            count {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesKnownBadInputsRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled  = true
            metric_name                 = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
            sampled_requests_enabled    = true
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "${local.servicetitle}-wafv2-acl-${local.env}"
        sampled_requests_enabled = true
    }

    tags = {
        Name                  = "${local.servicetitle}-wafv2-acl-${local.env}"
        environment           = local.env
        personalinformation   = "yes"
        servicetitle          = local.servicetitle
    }
}

/*resource "aws_wafv2_web_acl_association" "this" {
    web_acl_arn     = aws_wafv2_web_acl.this.arn
    resource_arn    = 
    
}*/