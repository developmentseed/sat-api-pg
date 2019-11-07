-- Revert sat-api-pg:20191107093406-stacendpoint from pg

BEGIN;
DROP VIEW data.stacLinks;
COMMIT;
