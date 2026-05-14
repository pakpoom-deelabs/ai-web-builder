#!/usr/bin/env bash
set -euo pipefail

: "${REPO_NAME:?REPO_NAME is required}"
: "${REPO_OWNER:?REPO_OWNER is required}"
: "${GH_TOKEN:?GH_TOKEN is required}"

if gh repo view "$REPO_OWNER/$REPO_NAME" >/dev/null 2>&1; then
  echo "Repository $REPO_NAME already exists. Cloning it..."
  gh repo clone "$REPO_OWNER/$REPO_NAME"
else
  echo "Creating new repository: $REPO_NAME"
  gh repo create "$REPO_NAME" --public --clone
  cd "$REPO_NAME"
  gh auth setup-git
  cat > index.html <<HTML
<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><title>$REPO_NAME</title></head><body><h1>Welcome to $REPO_NAME</h1></body></html>
HTML
  git checkout -b main
  git add index.html
  git config user.name "github-actions[bot]"
  git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
  git commit -m "Initial commit"
  git push -u origin main
fi
