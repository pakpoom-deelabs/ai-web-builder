#!/usr/bin/env bash
set -euo pipefail

: "${REPO_NAME:?REPO_NAME is required}"
: "${VERCEL_TOKEN:?VERCEL_TOKEN is required}"

cd "$REPO_NAME"
LIVE_URL=$(npx vercel deploy --prod --name "$REPO_NAME" --token "$VERCEL_TOKEN" --yes)
echo "Deployed: $LIVE_URL"

# Query Vercel for the project's real production alias.
PROJECT_JSON=$(curl -fsSL \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v9/projects/$REPO_NAME" 2>/dev/null || echo "{}")

# Prefer a PRODUCTION alias ending in .vercel.app; fall back to any PRODUCTION alias.
PUBLIC_HOST=$(echo "$PROJECT_JSON" | jq -r '
  (
    [.alias[]? | select(.target=="PRODUCTION") | .domain | select(test("\\.vercel\\.app$"))] +
    [.alias[]? | select(.target=="PRODUCTION") | .domain]
  ) | .[0] // empty
')

# Final fallback: strip protocol/path from LIVE_URL.
if [ -z "$PUBLIC_HOST" ] || [ "$PUBLIC_HOST" = "null" ]; then
  PUBLIC_HOST="${LIVE_URL#https://}"
  PUBLIC_HOST="${PUBLIC_HOST#http://}"
  PUBLIC_HOST="${PUBLIC_HOST%%/*}"
fi

PUBLIC_URL="https://$PUBLIC_HOST"
echo "Public domain: $PUBLIC_URL"

{
  echo "URL=$LIVE_URL"
  echo "PUBLIC_DOMAIN=$PUBLIC_URL"
} >> "$GITHUB_OUTPUT"
