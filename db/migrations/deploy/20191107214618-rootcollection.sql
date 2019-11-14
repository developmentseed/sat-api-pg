-- Deploy sat-api-pg:20191108211002-rootcollection to pg

BEGIN;
CREATE OR REPLACE VIEW data.collectionsobject AS
  SELECT
  (SELECT ARRAY(
      SELECT
      ROW((SELECT url || '/collections/' || data.collectionsLinks.id FROM data.apiUrls LIMIT 1),
      'child',
      'application/json',
      null)::data.linkobject
      FROM data.collectionsLinks)
  ) as links,
  (SELECT ARRAY(
    SELECT row_to_json(collection) 
    FROM (SELECT * FROM data.collectionsLinks) collection
  )) as collections;

CREATE OR REPLACE VIEW api.rootcollections AS
  SELECT * FROM data.collectionsobject;
ALTER VIEW api.rootcollections owner to api;

GRANT SELECT on data.collectionsobject to api;
GRANT SELECT on api.rootcollections to anonymous;
COMMIT;
