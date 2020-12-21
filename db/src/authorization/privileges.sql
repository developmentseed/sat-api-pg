\echo # Loading roles privilege

-- this file contains the privileges of all aplications roles to each database entity
-- if it gets too long, you can split it one file per entity

-- set default privileges to all the entities created by the auth lib
select auth.set_auth_endpoints_privileges('api', :'anonymous', enum_range(null::data.user_role)::text[]);

-- specify which application roles can access this api (you'll probably list them all)
-- remember to list all the values of user_role type here
grant usage on schema api to anonymous, application;
grant usage on schema data to anonymous, application;

grant select on data.items to api;
grant select, insert, update, delete on data.items_string_geometry to api;
grant select, insert, update on data.collections to api;
grant select, insert, update on data.collectionsLinks to api;
grant select, insert, update on data.itemsLinks to api;
grant select on data.rootLinks to api;
grant select on data.stacLinks to api;
grant select on data.collectionsobject to api;

-- Anonymous can view collection items
grant select on api.collectionitems to anonymous;
grant select on api.items to anonymous;
grant select on data.items to anonymous;
grant select on api.collections to anonymous;
grant select on api.root to anonymous;
grant select on api.stac to anonymous;
grant select on api.rootcollections to anonymous;

-- Application can insert items with transformed geojson
grant select, insert, update on data.collections to application;
grant select, insert, update on data.collectionsLinks to application;
grant select, insert, update on api.collections to application;
grant select, insert, update on data.itemsLinks to application;
grant select, insert, update on data.items to application;
grant select, insert, update, delete on api.items to application;
grant select, insert, update on data.items_string_geometry to application;
GRANT usage ON sequence data.items_tiebreak_seq TO application;
