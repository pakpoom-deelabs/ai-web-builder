import { config } from '../config';

const baseUrl = config.chatwoot.baseUrl;
const accountId = config.chatwoot.accountId;
const apiToken = config.chatwoot.apiToken;

const headers = {
  'Content-Type': 'application/json',
  'api_access_token': apiToken,
};

export async function sendMessage(conversationId: number, content: string): Promise<any> {
  const url = `${baseUrl}/api/v1/accounts/${accountId}/conversations/${conversationId}/messages`;
  
  const response = await fetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      content,
      message_type: 'outgoing',
      private: false,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to send message: ${response.status} - ${error}`);
  }

  return response.json();
}

export async function getConversation(conversationId: number): Promise<any> {
  const url = `${baseUrl}/api/v1/accounts/${accountId}/conversations/${conversationId}`;
  
  const response = await fetch(url, {
    method: 'GET',
    headers,
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to get conversation: ${response.status} - ${error}`);
  }

  return response.json();
}

export async function createWebhook(url: string, subscriptions: string[], inboxId?: number): Promise<any> {
  const webhookUrl = `${baseUrl}/api/v1/accounts/${accountId}/webhooks`;
  
  const body: any = {
    url,
    name: 'AI Factory Adapter',
    subscriptions,
  };

  if (inboxId) {
    body.inbox_id = inboxId;
  }

  const response = await fetch(webhookUrl, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to create webhook: ${response.status} - ${error}`);
  }

  return response.json();
}

export async function listWebhooks(): Promise<any> {
  const url = `${baseUrl}/api/v1/accounts/${accountId}/webhooks`;
  
  const response = await fetch(url, {
    method: 'GET',
    headers,
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to list webhooks: ${response.status} - ${error}`);
  }

  return response.json();
}