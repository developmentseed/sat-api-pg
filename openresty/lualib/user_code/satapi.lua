module("satapi", package.seeall)
local defaultFields = require "defaultFields"
local filters = require "filters"
local search = require "search"
local ngx_re = require "ngx.re"
local path_constants = require "path_constants"
local apiPath = path_constants.apiPath
local searchPath = path_constants.searchPath
local itemsPath = path_constants.itemsPath
local collectionsPath = path_constants.collectionsPath
local conformancePath = path_constants.conformancePath
local stacPath = path_constants.stacPath
local pg_searchPath = path_constants.pg_searchPath
local pg_searchNoGeomPath = path_constants.pg_searchNoGeomPath
local pg_root = path_constants.pg_root
local pg_rootcollections = path_constants.pg_rootcollections

function setUri(bodyJson, args, andQuery)
  -- The search function is needed for these operations
  if bodyJson and (bodyJson.bbox or bodyJson.intersects or bodyJson.fields or bodyJson.query) then
    local searchBody, searchArgs = search.buildSearch(bodyJson)
    ngx.req.set_body_data(cjson.encode(searchBody))
    ngx.req.set_uri_args(searchArgs)
    ngx.req.set_uri(pg_searchPath)
    ngx.req.set_method(ngx.HTTP_POST)
  -- The search function is needed for spatial operations
  elseif args and (args.bbox or args.intersects) then
    local searchBody, searchArgs = search.buildSearch(args)
    ngx.req.set_body_data(cjson.encode(searchBody))
    ngx.req.set_uri_args(searchArgs)
    ngx.req.set_uri(pg_searchPath)
    ngx.req.set_method(ngx.HTTP_POST)
  -- If not we can pass all the traffic down to the raw PostgREST items endpoint.
  else
    -- Use the POST body as the args table
    if args == nil and bodyJson then
      args = bodyJson
    end
    local filterArgs = filters.buildFilters(andQuery, args)
    ngx.req.set_body_data(cjson.encode(filterBody))
    ngx.req.set_uri_args(filterArgs)
    ngx.req.set_uri(itemsPath)
    ngx.req.set_method(ngx.HTTP_GET)
  end
end

function handleRequest()
  -- Change cjson encoding behavior to support empty arrays.
  cjson.encode_empty_table_as_object(false)
  local method = ngx.req.get_method()
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  local uri = string.gsub(ngx.var.request_uri, "?.*", "")
  -- Trim trailing slash
  if string.len(uri) > 1 and string.sub(uri, -1) == "/" then
    uri = string.sub(uri, 1, string.len(uri) - 1)
  end
  if method == 'POST' then
    ngx.req.set_header("Accept", "application/json")
    if uri == searchPath then
      if not body then
        body = "{}"
      end
      local bodyJson = cjson.decode(body)
      setUri(bodyJson)
    end
  elseif method == 'GET' then
    local collections = string.find(uri, collectionsPath)
    local args = ngx.req.get_uri_args()
    if collections then
      handleWFS(args, uri)
    else
      if uri == apiPath then
        ngx.req.set_header("Accept", "application/vnd.pgrst.object+json")
        ngx.req.set_uri(pg_root)
      elseif uri == itemsPath then
        ngx.req.set_header("Accept", "application/json")
        setUri(nil, args)
      -- This uses the root path for conformance to have a valid response
      elseif uri == conformancePath then
        ngx.req.set_uri(pg_root)
      elseif uri == stacPath then
        ngx.req.set_header("Accept", "application/vnd.pgrst.object+json")
        ngx.req.set_uri(stacPath)
      end
    end
  end
end

function handleWFS(args, uri)
  local uriComponents = ngx_re.split(uri, '/')
  local collections = uriComponents[2]
  local collectionId = uriComponents[3]
  local items = uriComponents[4]
  local itemId = uriComponents[5]

  if collectionId then
    if items and items ~= '' then
      local andQuery
      andQuery = "(collection.eq." .. collectionId .. ")"
      if itemId and itemId ~= '' then
        -- Return object rather than array
        ngx.req.set_header("Accept", "application/vnd.pgrst.object+json")
        andQuery = "(id.eq." .. itemId .. ")"
      else
        ngx.req.set_header("Accept", "application/json")
      end
      setUri(nil, args, andQuery)
    else
      idQuery = "eq." .. collectionId
      local defaultCollectionSelect = table.concat(defaultFields.collections, ",")
      local uriArgs = {}
      uriArgs["id"] = idQuery
      uriArgs["select"] = defaultCollectionSelect
      local headers = ngx.req.get_headers()
      -- Return object rather than array
      ngx.req.set_header("Accept", "application/vnd.pgrst.object+json")
      ngx.req.set_uri_args(uriArgs)
      ngx.req.set_uri(collectionsPath)
    end
  else
    -- Handle trailing slashes
    ngx.req.set_header("Accept", "application/vnd.pgrst.object+json")
    ngx.req.set_uri(pg_rootcollections)
  end
end

function wrapFeatureCollection(body)
  local features = cjson.decode(body)
  local itemCollection = {
    type="FeatureCollection",
    features=features
  }
  return cjson.encode(itemCollection)
end

function returnConformance()
  local conformanceTable = { conformsTo={
    "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core",
    "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/html",
    "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson"
  }}
  return cjson.encode(conformanceTable)
end

