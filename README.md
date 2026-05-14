# AI Software Factory 🏭🤖

An automated AI-powered development pipeline that treats GitHub Issues as a ticketing system to build, update, and deploy websites completely autonomously. 

Powered by the **Claude Code CLI** and **GitHub Actions**, this system allows you to generate individual child repositories and deploy them to Vercel simply by typing a prompt.

## 🚀 How it Works

1. **Submit a Request**: Open a new GitHub Issue in this repository. 
   - **Title**: The name of your project (e.g., `midnight-brew-cafe`). This will become the child repository name.
   - **Body**: The prompt describing the website you want to build (e.g., "Create a dark mode landing page...").
2. **AI Processing**: The `main.yml` workflow kicks in automatically. It will:
   - Check if a repository with that name already exists. If not, it creates a new one and initializes it.
   - Run the **Claude Code CLI** to generate the HTML/CSS/JS based on your prompt.
   - Perform a **Self-Healing Loop**: If it detects code formatting or syntax errors (via Prettier/HTMLHint), Claude will automatically attempt to fix its own code.
3. **Deployment**: The finished code is committed to the child repository and automatically deployed to Vercel.
4. **Report & Feedback**: The bot comments back on your Issue with the Live URL, source code link, and the Claude token/cost usage stats. If you want changes, just reply to that comment!

## ⚙️ Prerequisites & Setup

To run this factory in your own environment, you need to configure four GitHub Repository Secrets:

### 1. `CLAUDE_CODE_OAUTH_TOKEN` (Claude Authentication)
A long-lived OAuth token that lets the workflow authenticate as your Claude Pro / Team account.
1. Open a terminal on your local machine.
2. Run: `claude setup-token`
3. Log in via your browser.
4. Copy the generated long-lived token and paste it into the `CLAUDE_CODE_OAUTH_TOKEN` GitHub secret.

> Subscription quota is used instead of pay-per-API-call. If you prefer a developer API key, you'd need to modify `main.yml` to read `ANTHROPIC_API_KEY` instead.

### 2. `GH_PAT` (GitHub Personal Access Token)
Required to create, push to, and delete child repositories.
- Create a classic PAT at https://github.com/settings/tokens with scopes: **`repo`**, **`workflow`**, **`delete_repo`**.
- `delete_repo` is only needed for the auto-cleanup workflow (see below); the build workflow works fine without it.

### 3. `VERCEL_TOKEN` (Vercel Deployment)
Required to automatically host the generated websites.
- Generate a token at https://vercel.com/account/tokens.

### 4. `DATABASE_URL` (Neon Postgres — build tracking)
Lets the workflow log every generated site and build run to Postgres so you can dashboard / analyze them later.
- Create a Neon project (Postgres 17, region close to you), copy the **pooled** connection string from Neon Console → Connection Details.
- Apply the schema once: `psql "$DATABASE_URL" -f scripts/db/schema.sql`.
- Optional — if you don't set this secret, the workflow still builds and deploys; the DB-logging step just skips itself.

> `.env.example` at the repo root has the same list with copy-pasteable comments.

## 🧹 Auto-cleanup of stale sites

The factory's 1:1:1 model (1 issue → 1 GitHub repo → 1 Vercel project) keeps each customer cleanly isolated, but the dashboards fill up over time. A scheduled cleanup workflow removes anything that's been abandoned.

- **Workflow**: `.github/workflows/cleanup.yml` runs daily at 04:00 UTC, or manually via Actions → "Cleanup Stale Sites" → Run workflow.
- **Criteria**: a site is deleted if its `sites.updated_at` is older than `INACTIVE_DAYS` (default 10) **and** its `protected` column is `FALSE`.
- **What gets deleted**: the GitHub child repo, the Vercel project, and the DB rows (`build_runs` cascade-deletes with `sites`).

### Protecting real customer sites

To exempt a site from cleanup, set the `protected` flag in the DB:
```sql
UPDATE sites SET protected = TRUE WHERE slug = 'my-real-customer';
```

### One-time Vercel team setting

To make new child projects publicly accessible by default (without per-project toggling), change the team's deployment-protection default:
1. Open https://vercel.com/teams/<your-team>/settings/security
2. Find **Deployment Protection**.
3. Set the default for new projects to **"Only Preview Deployments"** (or "Disabled").
4. Save.

Without this, every new child site requires manual disabling of Vercel Authentication before the public can view it.

## 🛠️ Architecture

- **Build workflow**: `.github/workflows/main.yml` — triggered by issues/comments
- **Cleanup workflow**: `.github/workflows/cleanup.yml` — scheduled, sweeps stale sites
- **Scripts**: `scripts/*.sh` — focused bash scripts called from the workflow steps
- **Schema**: `scripts/db/schema.sql` — Postgres tables for `sites` + `build_runs`
- **Dependencies**: No complex frameworks. It generates vanilla HTML/CSS/JS for maximum speed and simplicity.
- **Permissions**: Claude is configured via `.claude/settings.json` to safely bypass interactive prompts in CI/CD.
