-- Deploy sat-api-pg:20191211011147-fixindexperf to pg

BEGIN;

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
intersects_geometry data.geometry;
BEGIN
  --  prefer := current_setting('request.header.prefer');
IF bbox IS NOT NULL THEN
  intersects_geometry = data.ST_MakeEnvelope(
    bbox[1],
    bbox[2],
    bbox[3],
    bbox[4],
    4326
  );
ELSIF intersects IS NOT NULL THEN
  intersects_geometry = data.st_SetSRID(data.ST_GeomFromGeoJSON(intersects), 4326);
END IF;
RETURN QUERY EXECUTE
FORMAT(
  'SELECT
  collectionproperties,
  collection,
  id,
  c.geom,
  c.bbox,
  type,
  assets,
  geometry,
  CASE WHEN $2 IS NULL THEN properties
  ELSE (
    SELECT jsonb_object_agg(e.key, e.value)
    FROM jsonb_each(properties) e
    WHERE e.key = ANY ($2)
  )
END as properties,
datetime,
links,
stac_version
FROM api.collectionitems c
WHERE (
  $1 IS NULL OR
  data.ST_Intersects($1, c.geom)
) %1s %2s LIMIT %3s OFFSET %4s;
', COALESCE(andQuery, ''), sort, lim, next)
USING intersects_geometry, include;

res_headers := format('[{"Func-Range": "%s-%s/*"}]', next, (next::int + lim::int) - 1);
PERFORM set_config('response.headers', res_headers, true);

END;
$$ LANGUAGE PLPGSQL IMMUTABLE;
COMMIT;
