-- Revert sat-api-pg:20191108211002-rootcollection from pg

BEGIN;
DROP VIEW collectionsobject;
DROP VIEW rootcollections;
COMMIT;
