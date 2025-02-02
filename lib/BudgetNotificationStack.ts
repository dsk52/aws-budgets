import { Stack, type StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';

import { CfnBudget } from 'aws-cdk-lib/aws-budgets';
import { Topic } from 'aws-cdk-lib/aws-sns';
import { ManagedPolicy, PolicyStatement, Role, ServicePrincipal } from 'aws-cdk-lib/aws-iam';
import { SlackChannelConfiguration } from 'aws-cdk-lib/aws-chatbot';
import { SLACK } from '../constants/config';

export class BudgetNotificationStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    const budgetTopic = new Topic(this, 'BudgetAlertTopic', {
      displayName: 'Budget Alert Notifications',
    });

    // SNSトピックへのアクセス許可 (BudgetsサービスがPublish可能にする)
    budgetTopic.addToResourcePolicy(
      new PolicyStatement({
        actions: ['sns:Publish'],
        principals: [new ServicePrincipal('budgets.amazonaws.com')],
        resources: [budgetTopic.topicArn],
      })
    );

    // CfnBudgetを使って予算を作成
    new CfnBudget(this, 'Budget', {
      budget: {
        budgetName: 'MonthlyCostBudget',
        budgetType: 'COST',
        timeUnit: 'MONTHLY',
        // 予算金額
        budgetLimit: {
          amount: 5,
          unit: 'USD'
        },
      },
      notificationsWithSubscribers: [
        {
          notification: {
            notificationType: 'ACTUAL',
            threshold: 50, // 予算の50%以上を使ったら通知
            thresholdType: 'PERCENTAGE',
            comparisonOperator: 'GREATER_THAN',
          },
          subscribers: [
            {
              subscriptionType: 'SNS',
              address: budgetTopic.topicArn,
            },
          ],
        },
        {
          notification: {
            notificationType: 'ACTUAL',
            threshold: 80, // 予算の80%以上を使ったら通知
            thresholdType: 'PERCENTAGE',
            comparisonOperator: 'GREATER_THAN',
          },
          subscribers: [
            {
              subscriptionType: 'SNS',
              address: budgetTopic.topicArn,
            },
          ],
        }
      ]
    })

    const chatbotRole = new Role(this, 'ChatbotRole', {
      assumedBy: new ServicePrincipal('chatbot.amazonaws.com'),
      managedPolicies: [
        ManagedPolicy.fromAwsManagedPolicyName('ReadOnlyAccess'),
        ManagedPolicy.fromAwsManagedPolicyName('CloudWatchReadOnlyAccess'),
      ],
    });

    new SlackChannelConfiguration(this, 'SlackChannelConfig', {
      slackChannelConfigurationName: 'BudgetAlertsChannel',
      slackWorkspaceId: SLACK.workspaceId,
      slackChannelId: SLACK.channelId,
      notificationTopics: [budgetTopic],
      role: chatbotRole,
    });
  }
}
