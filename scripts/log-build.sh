#!/usr/bin/env bash
set -euo pipefail

# Silently no-op if DB not configured — keeps the factory usable for setups
# that haven't provisioned Postgres yet.
if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL not set — skipping DB log."
  exit 0
fi

: "${REPO_NAME:?REPO_NAME is required}"
: "${GITHUB_REPO_OWNER:?GITHUB_REPO_OWNER is required}"
: "${ISSUE_NUMBER:?ISSUE_NUMBER is required}"
: "${EVENT_NAME:?EVENT_NAME is required}"
: "${GITHUB_RUN_ID:?GITHUB_RUN_ID is required}"

PUBLIC_DOMAIN="${PUBLIC_DOMAIN:-}"
LIVE_URL="${LIVE_URL:-}"
IN_TOKENS="${IN_TOKENS:-0}"
OUT_TOKENS="${OUT_TOKENS:-0}"
COST="${COST:-0}"
VERIFY_PASSED="${VERIFY_PASSED:-false}"

REPO_URL="https://github.com/$GITHUB_REPO_OWNER/$REPO_NAME"

if [ "$VERIFY_PASSED" = "true" ]; then
  STATUS="success"
else
  STATUS="verify_warning"
fi

# Truncate prompt to ~64KB to keep rows compact.
PROMPT=""
if [ -f .prompt.txt ]; then
  PROMPT=$(head -c 65536 .prompt.txt)
fi

echo "Logging build #$GITHUB_RUN_ID for site '$REPO_NAME' to Postgres..."

psql "$DATABASE_URL" \
  -v ON_ERROR_STOP=1 \
  -v slug="$REPO_NAME" \
  -v repo_url="$REPO_URL" \
  -v public_domain="$PUBLIC_DOMAIN" \
  -v live_url="$LIVE_URL" \
  -v issue_number="$ISSUE_NUMBER" \
  -v run_id="$GITHUB_RUN_ID" \
  -v event_type="$EVENT_NAME" \
  -v status="$STATUS" \
  -v verify_passed="$VERIFY_PASSED" \
  -v tokens_in="$IN_TOKENS" \
  -v tokens_out="$OUT_TOKENS" \
  -v cost="$COST" \
  -v prompt="$PROMPT" \
  -f scripts/db/log-build.sql

echo "Logged."
