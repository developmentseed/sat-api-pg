-- Deploy sat-api-pg:20191107093406-stacendpoint to pg

BEGIN;
SET search_path = data, api;
CREATE VIEW data.stacLinks AS
  SELECT
  'sat-api-pg' AS title,
  'sat-api-pg' AS id,
  'STAC v0.8.0 implementation by Development Seed' AS description,
  '0.8.0' AS stac_version,
  (SELECT array_cat(ARRAY(
      SELECT
      ROW((SELECT url || '/collections/' || data.collectionsLinks.id FROM data.apiUrls LIMIT 1),
      'child',
      'application/json',
      null)::data.linkobject
      FROM data.collectionsLinks),
      ARRAY[
        ROW((SELECT url || '/stac/search' FROM data.apiUrls LIMIT 1),
          'search',
          'application/json',
        null)::data.linkobject,
        ROW((SELECT url || '/stac' FROM data.apiUrls LIMIT 1),
          'self',
          'application/json',
        null)::data.linkobject]
    )
  ) as links;

GRANT SELECT on data.stacLinks to api;

CREATE OR REPLACE VIEW api.stac AS
  SELECT * FROM data.stacLinks;
ALTER VIEW stac owner to api;

GRANT SELECT on api.stac to anonymous;
COMMIT;
