# AI Software Factory 🏭🤖

An automated AI-powered development pipeline that treats GitHub Issues as a ticketing system to build, update, and deploy websites completely autonomously. 

Powered by the **Claude Code CLI** and **GitHub Actions**, this system allows you to generate individual child repositories and deploy them to Vercel simply by typing a prompt.

## 🚀 How it Works

1. **Submit a Request**: Open a new GitHub Issue in this repository. 
   - **Title**: The name of your project (e.g., `midnight-brew-cafe`). This will become the child repository name.
   - **Body**: The prompt describing the website you want to build (e.g., "Create a dark mode landing page...").
2. **AI Processing**: The `ai-factory.yml` workflow kicks in automatically. It will:
   - Check if a repository with that name already exists. If not, it creates a new one and initializes it.
   - Run the **Claude Code CLI** to generate the HTML/CSS/JS based on your prompt.
   - Perform a **Self-Healing Loop**: If it detects code formatting or syntax errors (via Prettier/HTMLHint), Claude will automatically attempt to fix its own code.
3. **Deployment**: The finished code is committed to the child repository and automatically deployed to Vercel.
4. **Report & Feedback**: The bot comments back on your Issue with the Live URL, source code link, and the Claude token/cost usage stats. If you want changes, just reply to that comment!

## ⚙️ Prerequisites & Setup

To run this factory in your own environment, you need to configure three GitHub Repository Secrets:

### 1. `ANTHROPIC_API_KEY` (Claude Authentication)
You have two options for authenticating Claude:
- **Option A (Developer API Key)**: Generate a standard API key from the [Anthropic Console](https://console.anthropic.com/).
- **Option B (Claude Pro / Team Plan)**: If you want to use your subscription quota instead of paying per API call, you can generate a long-lived OAuth token.
  1. Open a terminal on your local machine.
  2. Run: `claude setup-token`
  3. Log in via your browser.
  4. Copy the generated long-lived token.
  *Paste either the API Key or the Long-lived Token into the `ANTHROPIC_API_KEY` GitHub secret.*

### 2. `GH_PAT` (GitHub Personal Access Token)
Required to create and clone child repositories. 
- Create a classic PAT with `repo` and `workflow` scopes.

### 3. `VERCEL_TOKEN` (Vercel Deployment)
Required to automatically hosting the generated websites.
- Generate a token from your [Vercel Account Settings](https://vercel.com/account/tokens).

## 🛠️ Architecture

- **Workflow File**: `.github/workflows/ai-factory.yml`
- **Dependencies**: No complex frameworks. It generates vanilla HTML/CSS/JS for maximum speed and simplicity.
- **Permissions**: Claude is configured via `.claude/settings.json` to safely bypass interactive prompts in CI/CD.
