-- load some variables from the env
\setenv base_dir :DIR
\set base_dir `if [ $base_dir != ":"DIR ]; then echo $base_dir; else echo "/docker-entrypoint-initdb.d"; fi`
\set anonymous `echo $DB_ANON_ROLE`
\set authenticator `echo $DB_USER`
\set authenticator_pass `echo $DB_PASS`
\set jwt_secret `echo $JWT_SECRET`
\set quoted_jwt_secret '\'' :jwt_secret '\''

DROP ROLE IF EXISTS api;
CREATE ROLE api;

--  DROP ROLE IF EXISTS anonymous;
--  CREATE ROLE anonymous;

--  DROP ROLE IF EXISTS application;
--  CREATE ROLE application;

DROP ROLE IF EXISTS webuser;
CREATE ROLE webuser;

drop role if exists :authenticator;
create role :"authenticator" with login password :'authenticator_pass';

drop role if exists :"anonymous";
create role :"anonymous";
grant :"anonymous" to :"authenticator";

drop role if exists application;
create role application;
grant application to :"authenticator";
