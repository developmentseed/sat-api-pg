CREATE OR REPLACE VIEW collectionitems AS
  SELECT
    c.properties as collectionproperties,
    i.collection as collection,
    i.id as id,
    i.geometry as geom,
    i.bbox as bbox,
    i.type,
    i.assets,
    data.ST_AsGeoJSON(i.geometry) :: json as geometry,
    i.properties as properties,
    i.datetime as datetime,
    i.links,
    i.stac_version,
    i.tiebreak
  FROM data.itemsLinks i
  RIGHT JOIN
    data.collections c ON i.collection = c.id;
ALTER VIEW collectionitems owner to api;

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
  stac_version,
  tiebreak
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

CREATE OR REPLACE VIEW items AS
  SELECT * FROM data.items_string_geometry;
ALTER VIEW items owner to api;

CREATE OR REPLACE VIEW collections AS
  SELECT * FROM data.collectionsLinks;
ALTER VIEW collections owner to api;

CREATE OR REPLACE VIEW rootcollections AS
  SELECT * FROM data.collectionsobject;
ALTER VIEW rootcollections owner to api;

CREATE OR REPLACE VIEW root AS
  SELECT * FROM data.rootLinks;
ALTER VIEW root owner to api;

CREATE OR REPLACE VIEW stac AS
  SELECT * FROM data.stacLinks;
ALTER VIEW stac owner to api;
