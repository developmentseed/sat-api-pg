CREATE OR REPLACE VIEW collectionitems AS
  SELECT c.name as collection,
    c.properties as collectionproperties,
    i.id as id,
    data.ST_AsGeoJSON(i.geometry) :: json as geometry,
    i.properties as properties
  FROM data.items i
  RIGHT JOIN
    data.collections c ON i.collection_id = c.collection_id;
ALTER VIEW collectionitems owner to api;

CREATE FUNCTION search(bbox numeric[])
RETURNS setof collectionitems
AS $$
DECLARE
BEGIN
  RETURN QUERY
  SELECT *
  FROM collectionitems
  WHERE ST_INTERSECTS(collectionitems.geom, ST_MakeEnvelope(bbox[1], bbox[2], bbox[3], bbox[4], 4326));
END
$$ LANGUAGE plpgsql
