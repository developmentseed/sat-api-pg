-- Deploy sat-api-pg:20200217192155-tiebreak to pg

BEGIN;
ALTER TABLE data.items ADD COLUMN tiebreak SERIAL;


DROP VIEW data.itemsLinks CASCADE;
CREATE OR REPLACE VIEW data.itemsLinks AS
  SELECT
  id,
  type,
  geometry,
  bbox,
  properties,
  assets,
  collection,
  datetime,
  '0.8.0' AS stac_version,
  (SELECT array_cat(ARRAY[
    ROW((
        SELECT url || '/collections/' || collection || '/' || id
        FROM data.apiUrls LIMIT 1),
        'self',
        'application/geo+json',
        null)::data.linkobject,
    ROW((
        SELECT url || '/collections/' || collection
        FROM data.apiUrls LIMIT 1),
        'parent',
        'application/json',
        null)::data.linkobject
  ], links)) as links,
  tiebreak
  FROM data.items i;

CREATE VIEW data.items_string_geometry AS
  SELECT
  id,
  type,
  data.ST_AsGeoJSON(geometry) :: json as geometry,
  bbox,
  properties,
  assets,
  collection,
  datetime,
  links,
  stac_version
  FROM data.itemsLinks;

CREATE TRIGGER convert_geometry_tg INSTEAD OF INSERT
   ON data.items_string_geometry FOR EACH ROW
   EXECUTE PROCEDURE data.convert_values();

CREATE OR REPLACE VIEW api.collectionitems AS
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

CREATE OR REPLACE VIEW api.items AS SELECT * FROM data.items_string_geometry;

GRANT select, insert, update on data.items_string_geometry to api;
GRANT select, insert, update on data.itemsLinks to api;

GRANT select, insert, update on data.itemsLinks to application;
GRANT select, insert, update on api.items to application;
GRANT select, insert, update on data.items_string_geometry to application;
GRANT usage ON sequence data.items_tiebreak_seq TO application;

GRANT select on api.collectionitems to anonymous;
GRANT select on api.items to anonymous;

COMMIT;
