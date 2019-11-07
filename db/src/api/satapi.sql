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

CREATE FUNCTION search(
  bbox numeric[] = NULL,
  intersects json = NULL,
  include TEXT[] = NULL
)
RETURNS setof api.collectionitems
AS $$
DECLARE
  intersects_geometry data.geometry;
BEGIN
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
  IF include IS NOT NULL THEN
    RETURN QUERY
    SELECT
    collectionproperties,
    collection,
    id,
    geom,
    collectionitems.bbox,
    type,
    assets,
    geometry,
    (select jsonb_object_agg(e.key, e.value)
      from jsonb_each(properties) e
      where e.key = ANY (include)) properties,
    datetime,
    links,
    stac_version
    FROM api.collectionitems
    WHERE data.ST_INTERSECTS(collectionitems.geom, intersects_geometry);
  ELSE
    RETURN QUERY
    SELECT *
    FROM api.collectionitems
    WHERE data.ST_INTERSECTS(collectionitems.geom, intersects_geometry);
  END IF;
END
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE FUNCTION searchnogeom(
  include TEXT[] = NULL
)
RETURNS setof api.collectionitems
AS $$
BEGIN
  IF include IS NOT NULL THEN
    RETURN QUERY
    SELECT
    collectionproperties,
    collection,
    id,
    geom,
    bbox,
    type,
    assets,
    geometry,
    (select jsonb_object_agg(e.key, e.value)
      from jsonb_each(properties) e
      where e.key = ANY (include)) properties,
    datetime,
    links,
    stac_version
    FROM api.collectionitems;
  ELSE
    RETURN QUERY
    SELECT *
    FROM api.collectionitems;
  END IF;
END
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE VIEW items AS
  SELECT * FROM data.items_string_geometry;
ALTER VIEW items owner to api;

CREATE OR REPLACE VIEW collections AS
  SELECT * FROM data.collectionsLinks;
ALTER VIEW collections owner to api;

CREATE OR REPLACE VIEW root AS
  SELECT * FROM data.rootLinks;
ALTER VIEW root owner to api;

CREATE OR REPLACE VIEW stac AS
  SELECT * FROM data.stacLinks;
ALTER VIEW root owner to api;
