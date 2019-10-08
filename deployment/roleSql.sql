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
GRANT api to current_user; -- this is a workaround for RDS where the master user does not have SUPERUSER priviliges  

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
