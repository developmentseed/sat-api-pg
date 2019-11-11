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
  andquery text default NULL,
  bbox numeric[] default NULL,
  intersects json default NULL,
  include text[] default NULL,
  sort text default 'ORDER BY c.datetime',
  next text default '0',
  lim int default 50
) RETURNS setof api.collectionitems AS $$
BEGIN
RETURN QUERY EXECUTE
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
)'
|| 
' SELECT
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
    )'
||
COALESCE(andQuery, '')
||
' ' || sort
||
' LIMIT ' || lim
||
' OFFSET ' || next
|| ';'
USING bbox, intersects, include;
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
