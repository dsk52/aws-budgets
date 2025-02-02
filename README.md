# AWSコスト通知

## 構成

```
[AWS Budgets] 
      ↓
[AWS SNS Topic]
      ↓
[AWS Chatbot] --> [Slack Channnel]
```

## 使い方

1. AWSコンソール上からAWS Chatbotを有効化しておく
    1. ワークスペースとの連携まで
2. `npm i`
3. デプロイを実行 `npm run cdk deploy`
