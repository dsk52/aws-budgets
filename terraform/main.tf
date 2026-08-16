resource "aws_iam_role" "chatbot_role" {
  name = "ChatbotStack-ChatbotRole8A87AA1F-Kor5BnZZMXBr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "chatbot_read_only" {
  role       = aws_iam_role.chatbot_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "chatbot_cloudwatch_read_only" {
  role       = aws_iam_role.chatbot_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_sns_topic" "budget_alerts" {
  name         = "BudgetNotificationStack-BudgetAlertTopicF20DF526-fjln1hT3HCgC"
  display_name = "Budget Alert Notifications"
}

resource "aws_sns_topic_policy" "budget_alerts_publish" {
  arn = aws_sns_topic.budget_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "0"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.budget_alerts.arn
      }
    ]
  })
}

resource "aws_sns_topic" "health_check_us_east_1" {
  provider = aws.us_east_1
  name     = "HealthCheckNotificationStack-HealthCheckTopic4D4B188A-DL8RJOyqk6Au"
}

resource "aws_chatbot_slack_channel_configuration" "budget_alerts" {
  configuration_name = "BudgetAlertsChannel"
  slack_team_id      = var.slack_team_id
  slack_channel_id   = var.slack_channel_id
  iam_role_arn       = aws_iam_role.chatbot_role.arn

  sns_topic_arns = [
    aws_sns_topic.budget_alerts.arn,
    aws_sns_topic.health_check_us_east_1.arn,
  ]
}

resource "aws_budgets_budget" "monthly_cost" {
  provider     = aws.us_east_1
  name         = "MonthlyCostBudget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "20"
  limit_unit   = "USD"

  notification {
    comparison_operator = "GREATER_THAN"
    notification_type   = "ACTUAL"
    threshold           = 50
    threshold_type      = "PERCENTAGE"

    subscriber_sns_topic_arns = [aws_sns_topic.budget_alerts.arn]
  }

  notification {
    comparison_operator = "GREATER_THAN"
    notification_type   = "ACTUAL"
    threshold           = 80
    threshold_type      = "PERCENTAGE"

    subscriber_sns_topic_arns = [aws_sns_topic.budget_alerts.arn]
  }
}

resource "aws_route53_health_check" "blog_site" {
  type              = "HTTPS"
  fqdn              = "blog.daisukekonishi.com"
  port              = 443
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
  regions           = ["ap-northeast-1", "ap-southeast-1", "us-west-2"]

  tags = {
    Name = "BlogSite"
  }
}

resource "aws_route53_health_check" "memo_drip" {
  type              = "HTTPS"
  fqdn              = "memodrip.net"
  port              = 443
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
  regions           = ["ap-northeast-1", "ap-southeast-1", "us-west-2"]

  tags = {
    Name = "MemoDrip"
  }
}

resource "aws_cloudwatch_metric_alarm" "blog_site_us_east_1" {
  provider            = aws.us_east_1
  alarm_name          = "blog.daisukekonishi.com-health-check"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  statistic           = "Minimum"
  period              = 60

  dimensions = {
    HealthCheckId = aws_route53_health_check.blog_site.id
  }

  alarm_actions = [aws_sns_topic.health_check_us_east_1.arn]
}

resource "aws_cloudwatch_metric_alarm" "memo_drip_us_east_1" {
  provider            = aws.us_east_1
  alarm_name          = "memodrip.net-health-check"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  statistic           = "Minimum"
  period              = 60

  dimensions = {
    HealthCheckId = aws_route53_health_check.memo_drip.id
  }

  alarm_actions = [aws_sns_topic.health_check_us_east_1.arn]
}
