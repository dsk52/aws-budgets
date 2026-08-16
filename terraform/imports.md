# Terraform import commands

## Prerequisites

- Create `terraform/terraform.tfvars` from `terraform/terraform.tfvars.example`.
- Ensure AWS profile `default` exists (or update `aws_profile` and backend profile).
- Run `terraform -chdir=terraform init`.

## Imports

```bash
terraform -chdir=terraform import aws_iam_role.chatbot_role ChatbotStack-ChatbotRole8A87AA1F-Kor5BnZZMXBr
terraform -chdir=terraform import aws_sns_topic.budget_alerts arn:aws:sns:ap-northeast-1:178083574992:BudgetNotificationStack-BudgetAlertTopicF20DF526-fjln1hT3HCgC
terraform -chdir=terraform import aws_sns_topic_policy.budget_alerts_publish arn:aws:sns:ap-northeast-1:178083574992:BudgetNotificationStack-BudgetAlertTopicF20DF526-fjln1hT3HCgC
terraform -chdir=terraform import aws_sns_topic.health_check_us_east_1 arn:aws:sns:us-east-1:178083574992:HealthCheckNotificationStack-HealthCheckTopic4D4B188A-DL8RJOyqk6Au
terraform -chdir=terraform import aws_chatbot_slack_channel_configuration.budget_alerts arn:aws:chatbot::178083574992:chat-configuration/slack-channel/BudgetAlertsChannel

terraform -chdir=terraform import aws_route53_health_check.blog_site 1f4929bf-12af-4f08-925d-35e5065da238
terraform -chdir=terraform import aws_route53_health_check.memo_drip 3d32c2c3-7250-4247-992c-9f3b0b673942

terraform -chdir=terraform import 'aws_cloudwatch_metric_alarm.blog_site_us_east_1' 'blog.daisukekonishi.com-health-check'
terraform -chdir=terraform import 'aws_cloudwatch_metric_alarm.memo_drip_us_east_1' 'memodrip.net-health-check'

terraform -chdir=terraform import aws_budgets_budget.monthly_cost 178083574992:MonthlyCostBudget
```

## GitHub OIDC Imports

```bash
terraform -chdir=terraform import aws_iam_openid_connect_provider.github_actions arn:aws:iam::178083574992:oidc-provider/token.actions.githubusercontent.com

terraform -chdir=terraform import aws_iam_role.about_deploy about-deploy
terraform -chdir=terraform import aws_iam_role_policy.about_deploy about-deploy:about-deploy-policy

terraform -chdir=terraform import aws_iam_role.sandbox_go_function_github_actions sandbox-go-function-github-actions-role
terraform -chdir=terraform import aws_iam_policy.sandbox_go_function_github_actions_lambda_deploy arn:aws:iam::178083574992:policy/sandbox-go-function-github-actions-lambda-deploy
terraform -chdir=terraform import aws_iam_role_policy_attachment.sandbox_go_function_github_actions_lambda_deploy sandbox-go-function-github-actions-role/arn:aws:iam::178083574992:policy/sandbox-go-function-github-actions-lambda-deploy
```
