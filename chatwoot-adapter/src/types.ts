export interface ChatwootWebhookPayload {
  event: string;
  id: number;
  account: {
    id: number;
    name: string;
  };
  inbox: {
    id: number;
    name: string;
  };
  conversation: {
    id: number;
    display_id: number;
    status: string;
    priority: string;
    assignee?: {
      id: number;
      name: string;
      email: string;
    };
    contact: {
      id: number;
      name: string;
      email: string;
    };
  };
  message?: {
    id: number;
    content: string;
    message_type: 'incoming' | 'outgoing';
    content_type: string;
    created_at: number;
    sender: {
      id: number;
      name: string;
      type: 'Contact' | 'User' | 'Bot';
    };
  };
}

export interface GitHubIssueCommentPayload {
  action: string;
  issue: {
    number: number;
    title: string;
    body: string;
    html_url: string;
  };
  comment: {
    id: number;
    body: string;
    user: {
      login: string;
      type: string;
    };
    created_at: string;
  };
  repository: {
    name: string;
    full_name: string;
  };
  sender: {
    login: string;
    type: string;
  };
}

export interface GitHubIssuePayload {
  action: string;
  issue: {
    number: number;
    title: string;
    body: string;
    state: string;
    html_url: string;
  };
  repository: {
    name: string;
    full_name: string;
  };
}

export interface ConversationMapping {
  id: number;
  chatwootConversationId: string;
  chatwootAccountId: string;
  chatwootInboxId: string | null;
  githubIssueNumber: number;
  githubRepo: string;
  status: string;
  createdAt: Date;
  updatedAt: Date;
}