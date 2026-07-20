-- 009_api_surface.sql — the PostgREST API surface.
--
-- Supabase auto-exposes every table, but the app speaks its own shape: it sends
-- /v1/search?q=&page=&per_page= and decodes {stamps, total, page, per_page, total_pages}.
-- Rather than rewrite the client around PostgREST's table semantics, these RPCs present the
-- shape the client already expects. That keeps StampAPIClient host-agnostic — if we ever move
-- off Supabase, only the base URL changes.
--
-- Two things these functions deliberately do:
--   * return the SAME JSON keys as Stamp.CodingKeys, so no client-side decoding changes
--   * search country names through the succession graph, so "Rhodesia" reaches Zimbabwe. That
--     is the product's actual differentiator and it has to live server-side.

BEGIN;

-- One stamp, as the client's Stamp model expects it.
CREATE OR REPLACE FUNCTION public.stamp_json(s public.stamps)
RETURNS jsonb LANGUAGE sql STABLE AS $$
  SELECT jsonb_build_object(
    'id', s.id,
    'stamp_id', s.stamp_id,
    'uuid', s.uuid,
    'issuer', (SELECT jsonb_build_object('id', i.id, 'name', i.name,
                                         'country_iso', NULL, 'country_name', i.name)
               FROM public.issuers i WHERE i.id = s.issuer_id),
    'series', NULL,
    'format', s.format,
    'issue_date', s.issue_date,
    'issue_year', s.issue_year,
    'denomination', s.denomination,
    'currency', s.currency,
    'denomination_text', s.denomination_text,
    'colour', COALESCE(to_jsonb(s.colour), '[]'::jsonb),
    'print_method', s.print_method,
    'perforation_type', s.perforation_type,
    'perf_gauge_h', s.perf_gauge_h,
    'perf_gauge_v', s.perf_gauge_v,
    'watermark', s.watermark,
    'paper_type', s.paper_type,
    'subject', s.subject,
    'description', s.description,
    'designer', s.designer,
    'engraver', s.engraver,
    'printer', s.printer,
    'topics', COALESCE(to_jsonb(s.topics), '[]'::jsonb),
    'catalogue_refs', '[]'::jsonb,
    'primary_image_url', (SELECT im.cdn_url FROM public.stamp_images im
                          WHERE im.stamp_id = s.id AND im.is_primary LIMIT 1),
    'thumbnail_url',     (SELECT im.cdn_url FROM public.stamp_images im
                          WHERE im.stamp_id = s.id AND im.is_primary LIMIT 1),
    -- Valuations are Pro-gated and are not computed yet. Null is the honest answer; the client
    -- already renders an upgrade prompt for null rather than a price of zero.
    'valuation', NULL,
    'source_tier', s.source_tier,
    'confidence', s.confidence
  );
$$;

-- Search. Mirrors GET /v1/search.
CREATE OR REPLACE FUNCTION public.search_stamps(
  q text DEFAULT '', country text DEFAULT NULL,
  year_from int DEFAULT NULL, year_to int DEFAULT NULL,
  topic text DEFAULT NULL, page int DEFAULT 1, per_page int DEFAULT 40
) RETURNS jsonb LANGUAGE plpgsql STABLE AS $$
DECLARE
  _off int := GREATEST(0, (GREATEST(page,1) - 1) * per_page);
  _total int;
  _rows jsonb;
  _issuers int[];
BEGIN
  -- Country search walks the succession graph: typing "Rhodesia" must reach Zimbabwe, and a
  -- plain name match would silently return only the years that country used that exact name.
  IF country IS NOT NULL AND country <> '' THEN
    SELECT array_agg(DISTINCT l.issuer_id) INTO _issuers
    FROM public.issuers i
    CROSS JOIN LATERAL public.get_issuer_lineage_by_issuer(i.id) l
    WHERE i.name ILIKE country;
  END IF;

  -- Count and page are separate statements rather than one windowed query: adding
  -- row_number() to the row makes it a record, and stamp_json() takes a stamps row. The
  -- predicate is repeated deliberately — duplicating six lines beats a cast that can't work.
  SELECT count(*)::int INTO _total FROM public.stamps s
  WHERE (q IS NULL OR q = '' OR q = '*'
         OR s.subject ILIKE '%'||q||'%' OR s.description ILIKE '%'||q||'%'
         OR EXISTS (SELECT 1 FROM public.issuers i
                    WHERE i.id = s.issuer_id AND i.name ILIKE '%'||q||'%'))
    AND (_issuers IS NULL OR s.issuer_id = ANY(_issuers))
    AND (year_from IS NULL OR s.issue_year >= year_from)
    AND (year_to   IS NULL OR s.issue_year <= year_to)
    AND (topic IS NULL OR topic = '' OR s.topics && ARRAY[topic]);

  SELECT COALESCE(jsonb_agg(public.stamp_json(x.*)), '[]'::jsonb) INTO _rows FROM (
    SELECT s.* FROM public.stamps s
    WHERE (q IS NULL OR q = '' OR q = '*'
           OR s.subject ILIKE '%'||q||'%' OR s.description ILIKE '%'||q||'%'
           OR EXISTS (SELECT 1 FROM public.issuers i
                      WHERE i.id = s.issuer_id AND i.name ILIKE '%'||q||'%'))
      AND (_issuers IS NULL OR s.issuer_id = ANY(_issuers))
      AND (year_from IS NULL OR s.issue_year >= year_from)
      AND (year_to   IS NULL OR s.issue_year <= year_to)
      AND (topic IS NULL OR topic = '' OR s.topics && ARRAY[topic])
    ORDER BY s.issue_year NULLS LAST, s.id
    OFFSET _off LIMIT per_page) x;

  RETURN jsonb_build_object(
    'stamps', _rows, 'total', _total, 'page', GREATEST(page,1),
    'per_page', per_page,
    'total_pages', GREATEST(1, CEIL(_total::numeric / GREATEST(per_page,1))::int));
END;
$$;

-- One stamp by StampID. Mirrors GET /v1/stamps/{id}.
CREATE OR REPLACE FUNCTION public.get_stamp(p_stamp_id text)
RETURNS jsonb LANGUAGE sql STABLE AS $$
  SELECT public.stamp_json(s.*) FROM public.stamps s WHERE s.stamp_id = p_stamp_id;
$$;

-- Country list for the filter sheet. Only issuers that actually hold stamps — offering a
-- country that returns nothing is worse than not offering it.
CREATE OR REPLACE FUNCTION public.list_countries()
RETURNS jsonb LANGUAGE sql STABLE AS $$
  SELECT COALESCE(jsonb_agg(name ORDER BY name), '[]'::jsonb)
  FROM (SELECT DISTINCT i.name FROM public.issuers i
        JOIN public.stamps s ON s.issuer_id = i.id) t;
$$;

-- Read-only public access. The catalogue is public data; anything user-owned (collections,
-- valuations) is NOT exposed here and must go through authenticated policies when it exists.
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.search_stamps(text,text,int,int,text,int,int) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_stamp(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.list_countries() TO anon, authenticated;

-- RLS on every table, with no policy for anon. PostgREST exposes tables by default; without
-- this, the whole schema — including the users table — would be world-readable. The RPCs above
-- are SECURITY INVOKER but owned by postgres, so they still read fine.
DO $$
DECLARE t record;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t.tablename);
  END LOOP;
END $$;

COMMIT;
