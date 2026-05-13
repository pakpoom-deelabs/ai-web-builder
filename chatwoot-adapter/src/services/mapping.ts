import prisma from '../db';

export async function createMapping(
  chatwootConversationId: string,
  chatwootAccountId: string,
  chatwootInboxId: string | null,
  githubIssueNumber: number,
  githubRepo: string
) {
  return prisma.conversationMapping.create({
    data: {
      chatwootConversationId: chatwootConversationId.toString(),
      chatwootAccountId,
      chatwootInboxId,
      githubIssueNumber,
      githubRepo,
      status: 'active',
    },
  });
}

export async function getMappingByChatwootConversation(conversationId: string) {
  return prisma.conversationMapping.findUnique({
    where: { chatwootConversationId: conversationId },
  });
}

export async function getMappingByGithubIssue(issueNumber: number, repo: string) {
  return prisma.conversationMapping.findFirst({
    where: {
      githubIssueNumber: issueNumber,
      githubRepo: repo,
    },
  });
}

export async function updateMappingStatus(conversationId: string, status: string) {
  return prisma.conversationMapping.update({
    where: { chatwootConversationId: conversationId },
    data: { status },
  });
}

export async function deleteMapping(conversationId: string) {
  return prisma.conversationMapping.delete({
    where: { chatwootConversationId: conversationId },
  });
}