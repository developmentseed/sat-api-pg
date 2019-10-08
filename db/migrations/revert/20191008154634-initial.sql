-- Revert sat-api-pg:20191008154634-initial from pg

BEGIN;
  drop schema pgjwt cascade;
  drop schema api cascade;
  drop schema request cascade;
  drop schema data cascade;
  drop schema auth cascade;
  drop schema settings cascade;
  drop schema sqitch cascade;
COMMIT;
