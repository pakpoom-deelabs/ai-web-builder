import express from 'express';
import pino from 'pino';
import pinoHttp from 'pino-http';
import { config } from './config';
import { verifyChatwootWebhook, verifyGithubWebhook } from './middleware/webhook-verify';
import * as chatwootService from './services/chatwoot';
import * as githubService from './services/github';
import * as mappingService from './services/mapping';
import type { ChatwootWebhookPayload, GitHubIssueCommentPayload } from './types';

const logger = pino({
  level: config.nodeEnv === 'production' ? 'info' : 'debug',
});

const app = express();

app.use(pinoHttp({ logger }));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.post('/webhooks/chatwoot', verifyChatwootWebhook, async (req, res) => {
  try {
    const payload = req.body as ChatwootWebhookPayload;
    const event = payload.event;

    logger.info({ event, conversationId: payload.conversation?.id }, 'Chatwoot webhook received');

    if (event === 'conversation_created') {
      const conversation = payload.conversation;
      const contact = conversation.contact;

      const issueBody = `## Customer Info
- **Name:** ${contact.name}
- **Email:** ${contact.email}
- **Inbox:** ${payload.inbox.name}

---

## Initial Message

> ลูกค้าสร้าง conversation ใหม่ผ่าน LINE`;

      const issueNumber = await githubService.createIssue(
        `[${contact.name}] ${contact.name} - New conversation from LINE`,
        issueBody
      );

      await mappingService.createMapping(
        conversation.id.toString(),
        payload.account.id.toString(),
        payload.inbox.id.toString(),
        issueNumber,
        config.github.repo
      );

      logger.info({ issueNumber, conversationId: conversation.id }, 'Created GitHub issue for new conversation');
    }

    if (event === 'message_created' && payload.message) {
      const message = payload.message;
      const conversation = payload.conversation;

      if (message.message_type !== 'incoming') {
        logger.debug({ messageType: message.message_type }, 'Skipping non-incoming message');
        return res.json({ status: 'skipped' });
      }

      const mapping = await mappingService.getMappingByChatwootConversation(conversation.id.toString());

      if (!mapping) {
        logger.warn({ conversationId: conversation.id }, 'No mapping found for conversation');
        return res.json({ status: 'no_mapping' });
      }

      const commentBody = `**${message.sender.name}:**
${message.content}`;

      await githubService.addComment(mapping.githubIssueNumber, commentBody);

      logger.info({ issueNumber: mapping.githubIssueNumber }, 'Added comment to GitHub issue');
    }

    res.json({ status: 'ok' });
  } catch (error) {
    logger.error({ error }, 'Error processing Chatwoot webhook');
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/webhooks/github', verifyGithubWebhook, async (req, res) => {
  try {
    const payload = req.body as GitHubIssueCommentPayload;
    const action = req.headers['x-github-event'] as string;

    logger.info({ action, issueNumber: payload.issue?.number }, 'GitHub webhook received');

    if (action === 'issue_comment') {
      const comment = payload.comment;
      const issue = payload.issue;

      if (comment.user.type !== 'Bot') {
        logger.debug({ userType: comment.user.type }, 'Skipping non-bot comment');
        return res.json({ status: 'skipped' });
      }

      if (comment.user.login !== 'github-actions[bot]') {
        logger.debug({ userLogin: comment.user.login }, 'Skipping non-github-actions bot');
        return res.json({ status: 'skipped' });
      }

      const mapping = await mappingService.getMappingByGithubIssue(issue.number, payload.repository.full_name);

      if (!mapping) {
        logger.warn({ issueNumber: issue.number }, 'No mapping found for issue');
        return res.json({ status: 'no_mapping' });
      }

      await chatwootService.sendMessage(
        parseInt(mapping.chatwootConversationId),
        comment.body
      );

      logger.info({ conversationId: mapping.chatwootConversationId }, 'Sent message to Chatwoot');
    }

    res.json({ status: 'ok' });
  } catch (error) {
    logger.error({ error }, 'Error processing GitHub webhook');
    res.status(500).json({ error: 'Internal server error' });
  }
});

const server = app.listen(config.port, () => {
  logger.info(`Server running on port ${config.port}`);
});

process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, closing server');
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});

export default app;