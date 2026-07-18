-- 007_reattribute_by_era.sql
--
-- Fixes a systematic misattribution in the Commons-sourced corpus.
--
-- Wikimedia Commons files stamps under the MODERN country name regardless of era, so a
-- 1970 Soviet stamp lands under "Russia" (an issuer that only begins in 1992), an 1890
-- German Empire stamp under "Germany" (1991+), and Trucial States issues under the UAE
-- (1973+). Measured before this migration: 18,161 dated stamps — 17.2% of all dated
-- records — sat outside their issuer's active window.
--
-- This is exactly the problem the succession graph exists to solve. For each misdated
-- stamp, walk its issuer's ANCESTORS and move it to the nearest one whose active window
-- actually contains the issue year. A 1970 "Russia" stamp becomes a USSR stamp; an 1890
-- "Germany" stamp becomes Imperial Germany.
--
-- Idempotent: re-running finds nothing left to move. Safe to apply after 006.

BEGIN;

-- Stamps whose year cannot belong to their current issuer.
-- Pre-1840 records are excluded: stamps did not exist before the Penny Black, so those are
-- filename parse noise (e.g. a "1815" in a title), not misattribution, and are left for review.
CREATE TEMP TABLE _misdated AS
SELECT s.id, s.issue_year, s.issuer_id
FROM stamps s
JOIN issuers i ON i.id = s.issuer_id
WHERE s.issue_year IS NOT NULL
  AND s.issue_year >= 1840
  AND ( (i.active_from IS NOT NULL AND s.issue_year < extract(year from i.active_from) - 1)
     OR (i.active_to   IS NOT NULL AND s.issue_year > extract(year from i.active_to) + 1) );

-- Nearest ancestor (largest depth, i.e. fewest hops back) whose window contains the year.
CREATE TEMP TABLE _reattribution AS
SELECT DISTINCT ON (m.id) m.id AS stamp_id, l.issuer_id AS new_issuer_id
FROM _misdated m
CROSS JOIN LATERAL get_issuer_lineage_by_issuer(m.issuer_id) l
JOIN issuers a ON a.id = l.issuer_id
WHERE l.depth < 0                                   -- ancestors only, never forward in time
  AND a.id <> m.issuer_id
  AND (a.active_from IS NULL OR m.issue_year >= extract(year from a.active_from) - 1)
  AND (a.active_to   IS NULL OR m.issue_year <= extract(year from a.active_to) + 1)
ORDER BY m.id, l.depth DESC;                        -- -1 before -2: closest ancestor wins

UPDATE stamps s
SET issuer_id = r.new_issuer_id,
    updated_at = NOW()
FROM _reattribution r
WHERE s.id = r.stamp_id;

COMMIT;
