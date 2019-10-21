CREATE EXTENSION postgis SCHEMA data;
CREATE EXTENSION ltree SCHEMA data;
CREATE TYPE linkobject AS(
  href varchar(1024),
  rel varchar(1024),
  type varchar(1024),
  title varchar(1024)
);
CREATE TABLE apiUrls(
  url varchar(1024)
);
CREATE TABLE collections(
  id varchar(1024) PRIMARY KEY,
  title varchar(1024),
  description varchar(1024) NOT NULL,
  keywords varchar(300)[],
  version varchar(300),
  license varchar(300) NOT NULL,
  providers jsonb[],
  extent jsonb,
  properties jsonb,
  links linkobject[]
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
  links linkobject[],
  CONSTRAINT fk_collection FOREIGN KEY (collection) REFERENCES collections(id)
);
CREATE VIEW collectionsLinks AS
  SELECT
  id,
  title,
  description,
  keywords,
  version,
  license,
  providers,
  extent,
  properties,
  (SELECT array_cat(ARRAY[
    ROW((SELECT url || '/collections/' || id FROM data.apiUrls LIMIT 1),
        'self',
        'application/json',
        null)::data.linkobject,
    ROW((SELECT url || '/collections/' || id FROM data.apiUrls LIMIT 1),
      'root',
      'application/json' ,
      null)::data.linkobject
  ], links)) as links
  FROM data.collections;

CREATE VIEW rootLinks AS
  SELECT
  'sat-api-pg' AS title,
  'sat-api-pg' AS id,
  'STAC v0.8.0 implementation by Development Seed' AS description,
  '0.8.0' AS stac_version,
  (SELECT ARRAY[
    ROW((SELECT url || '/collections' FROM data.apiUrls LIMIT 1),
        'data',
        'application/json',
        null)::data.linkobject,
    ROW((SELECT url || '/conformance' FROM data.apiUrls LIMIT 1),
        'conformance',
        'application/json',
        null)::data.linkobject,
    ROW((SELECT url FROM data.apiUrls LIMIT 1),
      'self',
      'application/json' ,
      null)::data.linkobject
  ]) as links;

CREATE VIEW itemsLinks AS
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
  ], links)) as links
  FROM data.items i;

CREATE VIEW items_string_geometry AS
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

CREATE OR REPLACE FUNCTION convert_values()
  RETURNS trigger AS
  $BODY$
  DECLARE
    converted_geometry data.geometry;
    converted_datetime timestamp with time zone;
    newlinks data.linkobject;
    filteredlinks data.linkobject[];
  BEGIN
    --  IF TG_OP = 'INSERT' AND (NEW.geometry ISNULL) THEN
      --  RAISE EXCEPTION 'geometry is required';
      --  RETURN NULL;
    --  END IF;
  --  EXCEPTION WHEN SQLSTATE 'XX000' THEN
    --  RAISE WARNING 'geometry not updated: %', SQLERRM;
  converted_geometry = data.st_setsrid(data.ST_GeomFromGeoJSON(NEW.geometry), 4326);
  converted_datetime = (new.properties)->'datetime';
  SELECT * INTO newlinks FROM unnest(new.links) as linkObj
  WHERE linkObj.rel = 'derived_from';
  IF newlinks.href IS NOT NULL THEN
    filteredlinks = ARRAY[newlinks];
  ELSE
    filteredlinks = NULL;
  END IF;
  INSERT INTO data.items(
    id,
    type,
    geometry,
    bbox,
    properties,
    assets,
    collection,
    datetime,
    links)
  VALUES(
    new.id,
    new.type,
    converted_geometry,
    new.bbox,
    new.properties,
    new.assets,
    new.collection,
    converted_datetime,
    filteredlinks);
  RETURN NEW;
  END;
  $BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION convert_collection_links()
  RETURNS trigger AS
  $BODY$
  DECLARE
    newlinks data.linkobject;
    filteredlinks data.linkobject[];
  BEGIN
  SELECT * INTO newlinks FROM unnest(new.links) as linkObj
  WHERE linkObj.rel = 'derived_from';
  IF newlinks.href IS NOT NULL THEN
    filteredlinks = ARRAY[newlinks];
  ELSE
    filteredlinks = NULL;
  END IF;
  INSERT INTO data.collections(
    id,
    title,
    description,
    keywords,
    version,
    license,
    providers,
    extent,
    properties,
    links
  )
  VALUES(
    new.id,
    new.title,
    new.description,
    new.keywords,
    new.version,
    new.license,
    new.providers,
    new.extent,
    new.properties,
    filteredlinks
  );
  RETURN NEW;
  END;
  $BODY$
  LANGUAGE plpgsql;

CREATE TRIGGER convert_collection_links INSTEAD OF INSERT
  ON data.collectionsLinks FOR EACH ROW
  EXECUTE PROCEDURE data.convert_collection_links();

CREATE TRIGGER convert_geometry_tg INSTEAD OF INSERT
   ON data.items_string_geometry FOR EACH ROW
   EXECUTE PROCEDURE data.convert_values();

