# Chatwoot GitHub Adapter

Adapter to sync Chatwoot LINE conversations with GitHub Issues for AI Factory workflow.

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

3. **Setup database:**
   ```bash
   npm run db:generate
   npm run db:push
   ```

4. **Run locally:**
   ```bash
   npm run dev
   ```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string (Railway) |
| `CHATWOOT_BASE_URL` | Chatwoot URL (e.g., https://app.chatwoot.com) |
| `CHATWOOT_ACCOUNT_ID` | Chatwoot account ID |
| `CHATWOOT_API_TOKEN` | Chatwoot API token (from Settings → Access Tokens) |
| `WEBHOOK_SECRET_CHATWOOT` | Webhook secret for verification |
| `GITHUB_TOKEN` | GitHub PAT with repo permissions |
| `GITHUB_OWNER` | GitHub repository owner |
| `GITHUB_REPO` | GitHub repository name |
| `WEBHOOK_SECRET_GITHUB` | GitHub webhook secret |
| `PORT` | Server port (default: 3000) |
| `NODE_ENV` | Environment (development/production) |

## Webhook Setup

### Chatwoot
1. Go to Settings → Integrations → Webhooks
2. Add webhook:
   - URL: `https://your-server.com/webhooks/chatwoot`
   - Subscriptions: `conversation_created`, `message_created`

### GitHub
1. Go to Repository Settings → Webhooks
2. Add webhook:
   - URL: `https://your-server.com/webhooks/github`
   - Events: Issue comments

## Development with ngrok

```bash
# Terminal 1: Start server
npm run dev

# Terminal 2: Start ngrok
ngrok http 3000

# Use ngrok URL for webhook configuration
```

## Deploy to Railway

1. Connect Railway to your GitHub repository
2. Add PostgreSQL service
3. Set environment variables in Railway dashboard
4. Deploy

## Flow

```
LINE → Chatwoot → Adapter → GitHub Issue → AI Factory
                                      ↓
LINE ← Chatwoot ← Adapter ← GitHub webhook (comment)
```