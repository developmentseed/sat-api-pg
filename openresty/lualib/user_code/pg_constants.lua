module("pg_constants", package.seeall)
local pg_constants = {}
local collectionitems = "c"
pg_constants.datetime = collectionitems .. "." .. "datetime"
return pg_constants
