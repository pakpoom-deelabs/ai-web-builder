-- AI Factory — site + build tracking schema.
-- Apply once against your Neon database:
--   psql "$DATABASE_URL" -f scripts/db/schema.sql
-- Idempotent: safe to re-run; statements use IF NOT EXISTS.

CREATE TABLE IF NOT EXISTS sites (
  id                  SERIAL PRIMARY KEY,
  slug                TEXT NOT NULL UNIQUE,
  github_repo_url     TEXT NOT NULL,
  public_domain       TEXT,
  latest_live_url     TEXT,
  origin_issue_number INTEGER NOT NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sites_origin_issue ON sites(origin_issue_number);

CREATE TABLE IF NOT EXISTS build_runs (
  id              SERIAL PRIMARY KEY,
  site_id         INTEGER NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  github_run_id   BIGINT NOT NULL UNIQUE,
  event_type      TEXT NOT NULL,
  issue_number    INTEGER NOT NULL,
  prompt          TEXT,
  status          TEXT NOT NULL,
  verify_passed   BOOLEAN NOT NULL DEFAULT FALSE,
  tokens_in       INTEGER NOT NULL DEFAULT 0,
  tokens_out      INTEGER NOT NULL DEFAULT 0,
  cost_usd        NUMERIC(10, 6) NOT NULL DEFAULT 0,
  live_url        TEXT,
  ended_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_build_runs_site_id  ON build_runs(site_id);
CREATE INDEX IF NOT EXISTS idx_build_runs_ended_at ON build_runs(ended_at DESC);
