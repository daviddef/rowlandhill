-- 008_missing_succession_edges.sql
--
-- Nine succession edges that were missing, found by asking a blunt question of the 17 countries
-- the coverage report calls "not yet held": how many stamps does each actually REACH through the
-- succession graph? Several reached zero while a predecessor issuer holding their stamps sat
-- right there in the table, unlinked. Timor-Leste reached 0 with 16 Portuguese Timor stamps
-- loaded; South Sudan reached 0 with 22 Sudan stamps loaded.
--
-- Dates and relationships are from the country dossiers in docs/research/base-catalogue/,
-- which are sourced and flag their own uncertainties. Where a dossier could not establish a
-- date, succession_date is left NULL rather than guessed.
--
-- DELIBERATELY NOT ADDED — metropole edges. Georgia already reaches 12,723 stamps because its
-- ancestor walk climbs into the USSR and returns the entire Soviet corpus. That is correct
-- history and useless search: nobody typing "Georgia" wants 11,849 Soviet stamps. The same trap
-- is waiting for Faroe Islands -> Denmark (1,187) and Aruba -> Curacao/Netherlands Antilles.
-- Those edges are real and should exist eventually, but not before the schema can distinguish
-- "issued by this authority" from "used in this territory" -- see the note at the foot.

BEGIN;

INSERT INTO issuer_succession (predecessor_id, successor_id, succession_type, succession_date, notes)
VALUES
  -- Timor. Portuguese Timor's 16 stamps were unreachable from Timor-Leste. The UNTAET issuer
  -- is the 1999-2002 UN transitional administration, which issued 2 stamps of its own.
  (807, 1036, 'occupation',    '1999-10-25', 'UNTAET assumes administration; Portuguese Timor issues end 1975'),
  (1036, 1035, 'independence', '2002-05-20', 'Restoration of independence; UNTAET issues supersede'),

  -- Sudan -> South Sudan. 22 Sudan stamps become reachable.
  (995, 962, 'partition', '2011-07-09', 'Independence of South Sudan'),

  -- Falklands. The Dependencies (16 stamps) are an offshoot of the Falklands administration,
  -- not a predecessor -- direction matters, and the descendants-only walk is what reaches them.
  (316, 317, 'partition', '1944-02-21', 'First Dependencies issues; administered from Stanley'),

  -- Gabon. Reached via French Equatorial Africa (8 stamps).
  (351, 373, 'independence', '1960-08-17', 'Independence from French Equatorial Africa'),

  -- Upper Volta -> Burkina Faso. A pure rename, so a name search must cross it.
  -- NB the dossier corrects the commonly-cited gap: Upper Volta was dissolved into its
  -- neighbours and issued nothing 1933-1959, not 1932-1947.
  (1107, 151, 'renamed', '1984-08-04', 'Upper Volta renamed Burkina Faso'),

  -- Namibia, via South West Africa. Two hops, both real.
  (390, 964, 'annexation',   '1915-07-09', 'South African occupation of German South West Africa'),
  (964, 670, 'independence', '1990-03-21', 'Independence as Namibia'),

  -- Korea. The Soviet occupation zone precedes the DPRK's own issues.
  (722, 721, 'regime_change', '1948-09-09', 'Establishment of the DPRK')
ON CONFLICT DO NOTHING;

COMMIT;

-- KNOWN GAP, recorded here because it is the next real piece of work.
--
-- Timor-Leste has 24 years of postal history -- 1976 to 1999 -- catalogued under INDONESIA
-- (issuer 457). No edge is added for it, because adding one would pull the whole Indonesian
-- corpus into a Timor search, which is the Georgia/USSR problem again.
--
-- The fix is not another edge. It is a distinction the schema does not yet draw:
--
--   issued_by     -- this authority printed the stamp        (Portuguese Timor -> Timor-Leste)
--   used_in       -- this stamp was valid in that territory  (Indonesia -> Timor-Leste)
--
-- A search for a country wants the union when the user is identifying a stamp they physically
-- hold, and issued_by alone when they are browsing a country's own output. One boolean on
-- issuer_succession, plus a parameter on get_issuer_lineage_by_issuer, would carry it.
