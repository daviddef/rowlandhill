-- =============================================================================
-- Rowland — Country Succession, Name History & Cross-Era Search
-- Schema patch 004 — extends 001_core_schema.sql
--
-- Design principle: A single "search" for "Rhodesia" or "Zimbabwe" must surface
-- ALL stamps from ALL political entities in that lineage — across all names,
-- all predecessor/successor states, and all overlapping jurisdictions.
-- =============================================================================

-- =============================================================================
-- COUNTRY & ISSUER NAME HISTORY
-- Every name a country/issuer has ever been known by, with date ranges
-- =============================================================================

CREATE TABLE country_name_history (
  id              INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  country_id      SMALLINT NOT NULL REFERENCES countries(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  name_local      TEXT,                          -- name in local/native language
  name_type       TEXT NOT NULL,                 -- 'official', 'common', 'postal', 'philatelic', 'colonial', 'alias'
  language        CHAR(3),                       -- ISO 639-3 language code
  valid_from      DATE,
  valid_to        DATE,                          -- NULL = still in use
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_cnh_country     ON country_name_history(country_id);
CREATE INDEX idx_cnh_name_trgm   ON country_name_history USING gin(name gin_trgm_ops);
CREATE INDEX idx_cnh_valid_from  ON country_name_history(valid_from);

-- =============================================================================
-- COUNTRY SUCCESSION CHAINS
-- Explicit directed graph of political succession
-- Enables "get all issuers in this lineage" queries
-- =============================================================================

CREATE TABLE country_succession (
  id                  INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  predecessor_id      SMALLINT NOT NULL REFERENCES countries(id),
  successor_id        SMALLINT NOT NULL REFERENCES countries(id),
  succession_type     TEXT NOT NULL,    -- see enum below
  succession_date     DATE,            -- when the transition occurred
  overlap_from        DATE,            -- for overlapping periods (UDI, partition, etc.)
  overlap_to          DATE,
  notes               TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT no_self_succession CHECK (predecessor_id <> successor_id)
);

-- succession_type values:
--   'rename'          — same entity, name changed (Ceylon → Sri Lanka)
--   'independence'    — colony/territory became sovereign (Rhodesia → Zimbabwe)
--   'dissolution'     — state dissolved, territory redistributed (USSR → 15 states)
--   'unification'     — multiple states merged (German states → German Empire)
--   'partition'       — one state split into multiple (India/Pakistan 1947, Czechoslovakia → CZ+SK)
--   'occupation'      — occupying power issued stamps for territory (German occupation of France)
--   'transfer'        — territory transferred between sovereigns (Togo: German → British/French)
--   'restoration'     — state restored after occupation or annexation

CREATE UNIQUE INDEX idx_succession_unique ON country_succession(predecessor_id, successor_id, succession_type);
CREATE INDEX idx_succession_pred ON country_succession(predecessor_id);
CREATE INDEX idx_succession_succ ON country_succession(successor_id);

-- =============================================================================
-- ISSUER SUCCESSION CHAINS
-- More granular than country-level — stamp-issuing entity continuity
-- (e.g., "Rhodesia Post" → "Zimbabwe Posts" issuing authority)
-- =============================================================================

CREATE TABLE issuer_succession (
  id                  INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  predecessor_id      INT NOT NULL REFERENCES issuers(id),
  successor_id        INT NOT NULL REFERENCES issuers(id),
  succession_type     TEXT NOT NULL,
  succession_date     DATE,
  notes               TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_issuer_succ_pred ON issuer_succession(predecessor_id);
CREATE INDEX idx_issuer_succ_succ ON issuer_succession(successor_id);

-- =============================================================================
-- GEOGRAPHIC TERRITORY MAPPING
-- Links issuers to geographic regions regardless of political name
-- Enables "show all stamps ever issued for this territory"
-- =============================================================================

CREATE TABLE territories (
  id              INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name            TEXT NOT NULL,         -- stable geographic name (e.g., "Zimbabwe Plateau", "Rhine Province")
  geo_type        TEXT,                  -- 'nation', 'region', 'colony', 'territory', 'city'
  centroid_lat    NUMERIC(9, 6),
  centroid_lon    NUMERIC(9, 6),
  bounding_box    JSONB,                 -- {n, s, e, w} decimal degrees
  notes           TEXT
);

CREATE TABLE issuer_territory (
  issuer_id       INT NOT NULL REFERENCES issuers(id),
  territory_id    INT NOT NULL REFERENCES territories(id),
  controlled_from DATE,
  controlled_to   DATE,
  PRIMARY KEY (issuer_id, territory_id)
);

-- =============================================================================
-- SEARCH ALIAS TABLE
-- Powers "did you mean" and cross-name search in Elasticsearch
-- One row per (alias → canonical) mapping
-- =============================================================================

CREATE TABLE search_aliases (
  id              INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  alias           TEXT NOT NULL,         -- the alternative name/spelling users might search
  alias_type      TEXT NOT NULL,         -- 'former_name', 'colonial_name', 'local_name', 'common_name', 'abbreviation', 'transliteration'
  entity_type     TEXT NOT NULL,         -- 'country', 'issuer', 'territory'
  entity_id       INT NOT NULL,          -- references countries(id) or issuers(id)
  valid_from      DATE,
  valid_to        DATE,
  language        CHAR(3),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_aliases_alias    ON search_aliases USING gin(alias gin_trgm_ops);
CREATE INDEX idx_aliases_entity   ON search_aliases(entity_type, entity_id);

-- =============================================================================
-- SEED DATA — Major Country Successions
-- This is authoritative data for the Rowland IP layer
-- =============================================================================

-- First, seed the countries we reference below (extend the main countries table)
-- Note: These INSERT statements assume the base countries table already has
-- entries for modern nations. We add historical entities here.

-- We use a helper function to get/create country entries
CREATE OR REPLACE FUNCTION ensure_country(
  p_name TEXT, p_iso2 CHAR(2), p_iso3 CHAR(3),
  p_from DATE, p_to DATE
) RETURNS SMALLINT AS $$
DECLARE v_id SMALLINT;
BEGIN
  SELECT id INTO v_id FROM countries WHERE iso_alpha3 = p_iso3;
  IF v_id IS NULL THEN
    INSERT INTO countries (name, iso_alpha2, iso_alpha3, sovereign_from, sovereign_to)
    VALUES (p_name, p_iso2, p_iso3, p_from, p_to)
    RETURNING id INTO v_id;
  END IF;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- AFRICA — Key succession chains
-- =============================================================================

-- Zimbabwe / Rhodesia lineage
DO $$
DECLARE
  bsac_id      SMALLINT;
  s_rhodesia   SMALLINT;
  fed_rn_id    SMALLINT;
  n_rhodesia   SMALLINT;
  nyasaland_id SMALLINT;
  rhodesia_id  SMALLINT;
  zim_rhod_id  SMALLINT;
  zimbabwe_id  SMALLINT;
  zambia_id    SMALLINT;
  malawi_id    SMALLINT;
BEGIN
  bsac_id     := ensure_country('British South Africa Company Territory', NULL, 'BSA', '1890-01-01', '1924-01-01');
  s_rhodesia  := ensure_country('Southern Rhodesia', 'RH', 'SRH', '1924-01-01', '1980-04-18');
  fed_rn_id   := ensure_country('Federation of Rhodesia and Nyasaland', NULL, 'FRN', '1954-01-01', '1963-12-31');
  n_rhodesia  := ensure_country('Northern Rhodesia', NULL, 'NRH', '1925-01-01', '1964-10-24');
  nyasaland_id:= ensure_country('Nyasaland Protectorate', NULL, 'NYS', '1891-01-01', '1964-07-06');
  rhodesia_id := ensure_country('Rhodesia (UDI)', 'RH', 'RHO', '1965-11-11', '1980-04-18');
  zim_rhod_id := ensure_country('Zimbabwe Rhodesia', NULL, 'ZRH', '1979-06-01', '1980-04-18');
  zimbabwe_id := ensure_country('Zimbabwe', 'ZW', 'ZWE', '1980-04-18', NULL);
  zambia_id   := ensure_country('Zambia', 'ZM', 'ZMB', '1964-10-24', NULL);
  malawi_id   := ensure_country('Malawi', 'MW', 'MWI', '1964-07-06', NULL);

  -- Succession chain
  INSERT INTO country_succession (predecessor_id, successor_id, succession_type, succession_date, notes) VALUES
    (bsac_id,     s_rhodesia,  'rename',       '1924-01-01', 'BSAC territory became Crown Colony of Southern Rhodesia'),
    (s_rhodesia,  fed_rn_id,   'unification',  '1954-01-01', 'Joined Federation of Rhodesia and Nyasaland'),
    (n_rhodesia,  fed_rn_id,   'unification',  '1954-01-01', 'Northern Rhodesia joined Federation'),
    (nyasaland_id,fed_rn_id,   'unification',  '1954-01-01', 'Nyasaland joined Federation'),
    (fed_rn_id,   rhodesia_id, 'dissolution',  '1963-12-31', 'Federation dissolved; Southern Rhodesia declared UDI 1965'),
    (fed_rn_id,   n_rhodesia,  'dissolution',  '1963-12-31', 'Northern Rhodesia regained separate status'),
    (fed_rn_id,   nyasaland_id,'dissolution',  '1963-12-31', 'Nyasaland regained separate status'),
    (n_rhodesia,  zambia_id,   'independence', '1964-10-24', 'Northern Rhodesia became Zambia at independence'),
    (nyasaland_id,malawi_id,   'independence', '1964-07-06', 'Nyasaland became Malawi at independence'),
    (rhodesia_id, zim_rhod_id, 'rename',       '1979-06-01', 'UDI Rhodesia became Zimbabwe Rhodesia under internal settlement'),
    (zim_rhod_id, zimbabwe_id, 'independence', '1980-04-18', 'Zimbabwe Rhodesia became Zimbabwe at independence'),
    (s_rhodesia,  zimbabwe_id, 'independence', '1980-04-18', 'Direct Southern Rhodesia → Zimbabwe lineage link')
  ON CONFLICT DO NOTHING;

  -- Search aliases for Zimbabwe/Rhodesia family
  INSERT INTO search_aliases (alias, alias_type, entity_type, entity_id) VALUES
    ('Rhodesia',             'former_name',    'country', zimbabwe_id),
    ('Southern Rhodesia',    'former_name',    'country', zimbabwe_id),
    ('Zimbabwe Rhodesia',    'former_name',    'country', zimbabwe_id),
    ('UDI Rhodesia',         'common_name',    'country', rhodesia_id),
    ('Zimabwe',              'common_name',    'country', zimbabwe_id),  -- common misspelling
    ('Rhodesia & Nyasaland', 'former_name',    'country', fed_rn_id),
    ('N. Rhodesia',          'abbreviation',   'country', n_rhodesia),
    ('N. Rhodesia',          'abbreviation',   'country', zambia_id),
    ('Northern Rhodesia',    'former_name',    'country', zambia_id),
    ('Nyasaland',            'former_name',    'country', malawi_id)
  ON CONFLICT DO NOTHING;
END;
$$;

-- Guinea-Bissau / Portuguese Guinea lineage
DO $$
DECLARE
  port_guinea_id SMALLINT;
  paigc_id       SMALLINT;
  guinea_bis_id  SMALLINT;
BEGIN
  port_guinea_id := ensure_country('Portuguese Guinea', NULL, 'PGN', '1879-01-01', '1974-09-10');
  paigc_id       := ensure_country('PAIGC Liberated Territories', NULL, 'PAI', '1963-01-01', '1974-09-10');
  guinea_bis_id  := ensure_country('Guinea-Bissau', 'GW', 'GNB', '1974-09-10', NULL);

  INSERT INTO country_succession (predecessor_id, successor_id, succession_type, succession_date, notes) VALUES
    (port_guinea_id, guinea_bis_id, 'independence', '1974-09-10', 'Portuguese Guinea became Guinea-Bissau'),
    (paigc_id,       guinea_bis_id, 'independence', '1974-09-10', 'PAIGC provisional government became Guinea-Bissau state')
  ON CONFLICT DO NOTHING;

  INSERT INTO search_aliases (alias, alias_type, entity_type, entity_id) VALUES
    ('Portuguese Guinea',    'colonial_name', 'country', guinea_bis_id),
    ('Guiné-Bissau',         'local_name',    'country', guinea_bis_id),
    ('Guinée-Bissau',        'local_name',    'country', guinea_bis_id),
    ('PAIGC',                'former_name',   'country', guinea_bis_id),
    ('Guinea Bissau',        'common_name',   'country', guinea_bis_id)  -- no hyphen variant
  ON CONFLICT DO NOTHING;
END;
$$;

-- =============================================================================
-- EUROPE — Key succession chains
-- =============================================================================

DO $$
DECLARE
  german_empire_id SMALLINT;
  weimar_id        SMALLINT;
  third_reich_id   SMALLINT;
  west_germany_id  SMALLINT;
  east_germany_id  SMALLINT;
  germany_id       SMALLINT;
BEGIN
  german_empire_id := ensure_country('German Empire (Deutsches Reich)', 'DE', 'DER', '1871-01-18', '1918-11-09');
  weimar_id        := ensure_country('Weimar Republic', 'DE', 'WMR', '1919-08-11', '1933-01-30');
  third_reich_id   := ensure_country('Third Reich (Nazi Germany)', 'DE', 'NSG', '1933-01-30', '1945-05-08');
  west_germany_id  := ensure_country('West Germany (BRD)', 'DE', 'BRD', '1949-05-23', '1990-10-03');
  east_germany_id  := ensure_country('East Germany (DDR)', 'DD', 'DDR', '1949-10-07', '1990-10-03');
  germany_id       := ensure_country('Germany', 'DE', 'DEU', '1990-10-03', NULL);

  INSERT INTO country_succession (predecessor_id, successor_id, succession_type, succession_date, notes) VALUES
    (german_empire_id, weimar_id,       'rename',       '1919-08-11', 'German Empire → Weimar Republic'),
    (weimar_id,        third_reich_id,  'rename',       '1933-01-30', 'Weimar Republic → Third Reich'),
    (third_reich_id,   west_germany_id, 'partition',    '1949-05-23', 'Western Germany → BRD'),
    (third_reich_id,   east_germany_id, 'partition',    '1949-10-07', 'Eastern Germany → DDR'),
    (west_germany_id,  germany_id,      'unification',  '1990-10-03', 'German reunification'),
    (east_germany_id,  germany_id,      'unification',  '1990-10-03', 'German reunification')
  ON CONFLICT DO NOTHING;

  INSERT INTO search_aliases (alias, alias_type, entity_type, entity_id) VALUES
    ('Deutsches Reich',    'local_name',   'country', german_empire_id),
    ('Deutsches Reich',    'local_name',   'country', third_reich_id),
    ('BRD',                'abbreviation', 'country', west_germany_id),
    ('West Germany',       'common_name',  'country', west_germany_id),
    ('DDR',                'abbreviation', 'country', east_germany_id),
    ('East Germany',       'common_name',  'country', east_germany_id),
    ('Nazi Germany',       'common_name',  'country', third_reich_id),
    ('Reich',              'abbreviation', 'country', german_empire_id),
    ('Weimar',             'common_name',  'country', weimar_id)
  ON CONFLICT DO NOTHING;
END;
$$;

-- USSR / Russia
DO $$
DECLARE
  imperial_russia_id SMALLINT;
  ussr_id            SMALLINT;
  russia_id          SMALLINT;
BEGIN
  imperial_russia_id := ensure_country('Imperial Russia', 'RU', 'RUI', '1858-01-01', '1917-11-07');
  ussr_id            := ensure_country('Soviet Union (USSR)', 'SU', 'SUN', '1922-12-30', '1991-12-25');
  russia_id          := ensure_country('Russia', 'RU', 'RUS', '1991-12-25', NULL);

  INSERT INTO country_succession (predecessor_id, successor_id, succession_type, succession_date, notes) VALUES
    (imperial_russia_id, ussr_id,  'rename',      '1922-12-30', 'Russian Soviet Republic → USSR'),
    (ussr_id,            russia_id,'dissolution', '1991-12-25', 'USSR dissolved')
  ON CONFLICT DO NOTHING;

  INSERT INTO search_aliases (alias, alias_type, entity_type, entity_id) VALUES
    ('Soviet Union',   'common_name',  'country', ussr_id),
    ('CCCP',           'abbreviation', 'country', ussr_id),
    ('СССР',           'local_name',   'country', ussr_id),
    ('RSFSR',          'former_name',  'country', ussr_id),
    ('Tsarist Russia', 'common_name',  'country', imperial_russia_id),
    ('Imperial Russia','former_name',  'country', russia_id)
  ON CONFLICT DO NOTHING;
END;
$$;

-- =============================================================================
-- SEARCH HELPER FUNCTION
-- Returns all issuer_ids in a country's lineage (predecessors AND successors)
-- Use this in API queries to power "show all Rhodesia stamps" across all eras
-- =============================================================================

CREATE OR REPLACE FUNCTION get_issuer_lineage(p_country_id SMALLINT)
RETURNS TABLE(issuer_id INT, country_id SMALLINT, depth INT) AS $$
WITH RECURSIVE lineage AS (
  -- Start with all issuers for the given country
  SELECT i.id AS issuer_id, i.country_id, 0 AS depth
  FROM issuers i
  WHERE i.country_id = p_country_id

  UNION ALL

  -- Walk predecessors
  SELECT i.id, i.country_id, l.depth - 1
  FROM lineage l
  JOIN country_succession cs ON cs.successor_id = l.country_id
  JOIN issuers i ON i.country_id = cs.predecessor_id
  WHERE l.depth > -20  -- max 20 hops back

  UNION ALL

  -- Walk successors
  SELECT i.id, i.country_id, l.depth + 1
  FROM lineage l
  JOIN country_succession cs ON cs.predecessor_id = l.country_id
  JOIN issuers i ON i.country_id = cs.successor_id
  WHERE l.depth < 20   -- max 20 hops forward
)
SELECT DISTINCT issuer_id, country_id, depth FROM lineage;
$$ LANGUAGE sql STABLE;

-- =============================================================================
-- EXAMPLE USAGE
-- =============================================================================
-- Get all stamps ever issued for Zimbabwe (across all political names):
--
-- SELECT s.* FROM stamps s
-- JOIN (SELECT issuer_id FROM get_issuer_lineage(
--   (SELECT id FROM countries WHERE iso_alpha3 = 'ZWE')
-- )) l ON s.issuer_id = l.issuer_id
-- ORDER BY s.issue_date;
--
-- This will return stamps from:
--   BSAC territory (1890–1924)
--   Southern Rhodesia (1924–1953)
--   Federation of Rhodesia & Nyasaland (1954–1963)
--   UDI Rhodesia (1965–1979)
--   Zimbabwe Rhodesia (1979–1980)
--   Zimbabwe (1980–present)
-- =============================================================================

-- =============================================================================
-- ELASTICSEARCH SYNC — country alias index
-- Run this query to build the ES alias dictionary for search
-- =============================================================================

CREATE OR REPLACE VIEW v_country_search_terms AS
SELECT
  c.id AS country_id,
  c.name AS canonical_name,
  c.iso_alpha2,
  c.iso_alpha3,
  ARRAY_AGG(DISTINCT sa.alias) FILTER (WHERE sa.alias IS NOT NULL) AS aliases,
  ARRAY_AGG(DISTINCT cnh.name) FILTER (WHERE cnh.name IS NOT NULL) AS historical_names
FROM countries c
LEFT JOIN search_aliases sa ON sa.entity_type = 'country' AND sa.entity_id = c.id
LEFT JOIN country_name_history cnh ON cnh.country_id = c.id
GROUP BY c.id, c.name, c.iso_alpha2, c.iso_alpha3;
