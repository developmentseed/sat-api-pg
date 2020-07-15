-- Deploy sat-api-pg:20200715144826-multilinks to pg

BEGIN;

CREATE OR REPLACE FUNCTION convert_values()
  RETURNS trigger AS
  $BODY$
  DECLARE
    converted_geometry data.geometry;
    converted_datetime timestamp with time zone;
    newlinks data.linkobject[];
    filteredlinks data.linkobject[];
    link data.linkobject;
  BEGIN
    --  IF TG_OP = 'INSERT' AND (NEW.geometry ISNULL) THEN
      --  RAISE EXCEPTION 'geometry is required';
      --  RETURN NULL;
    --  END IF;
  --  EXCEPTION WHEN SQLSTATE 'XX000' THEN
    --  RAISE WARNING 'geometry not updated: %', SQLERRM;
  converted_geometry = data.st_setsrid(data.ST_GeomFromGeoJSON(NEW.geometry), 4326);
  converted_datetime = (new.properties)->'datetime';

  newlinks := new.links;
  IF newlinks IS NOT NULL THEN
    FOREACH link IN ARRAY newlinks LOOP
      IF link.rel='derived_from' AND link.href IS NOT NULL THEN
        filteredlinks := ARRAY_APPEND(filteredlinks, link);
      ELSE
        filteredlinks := NULL;
      END IF;
    END LOOP;
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
    newlinks data.linkobject[];
    filteredlinks data.linkobject[];
    link data.linkobject;
  BEGIN
 
  newlinks := new.links;
  IF newlinks IS NOT NULL THEN
    FOREACH link IN ARRAY newlinks LOOP
      IF link.rel='derived_from' AND link.href IS NOT NULL THEN
        filteredlinks := ARRAY_APPEND(filteredlinks, link);
      ELSE
        filteredlinks := NULL;
      END IF;
    END LOOP;
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

COMMIT;
