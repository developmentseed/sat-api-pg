module("pg_constants", package.seeall)
local pg_constants = {}
local collectionitems = "c"
pg_constants.datetime = collectionitems .. "." .. "datetime"
pg_constants.id = collectionitems .. "." .. "id"
pg_constants.collection = collectionitems .. "." .. "collection"

return pg_constants
