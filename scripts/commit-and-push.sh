#!/usr/bin/env bash
set -euo pipefail

: "${REPO_NAME:?REPO_NAME is required}"
: "${GH_TOKEN:?GH_TOKEN is required}"

cd "$REPO_NAME"
gh auth setup-git
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add .

if git diff --quiet && git diff --staged --quiet; then
  echo "No changes to commit."
else
  git commit -m "🔧 Update code by AI"
  git push origin main
fi
