-- 001_initial.sql
CREATE TABLE IF NOT EXISTS trials (
    id                  TEXT PRIMARY KEY,
    title               TEXT NOT NULL,
    title_fr            TEXT,
    sponsor             TEXT,
    phase               TEXT,
    status              TEXT,
    start_date          DATE,
    end_date            DATE,
    conditions          TEXT[],
    interventions       TEXT[],
    locations           TEXT[],
    url_euctr           TEXT,
    url_ctis            TEXT,
    raw_data            JSONB,
    vulgarized_summary  TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_trials_status ON trials(status);
CREATE INDEX IF NOT EXISTS idx_trials_conditions ON trials USING GIN(conditions);
CREATE INDEX IF NOT EXISTS idx_trials_phase ON trials(phase);

COMMENT ON TABLE trials IS 'Essais cliniques européens vulgarisés';
