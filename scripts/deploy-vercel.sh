#!/usr/bin/env bash
set -euo pipefail

: "${REPO_NAME:?REPO_NAME is required}"
: "${VERCEL_TOKEN:?VERCEL_TOKEN is required}"

cd "$REPO_NAME"
# Static HTML deploys without interactive prompts.
LIVE_URL=$(npx vercel deploy --prod --name "$REPO_NAME" --token "$VERCEL_TOKEN" --yes)
echo "Deployed: $LIVE_URL"
echo "URL=$LIVE_URL" >> "$GITHUB_OUTPUT"
