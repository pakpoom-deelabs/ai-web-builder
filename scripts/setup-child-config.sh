#!/usr/bin/env bash
set -euo pipefail

: "${REPO_NAME:?REPO_NAME is required}"

mkdir -p "$REPO_NAME/.claude"
cat > "$REPO_NAME/.claude/settings.json" <<'JSON'
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": ["Write(*)", "Edit(*)", "Read(*)", "Bash(*)"]
  }
}
JSON

cat >> "$REPO_NAME/.gitignore" <<'IGN'
claude_out.json
verify.log
.claude/
.vercel/
IGN
