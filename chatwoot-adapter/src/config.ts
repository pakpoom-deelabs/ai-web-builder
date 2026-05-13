export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',

  chatwoot: {
    baseUrl: process.env.CHATWOOT_BASE_URL || 'https://app.chatwoot.com',
    accountId: process.env.CHATWOOT_ACCOUNT_ID || '',
    apiToken: process.env.CHATWOOT_API_TOKEN || '',
    webhookSecret: process.env.WEBHOOK_SECRET_CHATWOOT || '',
  },

  github: {
    token: process.env.GITHUB_TOKEN || '',
    owner: process.env.GITHUB_OWNER || '',
    repo: process.env.GITHUB_REPO || '',
    webhookSecret: process.env.WEBHOOK_SECRET_GITHUB || '',
  },

  database: {
    url: process.env.DATABASE_URL || '',
  },
};