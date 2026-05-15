-- 002_add_fields_to_trials.sql
-- Migration sécurisée : ajoute les nouvelles colonnes sans perdre les données

ALTER TABLE trials 
    ADD COLUMN IF NOT EXISTS sponsor_country       TEXT,
    ADD COLUMN IF NOT EXISTS sponsor_type          TEXT,
    ADD COLUMN IF NOT EXISTS ct_public_status_code INTEGER,
    ADD COLUMN IF NOT EXISTS decision_date         DATE,
    ADD COLUMN IF NOT EXISTS publish_date          DATE,
    ADD COLUMN IF NOT EXISTS therapeutic_areas     TEXT[],
    ADD COLUMN IF NOT EXISTS countries             TEXT[],
    ADD COLUMN IF NOT EXISTS last_fetched_at       TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS vulgarized_fr         TEXT,
    ADD COLUMN IF NOT EXISTS title_fr              TEXT;   -- au cas où

-- Mise à jour des indexes (IF NOT EXISTS = sécurisé)
CREATE INDEX IF NOT EXISTS idx_trials_decision_date ON trials(decision_date DESC);
CREATE INDEX IF NOT EXISTS idx_trials_last_fetched  ON trials(last_fetched_at);
CREATE INDEX IF NOT EXISTS idx_trials_therapeutic   ON trials USING GIN(therapeutic_areas);
CREATE INDEX IF NOT EXISTS idx_trials_countries     ON trials USING GIN(countries);

-- Full-text search (optionnel mais très utile)
CREATE INDEX IF NOT EXISTS idx_trials_title_search 
    ON trials USING GIN(to_tsvector('french', title));

-- Trigger updated_at (on le recrée proprement)
DROP TRIGGER IF EXISTS set_timestamp_trials ON trials;

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

-- Mise à jour des données existantes (last_fetched_at = created_at)
UPDATE trials 
SET last_fetched_at = COALESCE(last_fetched_at, created_at, NOW())
WHERE last_fetched_at IS NULL;