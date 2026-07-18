-- =============================================================================
-- Rowland Database — Core Schema v1.0
-- PostgreSQL 15+
-- =============================================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";       -- fuzzy text search
CREATE EXTENSION IF NOT EXISTS "btree_gin";     -- GIN indexes on multiple cols
CREATE EXTENSION IF NOT EXISTS "unaccent";      -- accent-insensitive search

-- =============================================================================
-- ENUMERATIONS
-- =============================================================================

CREATE TYPE stamp_format AS ENUM (
  'stamp',           -- standard postage stamp
  'minisheet',       -- mini-sheet / souvenir sheet
  'booklet_pane',    -- booklet pane
  'coil',            -- coil stamp
  'imperforate',     -- imperforate variety
  'revenue',         -- revenue / fiscal stamp
  'airmail',         -- airmail specific
  'postage_due',     -- postage due / tax
  'official',        -- official government use
  'cinderella',      -- cinderella / local / phantom
  'error',           -- printing error / EFO
  'proof',           -- proof / essay / trial colour
  'first_day_cover'  -- FDC (linked to stamps)
);

CREATE TYPE perforation_type AS ENUM (
  'line', 'comb', 'harrow', 'serpentine', 'rouletted', 'imperforate', 'syncopated'
);

CREATE TYPE print_method AS ENUM (
  'lithography', 'recess_engraving', 'typography', 'photogravure',
  'offset', 'letterpress', 'embossed', 'thermography', 'digital', 'mixed', 'unknown'
);

CREATE TYPE gum_type AS ENUM (
  'og',         -- original gum
  'og_nh',      -- OG never hinged
  'og_hr',      -- OG hinge remnant
  'no_gum',     -- no gum as issued
  'regummed',
  'self_adhesive',
  'unknown'
);

CREATE TYPE condition_grade AS ENUM (
  'superb', 'vf', 'fine', 'vg', 'good', 'fair', 'poor'
);

CREATE TYPE data_source_tier AS ENUM (
  'official',       -- UPU WNS, national postal authority
  'licensed',       -- commercially licensed (Colnect, Stamp-Store, SG)
  'contributed',    -- community contributed and reviewed
  'scraped',        -- scraped from public sources
  'ai_extracted'    -- AI-extracted, pending review
);

CREATE TYPE review_status AS ENUM (
  'pending', 'in_review', 'approved', 'rejected', 'needs_correction'
);

-- =============================================================================
-- CORE GEOGRAPHY & ISSUER TABLES
-- =============================================================================

CREATE TABLE regions (
  id            SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name          TEXT NOT NULL UNIQUE,
  code          CHAR(3) NOT NULL UNIQUE,  -- ISO 3166 alpha-3 or custom for regions
  sort_order    SMALLINT DEFAULT 0
);

