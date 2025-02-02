#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { BudgetNotificationStack } from '../lib/BudgetNotificationStack';

const app = new cdk.App();
new BudgetNotificationStack(app, 'BudgetNotificationStack', {
  env: {
    region: 'ap-northeast-1'
  }
});
