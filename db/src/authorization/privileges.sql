\echo # Loading roles privilege

-- this file contains the privileges of all aplications roles to each database entity
-- if it gets too long, you can split it one file per entity

-- set default privileges to all the entities created by the auth lib
select auth.set_auth_endpoints_privileges('api', :'anonymous', enum_range(null::data.user_role)::text[]);

-- specify which application roles can access this api (you'll probably list them all)
-- remember to list all the values of user_role type here
grant usage on schema api to anonymous, webuser;
grant usage on schema data to anonymous, webuser;

grant select, insert, update, delete on api.collectionitems to anonymous;

grant select on data.collections to api;
grant select on data.items to api;

-- anonymous users can only request specific columns from this view
