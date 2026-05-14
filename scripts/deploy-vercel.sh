#!/usr/bin/env bash
set -euo pipefail

: "${REPO_NAME:?REPO_NAME is required}"
: "${VERCEL_TOKEN:?VERCEL_TOKEN is required}"

# Custom-domain config — defaults to demo-<slug>.deelabs.co
BASE_DOMAIN="${BASE_DOMAIN:-deelabs.co}"
DOMAIN_PREFIX="${DOMAIN_PREFIX:-demo-}"
CUSTOM_DOMAIN="${DOMAIN_PREFIX}${REPO_NAME}.${BASE_DOMAIN}"

# Team scoping (optional but recommended when project lives under a team)
TEAM_QUERY=""
if [ -n "${VERCEL_TEAM_ID:-}" ]; then
  TEAM_QUERY="?teamId=$VERCEL_TEAM_ID"
fi

cd "$REPO_NAME"
LIVE_URL=$(npx vercel deploy --prod --name "$REPO_NAME" --token "$VERCEL_TOKEN" --yes)
echo "Deployed: $LIVE_URL"

# Attach the custom domain to the project. Idempotent — 409 means "already attached", treat as success.
echo "Attaching custom domain: $CUSTOM_DOMAIN"
ATTACH_BODY=$(mktemp)
HTTP_CODE=$(curl -sS -o "$ATTACH_BODY" -w "%{http_code}" \
  -X POST \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$CUSTOM_DOMAIN\"}" \
  "https://api.vercel.com/v10/projects/$REPO_NAME/domains$TEAM_QUERY" || echo "000")

case "$HTTP_CODE" in
  200|201)
    echo "  ✓ attached"
    PUBLIC_URL="https://$CUSTOM_DOMAIN"
    ;;
  409)
    echo "  ✓ already attached (idempotent)"
    PUBLIC_URL="https://$CUSTOM_DOMAIN"
    ;;
  *)
    echo "  ⚠ attach returned HTTP $HTTP_CODE — falling back to Vercel deployment URL"
    head -c 500 "$ATTACH_BODY" || true
    echo ""
    PUBLIC_URL="$LIVE_URL"
    ;;
esac
rm -f "$ATTACH_BODY"

echo ""
echo "Live URL:      $LIVE_URL"
echo "Public domain: $PUBLIC_URL"

{
  echo "URL=$LIVE_URL"
  echo "PUBLIC_DOMAIN=$PUBLIC_URL"
} >> "$GITHUB_OUTPUT"
