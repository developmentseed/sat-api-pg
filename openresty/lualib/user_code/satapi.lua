module("satapi", package.seeall)
local defaultFields = require "defaultFields"
local filters = require "filters"
local search = require "search"
local ngx_re = require "ngx.re"
local path_constants = require "path_constants"
local searchPath = path_constants.searchPath
local itemsPath = path_constants.itemsPath
local collectionsPath = path_constants.collectionsPath

function setUri(bbox, intersects, uri)
  -- Must use the search function for spatial search.
  if bbox or intersects then
    ngx.req.set_uri("/rpc/search")
    ngx.req.set_method(ngx.HTTP_POST)
  else
    -- If using the search endpoint there is the potential for collection queries
    -- and filters so the searchnogeom function is required.
    if uri == searchPath then
      ngx.req.set_uri("/rpc/searchnogeom")
      ngx.req.set_method(ngx.HTTP_POST)
    else
      ngx.req.set_uri("/items")
    end
    -- If not we can pass all the traffic down to the raw PostgREST items endpoint.
  end
end

function handleRequest()
  -- Change cjson encoding behavior to support empty arrays.
  cjson.encode_empty_table_as_object(false)
  local method = ngx.req.get_method()
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  local uri = string.gsub(ngx.var.request_uri, "?.*", "")

  if method == 'POST' then
    if uri == searchPath then
      if not body then
        body = "{}"
      end
      local bodyJson = cjson.decode(body)
      local andQuery = search.processSearchQuery(bodyJson.query, bodyJson.datetime)
      andQuery = filters.processIdsFilter(andQuery, bodyJson.ids)
      local searchArgs = search.createSearchArgs(
                          andQuery,
                          bodyJson.sort,
                          bodyJson.next,
                          bodyJson.limit,
                          bodyJson.fields)
      local searchBody = search.createSearchBody(
                          bodyJson.fields,
                          bodyJson.bbox,
                          bodyJson.intersects)
      ngx.req.set_body_data(cjson.encode(searchBody))
      ngx.req.set_uri_args(searchArgs)
      setUri(bodyJson.bbox, bodyJson.intersects, uri)
    end
  elseif method == 'GET' then
    local collections = string.find(uri, collectionsPath)
    local args = ngx.req.get_uri_args()
    if collections then
      handleWFS(args, uri)
    else
      if uri == itemsPath then
        local andQuery = filters.processDatetimeFilter(nil, args.datetime)
        andQuery = filters.processIdsFilter(andQuery, args.ids)
        local filterArgs = filters.createFilterArgs(
                            andQuery,
                            args.sort,
                            args.next,
                            args.limit)
        local filterBody = filters.createFilterBody(args.bbox, args.intersects)
        ngx.req.set_body_data(cjson.encode(filterBody))
        ngx.req.set_uri_args(filterArgs)
        setUri(args.bbox, args.intersects, uri)
      end
    end
  end
end

function handleWFS(args, uri)
  local uriComponents = ngx_re.split(uri, '/')
  local collections = uriComponents[3]
  local collectionId = uriComponents[4]
  local items = uriComponents[5]
  local itemId = uriComponents[6]

  if collectionId then
    if items and items ~= '' then
      local andQuery
      andQuery = "(collection.eq." .. collectionId .. ")"
      if itemId and itemId ~= '' then
        -- Return object rather than array
        ngx.req.set_header("Accept", "application/vnd.pgrst.object+json")
        andQuery = "(id.eq." .. itemId .. ")"
      end
      local andQuery = filters.processDatetimeFilter(andQuery, args.datetime)
      andQuery = filters.processIdsFilter(andQuery, args.ids)
      local filterArgs = filters.createFilterArgs(
                            andQuery,
                            args.sort,
                            args.next,
                            args.limit)
        local filterBody = filters.createFilterBody(args.bbox, args.intersects)
        ngx.req.set_body_data(cjson.encode(filterBody))
        ngx.req.set_uri_args(filterArgs)
        setUri(args.bbox, args.intersects, uri)
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
      ngx.req.set_uri("collections")
    end
  else
    -- Handle trailing slashes
    ngx.req.set_uri("collections")
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
