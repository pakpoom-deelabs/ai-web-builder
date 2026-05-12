# AI Web Builder

This repository contains an automated GitHub Actions workflow that acts as an AI-powered developer. It listens to GitHub Issues and uses the [Claude Code CLI](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) to automatically write code, commit changes, and create Pull Requests.

## How it Works

1. **Create an Issue**: Open a new GitHub Issue and describe the feature or bug fix you want.
2. **AI Processing**: The `ai-builder.yml` workflow is triggered automatically. It will:
   - Create a new branch for your feature (`ai-feature/issue-<number>`).
   - Run the Claude Code CLI using your issue title and description as the prompt.
   - Give Claude permission to modify files, write code, and run commands.
3. **Pull Request**: Once Claude completes the task, the workflow automatically creates a Pull Request back to the `main` branch.
4. **Iterate**: You can review the code, test it, or leave additional comments on the Issue. The AI will read your comments, make further adjustments, and update the PR.

## Workflow File

The core logic is located in: `.github/workflows/ai-builder.yml`.

## Prerequisites

To use this workflow in your own repository, you need:
- `ANTHROPIC_API_KEY`: Configured in your GitHub Repository Secrets to authenticate with Claude.
- Proper GitHub Action permissions (read/write access to repository contents and pull requests).

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
