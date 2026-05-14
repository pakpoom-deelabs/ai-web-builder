#!/usr/bin/env bash
set -euo pipefail

# Delete factory-generated sites that have been inactive for INACTIVE_DAYS days
# and are not marked `protected` in the DB. Operates on three places per slug:
#   1. GitHub repository  (needs GH_PAT with delete_repo scope)
#   2. Vercel project      (uses `vercel remove`, team scoping comes from the token)
#   3. DB row              (build_runs cascades via FK)

: "${DATABASE_URL:?DATABASE_URL is required}"
: "${GH_TOKEN:?GH_TOKEN is required}"
: "${VERCEL_TOKEN:?VERCEL_TOKEN is required}"
: "${GITHUB_REPO_OWNER:?GITHUB_REPO_OWNER is required}"

INACTIVE_DAYS="${INACTIVE_DAYS:-10}"

echo "Looking for sites inactive for >= ${INACTIVE_DAYS} days (and not protected)..."

STALE_SLUGS=$(psql "$DATABASE_URL" -t -A -c "
  SELECT slug FROM sites
  WHERE protected = FALSE
    AND updated_at < NOW() - INTERVAL '${INACTIVE_DAYS} days'
  ORDER BY updated_at ASC
")

if [ -z "$STALE_SLUGS" ]; then
  echo "Nothing to clean."
  exit 0
fi

echo "Will delete:"
echo "$STALE_SLUGS" | sed 's/^/  - /'

while IFS= read -r SLUG; do
  [ -z "$SLUG" ] && continue
  echo ""
  echo "=== $SLUG ==="

  # 1. GitHub repo
  echo "  GitHub: deleting $GITHUB_REPO_OWNER/$SLUG..."
  if gh repo delete "$GITHUB_REPO_OWNER/$SLUG" --yes 2>&1 | sed 's/^/    /'; then
    :
  else
    echo "    (continuing — may already be gone or PAT lacks delete_repo scope)"
  fi

  # 2. Vercel project — `vercel remove` honors the token's team scope automatically.
  echo "  Vercel: removing project $SLUG..."
  if npx --yes vercel remove "$SLUG" --yes --token "$VERCEL_TOKEN" 2>&1 | sed 's/^/    /'; then
    :
  else
    echo "    (continuing — may already be gone)"
  fi

  # 3. DB row (build_runs cascades).
  psql "$DATABASE_URL" -v slug="$SLUG" -c "DELETE FROM sites WHERE slug = :'slug';"

  echo "  Done."
done <<< "$STALE_SLUGS"

echo ""
echo "Cleanup complete."