CREATE TABLE countries (
  id              SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  region_id       SMALLINT REFERENCES regions(id),
  name            TEXT NOT NULL,
  name_local      TEXT,                          -- name in local language
  iso_alpha2      CHAR(2),
  iso_alpha3      CHAR(3) UNIQUE,
  iso_numeric     SMALLINT,
  upu_code        CHAR(4),                       -- UPU member country code
  sovereign_from  DATE,
  sovereign_to    DATE,                          -- NULL = still exists
  succeeded_by    SMALLINT REFERENCES countries(id),
  preceded_by     SMALLINT REFERENCES countries(id),
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_countries_iso2 ON countries(iso_alpha2);
CREATE INDEX idx_countries_name_trgm ON countries USING gin(name gin_trgm_ops);

-- Issuers: distinct from countries (e.g. German States, Confederate States, Channel Islands)
CREATE TABLE issuers (
  id              INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  country_id      SMALLINT REFERENCES countries(id),
  name            TEXT NOT NULL,
  name_local      TEXT,
  issuer_type     TEXT,   -- 'national_post', 'occupation', 'state', 'colony', 'mandate', etc.
  active_from     DATE,
  active_to       DATE,
  parent_issuer   INT REFERENCES issuers(id),
  wns_code        TEXT,   -- UPU WNS issuer code
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_issuers_country ON issuers(country_id);
CREATE INDEX idx_issuers_name_trgm ON issuers USING gin(name gin_trgm_ops);

-- =============================================================================
-- CATALOGUE SYSTEMS TABLE
-- =============================================================================

CREATE TABLE catalogue_systems (
  id          SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  code        TEXT NOT NULL UNIQUE,   -- 'scott', 'sg', 'michel', 'yvert', 'nvph', etc.
  name        TEXT NOT NULL,
  publisher   TEXT,
  country     TEXT,                   -- primary country of authority
  url         TEXT,
  notes       TEXT
);

-- Seed data
INSERT INTO catalogue_systems (code, name, publisher, country) VALUES
  ('scott',    'Scott Standard Postage Stamp Catalogue', 'Amos Media', 'US'),
  ('sg',       'Stanley Gibbons',           'Stanley Gibbons Ltd',    'GB'),
  ('michel',   'Michel-Katalog',            'Schwaneberger Verlag',   'DE'),
  ('yvert',    'Yvert et Tellier',          'Yvert et Tellier',       'FR'),
  ('nvph',     'NVPH',                      'NVPH',                   'NL'),
  ('afa',      'AFA (Postfrimærker)',        'AFA Publishers',         'DK'),
  ('facit',    'Facit',                     'Facit Förlag',           'SE'),
  ('sbk',      'Zumstein/SBK',              'Schweizerische Briefmarken-Katalog', 'CH'),
  ('ank',      'ANK (Austria Netto Katalog)','Ankermayer',            'AT'),
  ('cob',      'COB',                       'Bertrand',               'BE'),
  ('pofis',    'Pofis',                     'Pofis',                  'CZ'),
  ('wns',      'UPU WNS',                   'Universal Postal Union', 'INT'),
  ('colnect',  'Colnect',                   'Colnect',                'INT'),
  ('stanley',  'Stanley Gibbons Simplified','Stanley Gibbons Ltd',    'GB');

-- =============================================================================
-- STAMP SERIES / ISSUES
-- =============================================================================

-- A "series" groups related stamps issued together
CREATE TABLE stamp_series (
  id              INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  issuer_id       INT NOT NULL REFERENCES issuers(id),
  name            TEXT NOT NULL,
  issue_date      DATE,
  issue_date_text TEXT,                 -- "circa 1955" for approximate dates
  topic           TEXT[],               -- thematic topics: flora, fauna, royalty, etc.
  occasion        TEXT,                 -- commemorative occasion
  designer        TEXT,
  engraver        TEXT,
  printer         TEXT,
  print_method    print_method,
  perforation     TEXT,                 -- "13.5 x 14" etc
  stamp_ids       INT[],                -- denormalized for fast lookups
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_series_issuer ON stamp_series(issuer_id);
CREATE INDEX idx_series_date ON stamp_series(issue_date);
CREATE INDEX idx_series_topic ON stamp_series USING gin(topic);

-- =============================================================================
-- STAMPS — CORE TABLE
-- =============================================================================

CREATE TABLE stamps (
  -- Identity
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  stamp_id        TEXT NOT NULL UNIQUE,     -- StampID (see spec: SID-US-1847-0001-A)
  uuid            UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE,

  -- Classification
  issuer_id       INT NOT NULL REFERENCES issuers(id),
  series_id       INT REFERENCES stamp_series(id),
  format          stamp_format NOT NULL DEFAULT 'stamp',

  -- Issue details
  issue_date      DATE,
  issue_year      SMALLINT,                 -- known year even when the full date is uncertain
  issue_date_text TEXT,
  denomination    NUMERIC(12, 4),           -- face value
  currency        CHAR(3),                  -- ISO 4217
  denomination_text TEXT,                   -- "2d" or "5 Pf" or "XXIV Kreuzer"
  colour          TEXT[],                   -- ['carmine', 'deep blue']
  colour_hex      CHAR(7)[],                -- approximate hex values

  -- Physical characteristics
  print_method    print_method,
  perforation_type perforation_type,
  perf_gauge_h    NUMERIC(5, 2),            -- horizontal
  perf_gauge_v    NUMERIC(5, 2),            -- vertical
  watermark       TEXT,
  paper_type      TEXT,
  gum             gum_type,
  size_mm_h       NUMERIC(6, 2),
  size_mm_v       NUMERIC(6, 2),

  -- Design
  subject         TEXT,                     -- "Queen Victoria portrait"
  description     TEXT,                     -- AI-generated + human-reviewed
  designer        TEXT,
  engraver        TEXT,
  printer         TEXT,
  print_run       BIGINT,                   -- known print quantity

  -- Thematic
  topics          TEXT[],                   -- thematic classifications
  keywords        TEXT[],

  -- Data provenance
  source_tier     data_source_tier NOT NULL DEFAULT 'ai_extracted',
  review_status   review_status NOT NULL DEFAULT 'pending',
  reviewed_by     INT,                      -- references users(id)
  reviewed_at     TIMESTAMPTZ,
  source_url      TEXT,                     -- where this record came from
  confidence      NUMERIC(4, 3),            -- 0.000–1.000 data confidence score

  -- Timestamps
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Core indexes
CREATE INDEX idx_stamps_issuer       ON stamps(issuer_id);
CREATE INDEX idx_stamps_series       ON stamps(series_id);
CREATE INDEX idx_stamps_issue_date   ON stamps(issue_date);
CREATE INDEX idx_stamps_format       ON stamps(format);
CREATE INDEX idx_stamps_source_tier  ON stamps(source_tier);
CREATE INDEX idx_stamps_review       ON stamps(review_status);
CREATE INDEX idx_stamps_uuid         ON stamps(uuid);
CREATE INDEX idx_stamps_stamp_id     ON stamps(stamp_id);

-- Full-text search
-- Full-text search over subject + description + topics.
--
-- Two separate reasons the naive form cannot be indexed, both of which made the
-- original schema fail to apply at all:
--   1. to_tsvector('english', ...) resolves to to_tsvector(text, text), which is only
--      STABLE. The regconfig cast selects the IMMUTABLE two-arg form.
--   2. array_to_string(anyarray, text) is STABLE — it is declared that way because the
--      generic anyarray path goes through type output functions. For a plain text[] the
--      result is genuinely deterministic, so the standard workaround is to wrap the
--      expression in an IMMUTABLE function. Keep the wrapper text[]-only; widening it to
--      anyarray would make the immutability claim false.
CREATE OR REPLACE FUNCTION stamps_fts_document(
  p_subject TEXT, p_description TEXT, p_topics TEXT[]
) RETURNS tsvector AS $$
  SELECT to_tsvector('english'::regconfig,
    coalesce(p_subject, '') || ' ' ||
    coalesce(p_description, '') || ' ' ||
    coalesce(array_to_string(p_topics, ' '), '')
  )
$$ LANGUAGE sql IMMUTABLE;

CREATE INDEX idx_stamps_fts ON stamps USING gin(
  stamps_fts_document(subject, description, topics)
);

-- Trigram indexes for fuzzy matching
CREATE INDEX idx_stamps_subject_trgm ON stamps USING gin(subject gin_trgm_ops);
CREATE INDEX idx_stamps_colour_trgm  ON stamps USING gin(colour);

-- Update trigger
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER stamps_updated_at
  BEFORE UPDATE ON stamps
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- CATALOGUE CROSS-REFERENCES
-- (one row per stamp × catalogue system × number)
-- =============================================================================

CREATE TABLE catalogue_references (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  stamp_id        BIGINT NOT NULL REFERENCES stamps(id) ON DELETE CASCADE,
  catalogue_id    SMALLINT NOT NULL REFERENCES catalogue_systems(id),
  cat_number      TEXT NOT NULL,            -- e.g. "279B" or "SG 200a"
  cat_number_raw  TEXT,                     -- original unparsed number
  cat_suffix      TEXT,                     -- variety suffix within catalogue
  is_primary      BOOLEAN DEFAULT FALSE,    -- primary number for this catalogue
  confirmed       BOOLEAN DEFAULT FALSE,    -- human-verified cross-reference
  source_url      TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_catref_unique ON catalogue_references(stamp_id, catalogue_id, cat_number);
CREATE INDEX idx_catref_stamp      ON catalogue_references(stamp_id);
CREATE INDEX idx_catref_catalogue  ON catalogue_references(catalogue_id);
CREATE INDEX idx_catref_number     ON catalogue_references(cat_number);
CREATE INDEX idx_catref_number_trgm ON catalogue_references USING gin(cat_number gin_trgm_ops);

-- =============================================================================
-- STAMP IMAGES
-- =============================================================================

CREATE TABLE stamp_images (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  stamp_id        BIGINT NOT NULL REFERENCES stamps(id) ON DELETE CASCADE,
  s3_key          TEXT NOT NULL UNIQUE,     -- s3://rowland-images/<s3_key>
  cdn_url         TEXT NOT NULL,
  image_type      TEXT NOT NULL,            -- 'front', 'back', 'used', 'mint', 'detail'
  width_px        INT,
  height_px       INT,
  file_size_bytes INT,
  mime_type       TEXT DEFAULT 'image/jpeg',
  is_primary      BOOLEAN DEFAULT FALSE,
  source_url      TEXT,                     -- original URL if scraped
  licence         TEXT,                     -- 'cc0', 'cc-by', 'fair_use', 'licensed', etc.
  embedding_key   TEXT,                     -- key in Qdrant vector store
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_images_stamp     ON stamp_images(stamp_id);
CREATE INDEX idx_images_primary   ON stamp_images(stamp_id) WHERE is_primary = TRUE;
CREATE INDEX idx_images_embedding ON stamp_images(embedding_key) WHERE embedding_key IS NOT NULL;

-- =============================================================================
-- VALUATIONS
-- =============================================================================

CREATE TABLE valuation_sources (
  id      SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  code    TEXT NOT NULL UNIQUE,   -- 'ebay_sold', 'siegel', 'cherrystone', 'sg_cat', 'scott_cat'
  name    TEXT NOT NULL,
  type    TEXT NOT NULL,          -- 'auction_realised', 'catalogue_value', 'dealer_price'
  url     TEXT,
  notes   TEXT
);

INSERT INTO valuation_sources (code, name, type) VALUES
  ('ebay_sold',     'eBay Completed Sales',     'auction_realised'),
  ('siegel',        'Robert A. Siegel Auctions', 'auction_realised'),
  ('cherrystone',   'Cherrystone Philatelic',   'auction_realised'),
  ('heinrich_kohler','Heinrich Köhler',          'auction_realised'),
  ('corinphila',    'Corinphila Auctions',       'auction_realised'),
  ('david_feldman', 'David Feldman',             'auction_realised'),
  ('sg_cat',        'Stanley Gibbons Catalogue', 'catalogue_value'),
  ('scott_cat',     'Scott Standard Catalogue',  'catalogue_value'),
  ('michel_cat',    'Michel Catalogue',          'catalogue_value');

CREATE TABLE valuations (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  stamp_id        BIGINT NOT NULL REFERENCES stamps(id) ON DELETE CASCADE,
  source_id       SMALLINT NOT NULL REFERENCES valuation_sources(id),
  condition       condition_grade,
  currency        CHAR(3) NOT NULL DEFAULT 'USD',
  value_min       NUMERIC(12, 2),
  value_max       NUMERIC(12, 2),
  value_typical   NUMERIC(12, 2),
  is_used         BOOLEAN DEFAULT FALSE,    -- used vs mint
  lot_number      TEXT,                     -- auction lot reference
  sale_date       DATE,
  realised_price  NUMERIC(12, 2),           -- actual sale price if auction
  catalogue_year  SMALLINT,                 -- e.g. 2024 for catalogue prices
  source_url      TEXT,
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_valuations_stamp   ON valuations(stamp_id);
CREATE INDEX idx_valuations_source  ON valuations(source_id);
CREATE INDEX idx_valuations_date    ON valuations(sale_date);
CREATE INDEX idx_valuations_typical ON valuations(value_typical);

-- Materialised view: latest valuation per stamp per source type
CREATE MATERIALIZED VIEW stamp_latest_valuations AS
SELECT DISTINCT ON (v.stamp_id, vs.type)
  v.stamp_id,
  vs.type AS source_type,
  v.value_typical,
  v.value_min,
  v.value_max,
  v.currency,
  v.condition,
  v.is_used,
  v.sale_date,
  v.source_id,
  v.created_at
FROM valuations v
JOIN valuation_sources vs ON vs.id = v.source_id
ORDER BY v.stamp_id, vs.type, v.sale_date DESC NULLS LAST, v.created_at DESC;

CREATE UNIQUE INDEX idx_slv_stamp_type ON stamp_latest_valuations(stamp_id, source_type);

-- =============================================================================
-- USER COLLECTIONS
-- =============================================================================

CREATE TABLE users (
  id              INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  uuid            UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE,
  apple_id        TEXT UNIQUE,              -- Sign in with Apple subject ID
  email           TEXT,
  display_name    TEXT,
  subscription    TEXT DEFAULT 'free',      -- 'free', 'pro', 'dealer_pro'
  sub_expires_at  TIMESTAMPTZ,
  country_pref    SMALLINT REFERENCES countries(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  last_seen_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE collections (
  id              INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id         INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name            TEXT NOT NULL DEFAULT 'My Collection',
  description     TEXT,
  is_public       BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE collection_items (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  collection_id   INT NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
  stamp_id        BIGINT NOT NULL REFERENCES stamps(id),
  condition       condition_grade,
  gum             gum_type,
  is_used         BOOLEAN DEFAULT FALSE,
  quantity        SMALLINT DEFAULT 1,
  purchase_price  NUMERIC(10, 2),
  purchase_date   DATE,
  purchase_source TEXT,
  notes           TEXT,
  user_image_key  TEXT,                     -- user's own scan in S3
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_collitems_unique ON collection_items(collection_id, stamp_id, condition, is_used);
CREATE INDEX idx_collitems_collection ON collection_items(collection_id);
CREATE INDEX idx_collitems_stamp      ON collection_items(stamp_id);

CREATE TRIGGER collection_items_updated_at
  BEFORE UPDATE ON collection_items
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- SCAN / IDENTIFICATION LOG
-- =============================================================================

CREATE TABLE scan_logs (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id         INT REFERENCES users(id),
  scan_uuid       UUID NOT NULL DEFAULT uuid_generate_v4(),
  image_s3_key    TEXT,
  matched_stamp   BIGINT REFERENCES stamps(id),
  confidence      NUMERIC(4, 3),            -- model confidence 0.000–1.000
  top_candidates  JSONB,                    -- [{stamp_id, score}, ...] top 5
  model_version   TEXT,                     -- CoreML model version used
  scan_mode       TEXT,                     -- 'camera', 'photo_library'
  device_model    TEXT,
  os_version      TEXT,
  duration_ms     INT,
  user_confirmed  BOOLEAN,                  -- did user confirm the match?
  user_correction BIGINT REFERENCES stamps(id), -- if user picked different stamp
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_scanlogs_user    ON scan_logs(user_id);
CREATE INDEX idx_scanlogs_stamp   ON scan_logs(matched_stamp);
CREATE INDEX idx_scanlogs_date    ON scan_logs(created_at);
CREATE INDEX idx_scanlogs_conf    ON scan_logs(confidence);

-- =============================================================================
-- CONTRIBUTOR SYSTEM
-- =============================================================================

CREATE TABLE contributors (
  id              INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id         INT UNIQUE REFERENCES users(id),
  display_name    TEXT NOT NULL,
  reputation      INT DEFAULT 0,
  total_edits     INT DEFAULT 0,
  approved_edits  INT DEFAULT 0,
  rank            TEXT DEFAULT 'novice',    -- novice, collector, expert, curator
  specialties     TEXT[],                   -- country/topic specialties
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE stamp_edits (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  stamp_id        BIGINT NOT NULL REFERENCES stamps(id),
  contributor_id  INT NOT NULL REFERENCES contributors(id),
  field_changed   TEXT NOT NULL,
  old_value       JSONB,
  new_value       JSONB NOT NULL,
  edit_note       TEXT,
  status          review_status DEFAULT 'pending',
  reviewed_by     INT REFERENCES contributors(id),
  reviewed_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_edits_stamp       ON stamp_edits(stamp_id);
CREATE INDEX idx_edits_contributor ON stamp_edits(contributor_id);
CREATE INDEX idx_edits_status      ON stamp_edits(status);

-- =============================================================================
-- MARKETPLACE (Phase 4+)
-- =============================================================================

CREATE TABLE listings (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  seller_id       INT NOT NULL REFERENCES users(id),
  stamp_id        BIGINT NOT NULL REFERENCES stamps(id),
  condition       condition_grade NOT NULL,
  gum             gum_type,
  is_used         BOOLEAN DEFAULT FALSE,
  asking_price    NUMERIC(10, 2) NOT NULL,
  currency        CHAR(3) DEFAULT 'USD',
  quantity        SMALLINT DEFAULT 1,
  image_keys      TEXT[],
  description     TEXT,
  status          TEXT DEFAULT 'active',   -- 'active', 'sold', 'withdrawn'
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_listings_seller ON listings(seller_id);
CREATE INDEX idx_listings_stamp  ON listings(stamp_id);
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_listings_price  ON listings(asking_price);

-- =============================================================================
-- CRAWLER / PIPELINE TRACKING
-- =============================================================================

CREATE TABLE crawl_jobs (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  source_code     TEXT NOT NULL,            -- 'colnect', 'michel_online', 'wikimedia', etc.
  source_url      TEXT,
  job_type        TEXT NOT NULL,            -- 'discovery', 'detail', 'image', 'valuation'
  status          TEXT DEFAULT 'queued',    -- 'queued', 'running', 'done', 'failed', 'skipped'
  items_found     INT DEFAULT 0,
  items_imported  INT DEFAULT 0,
  items_updated   INT DEFAULT 0,
  items_skipped   INT DEFAULT 0,
  error_message   TEXT,
  started_at      TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_crawl_source ON crawl_jobs(source_code);
CREATE INDEX idx_crawl_status ON crawl_jobs(status);
CREATE INDEX idx_crawl_type   ON crawl_jobs(job_type);

CREATE TABLE crawl_queue (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  source_code     TEXT NOT NULL,
  url             TEXT NOT NULL UNIQUE,
  priority        SMALLINT DEFAULT 5,       -- 1 (highest) to 10 (lowest)
  depth           SMALLINT DEFAULT 0,
  parent_url      TEXT,
  status          TEXT DEFAULT 'pending',
  attempts        SMALLINT DEFAULT 0,
  last_error      TEXT,
  scheduled_after TIMESTAMPTZ DEFAULT NOW(),
  claimed_at      TIMESTAMPTZ,
  claimed_by      TEXT,                     -- worker instance ID
  completed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_queue_status_priority ON crawl_queue(status, priority, scheduled_after)
  WHERE status = 'pending';
CREATE INDEX idx_queue_source ON crawl_queue(source_code);
