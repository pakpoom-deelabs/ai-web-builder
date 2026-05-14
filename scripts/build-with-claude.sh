#!/usr/bin/env bash
set -uo pipefail

: "${REPO_NAME:?REPO_NAME is required}"
: "${CLAUDE_CODE_OAUTH_TOKEN:?CLAUDE_CODE_OAUTH_TOKEN is required}"

PROMPT=$(cat .prompt.txt)
FIX_TEMPLATE=$(cat prompts/fix.md)
cd "$REPO_NAME"

TOTAL_COST=0
TOTAL_IN_TOKENS=0
TOTAL_OUT_TOKENS=0
CLAUDE_OK=false

run_claude() {
  local p="$1"
  echo "🤖 Prompting Claude..."
  claude -p "$p" --permission-mode bypassPermissions --output-format json > claude_out.json 2>&1 || true
  local json_data
  json_data=$(grep -E '^{"type":"result"' claude_out.json | head -n 1)
  if [ -n "$json_data" ]; then
    CLAUDE_OK=true
    echo "$json_data" | jq -r '.result'
    local cost in_tokens out_tokens
    cost=$(echo "$json_data" | jq -r '.total_cost_usd // 0')
    in_tokens=$(echo "$json_data" | jq -r '.usage.input_tokens // 0')
    out_tokens=$(echo "$json_data" | jq -r '.usage.output_tokens // 0')
    TOTAL_COST=$(awk "BEGIN {printf \"%.6f\", $TOTAL_COST + $cost}")
    TOTAL_IN_TOKENS=$((TOTAL_IN_TOKENS + in_tokens))
    TOTAL_OUT_TOKENS=$((TOTAL_OUT_TOKENS + out_tokens))
  else
    echo "⚠️ Claude did not return a valid result."
    cat claude_out.json
  fi
}

# 1. Initial code generation
run_claude "$PROMPT"

if [ "$CLAUDE_OK" != "true" ]; then
  echo "::error::Claude failed to generate code. Aborting."
  exit 1
fi

# 2. Self-healing loop
MAX_RETRIES=2
ATTEMPT=1
VERIFY_PASSED=false
VERIFY_CMD="npx --yes prettier --write . && npx --yes htmlhint '**/*.html'"

while [ $ATTEMPT -le $MAX_RETRIES ]; do
  echo "🔍 Running verification (Attempt $ATTEMPT/$MAX_RETRIES)..."
  if eval "$VERIFY_CMD" > verify.log 2>&1; then
    echo "✅ Verification passed!"
    VERIFY_PASSED=true
    break
  else
    echo "❌ Verification failed! Asking Claude to fix it..."
    ERROR_LOG=$(cat verify.log)
    FIX_PROMPT="${FIX_TEMPLATE//\{\{ERROR_LOG\}\}/$ERROR_LOG}"
    run_claude "$FIX_PROMPT"
    ATTEMPT=$((ATTEMPT + 1))
  fi
done

if [ "$VERIFY_PASSED" != "true" ]; then
  echo "::warning::Self-healing loop exhausted. Code may contain issues."
fi

{
  echo "COST=$TOTAL_COST"
  echo "IN_TOKENS=$TOTAL_IN_TOKENS"
  echo "OUT_TOKENS=$TOTAL_OUT_TOKENS"
  echo "VERIFY_PASSED=$VERIFY_PASSED"
} >> "$GITHUB_OUTPUT"
