import crypto from 'crypto';
import { Request, Response, NextFunction } from 'express';
import { config } from '../config';

export function verifyChatwootWebhook(req: Request, res: Response, next: NextFunction) {
  const signature = req.headers['x-chatwoot-signature'] as string;
  const timestamp = req.headers['x-chatwoot-timestamp'] as string;
  const secret = config.chatwoot.webhookSecret;

  if (!secret) {
    console.warn('Chatwoot webhook secret not configured, skipping verification');
    return next();
  }

  if (!signature || !timestamp) {
    return res.status(401).json({ error: 'Missing signature or timestamp' });
  }

  const payload = JSON.stringify(req.body);
  const signatureData = `${timestamp}.${payload}`;
  const expectedSignature = `sha256=${crypto
    .createHmac('sha256', secret)
    .update(signatureData)
    .digest('hex')}`;

  if (signature !== expectedSignature) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  next();
}

export function verifyGithubWebhook(req: Request, res: Response, next: NextFunction) {
  const signature = req.headers['x-hub-signature-256'] as string;
  const secret = config.github.webhookSecret;

  if (!secret) {
    console.warn('GitHub webhook secret not configured, skipping verification');
    return next();
  }

  if (!signature) {
    return res.status(401).json({ error: 'Missing signature' });
  }

  const payload = JSON.stringify(req.body);
  const expectedSignature = `sha256=${crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex')}`;

  if (signature !== expectedSignature) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  next();
}