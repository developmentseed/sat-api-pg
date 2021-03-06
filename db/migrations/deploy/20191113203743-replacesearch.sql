-- Deploy sat-api-pg:20191113203743-replacesearch to pg

BEGIN;

DROP FUNCTION IF EXISTS api.search(
  bbox numeric[],
  intersects json,
  include TEXT[]
);

DROP FUNCTION IF EXISTS api.searchnogeom(
  include TEXT[]
);

CREATE OR REPLACE FUNCTION api.search(
  bbox numeric[] default NULL,
  intersects json default NULL,
  include text[] default NULL,
  andquery text default NULL,
  sort text default 'ORDER BY c.datetime',
  lim int default 50,
  next text default '0'
) RETURNS setof api.collectionitems AS $$
DECLARE
  res_headers text;
  prefer text;
BEGIN
 --  prefer := current_setting('request.header.prefer');
RETURN QUERY EXECUTE
FORMAT(
'WITH g AS (
  SELECT CASE
  WHEN $1 IS NOT NULL THEN
    data.ST_MakeEnvelope(
      $1[1],
      $1[2],
      $1[3],
      $1[4],
      4326
    )
  WHEN $2 IS NOT NULL THEN
    data.st_SetSRID(
      data.ST_GeomFromGeoJSON($2),
      4326
    )
  ELSE
    NULL
  END AS geom
)
SELECT
  collectionproperties,
  collection,
  id,
  c.geom,
  c.bbox,
  type,
  assets,
  geometry,
  CASE WHEN $3 IS NULL THEN properties
  ELSE (
    SELECT jsonb_object_agg(e.key, e.value)
    FROM jsonb_each(properties) e
    WHERE e.key = ANY ($3)
  )
  END as properties,
  datetime,
  links,
  stac_version
  FROM api.collectionitems c, g
  WHERE (
    g.geom IS NULL OR
    data.ST_Intersects(g.geom, c.geom)
  ) %1s %2s LIMIT %3s OFFSET %4s;
', COALESCE(andQuery, ''), sort, lim, next)
USING bbox, intersects, include;

res_headers := format('[{"Func-Range": "%s-%s/*"}]', next, (next::int + lim::int) - 1);
PERFORM set_config('response.headers', res_headers, true);
END;
$$ LANGUAGE PLPGSQL IMMUTABLE;

COMMIT;
