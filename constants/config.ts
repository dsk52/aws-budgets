import * as dotenv from 'dotenv';

dotenv.config();

const workspaceId = process.env.SLACK_WORKSPACE_ID;
const channelId = process.env.SLACK_CHANNEL_ID;

if (!workspaceId || !channelId) {
  throw new Error('SLACK_WORKSPACE_ID and SLACK_CHANNEL_ID must be set in .env');
}

export const SLACK = {
  workspaceId,
  channelId,
}
