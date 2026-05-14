-- Upsert the site row, then insert a build_run row referencing it.
-- Run via:  psql "$DATABASE_URL" -v slug=... -v ... -f scripts/db/log-build.sql
-- All :'name' substitutions are quoted/escaped by psql (safe against SQL injection).

WITH site_upsert AS (
  INSERT INTO sites (
    slug,
    github_repo_url,
    public_domain,
    latest_live_url,
    origin_issue_number
  )
  VALUES (
    :'slug',
    :'repo_url',
    NULLIF(:'public_domain', ''),
    NULLIF(:'live_url', ''),
    :issue_number
  )
  ON CONFLICT (slug) DO UPDATE SET
    public_domain   = COALESCE(NULLIF(EXCLUDED.public_domain, ''),   sites.public_domain),
    latest_live_url = COALESCE(NULLIF(EXCLUDED.latest_live_url, ''), sites.latest_live_url),
    updated_at      = NOW()
  RETURNING id
)
INSERT INTO build_runs (
  site_id,
  github_run_id,
  event_type,
  issue_number,
  prompt,
  status,
  verify_passed,
  tokens_in,
  tokens_out,
  cost_usd,
  live_url
)
SELECT
  id,
  :run_id,
  :'event_type',
  :issue_number,
  NULLIF(:'prompt', ''),
  :'status',
  :'verify_passed'::boolean,
  :tokens_in,
  :tokens_out,
  :'cost'::numeric,
  NULLIF(:'live_url', '')
FROM site_upsert
ON CONFLICT (github_run_id) DO NOTHING;
