module("path_constants", package.seeall)
local path_constants = {}
path_constants.apiPath = "/"
path_constants.searchPath = "/stac/search"
path_constants.itemsPath = "/items"
path_constants.collectionsPath = "/collections"
path_constants.conformancePath = "/conformance"
path_constants.stacPath = "/stac"
path_constants.pg_searchPath = "/rpc/search"
path_constants.pg_searchNoGeomPath "/rpc/searchnogeom"
path_constants.pg_root = "root"
path_constants.pg_stac = "stac"
path_constants.pg_rootcollections = "rootcollections"
return path_constants
