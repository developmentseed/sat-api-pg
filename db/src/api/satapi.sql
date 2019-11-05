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
    i.stac_version
  FROM data.itemsLinks i
  RIGHT JOIN
    data.collections c ON i.collection = c.id;
ALTER VIEW collectionitems owner to api;

CREATE OR REPLACE FUNCTION search(
  bbox numeric[] = NULL,
  intersects json = NULL,
  include text[] = NULL
) RETURNS setof api.collectionitems AS $$
WITH g AS (
  SELECT CASE
  WHEN bbox IS NOT NULL THEN
      data.ST_MakeEnvelope(
        bbox[1],
        bbox[2],
        bbox[3],
        bbox[4],
        4326
      )
    WHEN intersects IS NOT NULL THEN
      data.st_SetSRID(
        data.ST_GeomFromGeoJSON(intersects),
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
    CASE WHEN include IS NULL THEN properties
    ELSE (
      SELECT jsonb_object_agg(e.key, e.value)
      FROM jsonb_each(properties) e
      WHERE e.key = ANY (include)
    )
    END as properties,
    datetime,
    links,
    stac_version
    FROM api.collectionitems c, g
    WHERE (
      g.geom IS NULL OR 
      data.ST_Intersects(g.geom, c.geom)
    );
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION searchnogeom(
  include TEXT[] = NULL
)
RETURNS setof api.collectionitems
AS $$
SELECT * FROM search(NULL, NULL, include);
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE VIEW items AS
  SELECT * FROM data.items_string_geometry;
ALTER VIEW items owner to api;

CREATE OR REPLACE VIEW collections AS
  SELECT * FROM data.collectionsLinks;
ALTER VIEW collections owner to api;

CREATE OR REPLACE VIEW root AS
  SELECT * FROM data.rootLinks;
ALTER VIEW root owner to api;
