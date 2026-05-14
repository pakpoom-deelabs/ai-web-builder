#!/usr/bin/env bash
set -euo pipefail

: "${REPO_NAME:?REPO_NAME is required}"
: "${GITHUB_USER:?GITHUB_USER is required}"
: "${LIVE_URL:?LIVE_URL is required}"
: "${EVENT_NAME:?EVENT_NAME is required}"
: "${ISSUE_NUMBER:?ISSUE_NUMBER is required}"
: "${GITHUB_REPO:?GITHUB_REPO is required}"
: "${GH_TOKEN:?GH_TOKEN is required}"

COST="${COST:-0}"
IN_TOKENS="${IN_TOKENS:-0}"
OUT_TOKENS="${OUT_TOKENS:-0}"
VERIFY_PASSED="${VERIFY_PASSED:-false}"

VERIFY_NOTE=""
if [ "$VERIFY_PASSED" != "true" ]; then
  VERIFY_NOTE="
⚠️ **Note:** Code verification did not fully pass. Please review the output carefully."
fi

if [ "$EVENT_NAME" = "issues" ]; then
  MSG="✅ **Deployment Successful**

The requested project has been generated and deployed.

🌐 **Live Preview (Deployment):** $LIVE_URL
🌍 **Public Domain:** https://${REPO_NAME}.vercel.app
📦 **Source Repository:** https://github.com/$GITHUB_USER/$REPO_NAME

📊 **Usage Stats:**
- **Tokens:** \`${IN_TOKENS} in\` / \`${OUT_TOKENS} out\`
- **Estimated Cost:** \`\$${COST}\`
${VERIFY_NOTE}

_To request further modifications, please reply directly to this issue._"
else
  MSG="✨ **Update Successful**

The codebase has been updated based on your recent feedback.

🌐 **Live Preview (Deployment):** $LIVE_URL
🌍 **Public Domain:** https://${REPO_NAME}.vercel.app

📊 **Usage Stats:**
- **Tokens:** \`${IN_TOKENS} in\` / \`${OUT_TOKENS} out\`
- **Estimated Cost:** \`\$${COST}\`
${VERIFY_NOTE}

_If you need any further adjustments, feel free to leave another comment._"
fi

gh issue comment "$ISSUE_NUMBER" --repo "$GITHUB_REPO" --body "$MSG"
