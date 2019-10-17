module("defaultFields", package.seeall)
local defaultFields = {}
defaultFields.items = { "id", "collection", "geometry", "properties" ,"type" , "assets", "bbox", "links"}
defaultFields.collections = { "id", "description", "properties", "keywords", "version", "license", "providers", "links" }
return defaultFields
