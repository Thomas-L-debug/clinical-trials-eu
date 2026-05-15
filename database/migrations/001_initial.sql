-- 001_initial.sql (version recommandée)
CREATE TABLE IF NOT EXISTS trials (
    id                  TEXT PRIMARY KEY,                    -- ctNumber (ex: 2023-508248-23-00)
    title               TEXT NOT NULL,
    title_fr            TEXT,                                 -- pour futur multilingue / vulgarisation
    sponsor             TEXT,
    sponsor_country     TEXT,                                 -- nouveau : très utile pour filtres
    phase               TEXT,                                 -- 'Phase 1', 'Phase 2/3', etc.
    status              TEXT NOT NULL,                        -- Overall trial status
    ct_public_status_code INTEGER,                          -- code officiel CTIS (utile pour mapping précis)
    
    start_date          DATE,                                 -- Overall start date EU
    end_date            DATE,                                 -- Overall end date EU
    decision_date       DATE,                                 -- très important pour le tri incrémental
    publish_date        DATE,
    
    conditions          TEXT[],                               -- medical conditions
    therapeutic_areas   TEXT[],                               -- nouveau : très demandé
    interventions       TEXT[],
    locations           TEXT[],                               -- pays / sites
    countries           TEXT[],                               -- nouveau : liste des pays EU/EEA impliqués
    
    url_euctr           TEXT,
    url_ctis            TEXT,
    
    raw_data            JSONB NOT NULL,                       -- toujours tout garder !
    vulgarized_summary  TEXT,                                 -- résumé simplifié (LLM)
    vulgarized_fr       TEXT,                                 -- futur
    
    last_fetched_at     TIMESTAMPTZ DEFAULT NOW(),            -- CRITIQUE pour sync incrémentale
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes performants (ce qui change vraiment la vie)
CREATE INDEX IF NOT EXISTS idx_trials_status          ON trials(status);
CREATE INDEX IF NOT EXISTS idx_trials_phase           ON trials(phase);
CREATE INDEX IF NOT EXISTS idx_trials_decision_date   ON trials(decision_date DESC);   -- pour fetch incrémental
CREATE INDEX IF NOT EXISTS idx_trials_last_fetched    ON trials(last_fetched_at);

CREATE INDEX IF NOT EXISTS idx_trials_conditions      ON trials USING GIN(conditions);
CREATE INDEX IF NOT EXISTS idx_trials_therapeutic     ON trials USING GIN(therapeutic_areas);
CREATE INDEX IF NOT EXISTS idx_trials_countries       ON trials USING GIN(countries);

-- Full-text search (très puissant pour recherche libre)
CREATE INDEX IF NOT EXISTS idx_trials_title_search 
    ON trials USING GIN(to_tsvector('french', title));

CREATE INDEX IF NOT EXISTS idx_trials_conditions_search 
    ON trials USING GIN(to_tsvector('french', array_to_string(conditions, ' ')));

-- Triggers pour updated_at automatique (très propre)
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp_trials
BEFORE UPDATE ON trials
FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();