CREATE EXTENSION postgis SCHEMA data;
CREATE EXTENSION ltree SCHEMA data;
CREATE TABLE collections(
  collection_id varchar(1024) PRIMARY KEY,
  description varchar(1024),
  properties jsonb
);
CREATE TABLE items(
  item_id serial PRIMARY KEY,
  id varchar(1024) NOT NULL,
  type varchar(20) NOT NULL,
  geometry geometry,
  properties jsonb NOT NULL,
  assets jsonb,
  collection varchar(1024),
  CONSTRAINT fk_collection FOREIGN KEY (collection) REFERENCES collections(collection_id)
);

CREATE VIEW items_string_geometry AS
  SELECT item_id,
  id,
  type,
  data.ST_AsGeoJSON(geometry) :: json as geometry,
  properties,
  assets,
  collection
  FROM data.items;

CREATE OR REPLACE FUNCTION convert_geometry()
  RETURNS trigger AS
  $BODY$
  DECLARE
    converted_geometry data.geometry;
  BEGIN
    --  IF TG_OP = 'INSERT' AND (NEW.geometry ISNULL) THEN
      --  RAISE EXCEPTION 'geometry is required';
      --  RETURN NULL;
    --  END IF;
  --  EXCEPTION WHEN SQLSTATE 'XX000' THEN
    --  RAISE WARNING 'geometry not updated: %', SQLERRM;
  --  NEW.geometry := data.ST_GeomFromGeoJSON(NEW.geometry);
  converted_geometry = data.ST_SetSRID(data.ST_GeomFromGeoJSON(NEW.geometry), 4326);
  INSERT INTO data.items(id, type, geometry, properties, assets, collection)
  VALUES(new.id, new.type, converted_geometry, new.properties, new.assets, new.collection);
  RETURN NEW;
  END;
  $BODY$
  LANGUAGE plpgsql;

CREATE TRIGGER convert_geometry_tg INSTEAD OF INSERT
   ON data.items_string_geometry FOR EACH ROW
   EXECUTE PROCEDURE data.convert_geometry();

