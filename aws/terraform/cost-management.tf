# KMS Key for SNS Topic encryption
resource "aws_kms_key" "budget_alerts" {
  description             = "KMS key for budget alerts SNS topic"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "budget_alerts" {
  name          = "alias/budget-alerts"
  target_key_id = aws_kms_key.budget_alerts.key_id
}

# SNS Topic for Budget Alerts
resource "aws_sns_topic" "budget_alerts" {
  name              = "budget-alerts"
  kms_master_key_id = aws_kms_key.budget_alerts.arn
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "budget_email" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = "bsmorris1+aws@gmail.com"
}

# Overall Organization Budget
resource "aws_budgets_budget" "organization_monthly" {
  name         = "organization-monthly-budget"
  budget_type  = "COST"
  limit_amount = "50"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "LinkedAccount"
    values = ["396913723725"]
  }
  cost_filter {
    name   = "LinkedAccount"
    values = ["688567306703"]
  }
  cost_filter {
    name   = "LinkedAccount"
    values = ["400205986141"]
  }
  cost_filter {
    name   = "LinkedAccount"
    values = ["825765407025"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["bsmorris1+aws@gmail.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["bsmorris1+aws@gmail.com"]
  }
}

# Per-Account Budgets
resource "aws_budgets_budget" "dev_account" {
  name         = "dev-account-budget"
  budget_type  = "COST"
  limit_amount = "15"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "LinkedAccount"
    values = ["688567306703"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["bsmorris1+aws@gmail.com"]
  }
}

resource "aws_budgets_budget" "staging_account" {
  name         = "staging-account-budget"
  budget_type  = "COST"
  limit_amount = "20"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "LinkedAccount"
    values = ["400205986141"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["bsmorris1+aws@gmail.com"]
  }
}

resource "aws_budgets_budget" "prod_account" {
  name         = "prod-account-budget"
  budget_type  = "COST"
  limit_amount = "25"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "LinkedAccount"
    values = ["825765407025"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["bsmorris1+aws@gmail.com"]
  }
}

