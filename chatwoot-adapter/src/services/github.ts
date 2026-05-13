import { Octokit } from '@octokit/rest';
import { config } from '../config';

const octokit = new Octokit({
  auth: config.github.token,
});

export async function createIssue(title: string, body: string): Promise<number> {
  const response = await octokit.issues.create({
    owner: config.github.owner,
    repo: config.github.repo,
    title,
    body,
  });

  return response.data.number;
}

export async function addComment(issueNumber: number, body: string): Promise<void> {
  await octokit.issues.createComment({
    owner: config.github.owner,
    repo: config.github.repo,
    issue_number: issueNumber,
    body,
  });
}

export async function getIssue(issueNumber: number): Promise<any> {
  const response = await octokit.issues.get({
    owner: config.github.owner,
    repo: config.github.repo,
    issue_number: issueNumber,
  });

  return response.data;
}

export async function closeIssue(issueNumber: number): Promise<void> {
  await octokit.issues.update({
    owner: config.github.owner,
    repo: config.github.repo,
    issue_number: issueNumber,
    state: 'closed',
  });
}

export async function reopenIssue(issueNumber: number): Promise<void> {
  await octokit.issues.update({
    owner: config.github.owner,
    repo: config.github.repo,
    issue_number: issueNumber,
    state: 'open',
  });
}