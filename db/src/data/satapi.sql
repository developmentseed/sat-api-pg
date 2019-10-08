CREATE EXTENSION postgis SCHEMA data;
CREATE EXTENSION ltree SCHEMA data;
CREATE TABLE collections(
  id varchar(1024) PRIMARY KEY,
  description varchar(1024),
  properties jsonb
);
CREATE TABLE items(
  id varchar(1024) PRIMARY KEY,
  type varchar(20) NOT NULL,
  geometry geometry NOT NULL,
  bbox numeric[] NOT NULL,
  properties jsonb NOT NULL,
  assets jsonb NOT NULL,
  collection varchar(1024),
  datetime timestamp with time zone NOT NULL,
  CONSTRAINT fk_collection FOREIGN KEY (collection) REFERENCES collections(id)
);

CREATE VIEW items_string_geometry AS
  SELECT
  id,
  type,
  data.ST_AsGeoJSON(geometry) :: json as geometry,
  bbox,
  properties,
  assets,
  collection,
  datetime
  FROM data.items;

CREATE OR REPLACE FUNCTION convert_values()
  RETURNS trigger AS
  $BODY$
  DECLARE
    converted_geometry data.geometry;
    converted_datetime timestamp with time zone;
  BEGIN
    --  IF TG_OP = 'INSERT' AND (NEW.geometry ISNULL) THEN
      --  RAISE EXCEPTION 'geometry is required';
      --  RETURN NULL;
    --  END IF;
  --  EXCEPTION WHEN SQLSTATE 'XX000' THEN
    --  RAISE WARNING 'geometry not updated: %', SQLERRM;
  converted_geometry = data.st_setsrid(data.ST_GeomFromGeoJSON(NEW.geometry), 4326);
  converted_datetime = (new.properties)->'datetime';
  INSERT INTO data.items(id, type, geometry, bbox, properties, assets, collection, datetime)
  VALUES(
    new.id,
    new.type,
    converted_geometry,
    new.bbox,
    new.properties,
    new.assets,
    new.collection,
    converted_datetime);
  RETURN NEW;
  END;
  $BODY$
  LANGUAGE plpgsql;

CREATE TRIGGER convert_geometry_tg INSTEAD OF INSERT
   ON data.items_string_geometry FOR EACH ROW
   EXECUTE PROCEDURE data.convert_values();

