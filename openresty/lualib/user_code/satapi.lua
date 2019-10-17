module("satapi", package.seeall)
require "extensions.fieldsExtension"
require "extensions.queryExtension"
require "extensions.sortExtension"
local ngx_re = require "ngx.re"
local path_constants = require "path_constants"
local searchPath = path_constants.searchPath
local itemsPath = path_constants.itemsPath
local collectionsPath = path_constants.collectionsPath
local defaultFields = { "id", "collection", "geometry", "properties" ,"type" , "assets", "bbox", "links"}
local defaultCollectionFields = { "id", "description", "properties" }

function buildDatetime(datetime)
  local dateString
  local startdate, enddate = string.match(datetime, "(.*)/(.*)")
  if startdate and enddate then
    dateString = "datetime.gt." .. startdate .. "," .. "datetime.lt." .. enddate
  else
    dateString = "datetime.eq." .. datetime
  end
  return dateString
end

function processDatetimeFilter(andQuery, datetime)
  local updatedAndQuery
  if datetime then
    local dateString = buildDatetime(datetime)
    if andQuery then
      updatedAndQuery = string.sub(andQuery, 1,-2) .. "," .. dateString .. ")"
    else
      updatedAndQuery = "(" .. dateString .. ")"
    end
  else
    updatedAndQuery = andQuery
  end
  return updatedAndQuery
end

function processIdsFilter(andQuery, ids)
  local updatedAndQuery
  if ids then
    local idsTable
    if type(ids) == "table" then
      idsTable = ids
    else
      idsTable = cjson.decode(ids)
    end

    local idsList = table.concat(idsTable, ",")
    local idsQuery = "id.in.(" .. idsList .. ")"
    if andQuery then
      updatedAndQuery = string.sub(andQuery, 1,-2) .. "," .. idsQuery.. ")"
    else
      updatedAndQuery = "(" .. idsQuery .. ")"
    end
  else
    updatedAndQuery = andQuery
  end
  print (updatedAndQuery)
  return updatedAndQuery
end

function createFilterArgs(andQuery, sort, next, limit)
  local defaultSelect = table.concat(defaultFields, ",")
  local filterArgs = {}
  filterArgs["select"] = defaultSelect
  if andQuery then
    filterArgs["and"] = andQuery
  end
  if next and limit then
    filterArgs["offset"] = next
    filterArgs["limit"] = limit
  end
  -- If sort is null returns default sorting order
  local order = sortExtension.buildSortString(sort)
  filterArgs["order"] = order
  return filterArgs
end

function createFilterBody(bbox, intersects)
  local body = {}
  if type(bbox) == 'string' then
    modifiedBbox = bbox:gsub("%[", "{")
    modifiedBbox = modifiedBbox:gsub("%]", "}")
    body["bbox"] = modifiedBbox
  end
  if type(intersects) == 'string' then
    local intersectsTable = cjson.decode(intersects)
    body["intersects"] = intersectsTable
  end
  return body
end

function processSearchQuery(query, datetime)
  local updatedAndQuery
  if query then
    updatedAndQuery = queryExtension.buildQueryString(query)
    if datetime then
      local dateString = buildDatetime(datetime)
      updatedAndQuery = string.sub(updatedAndQuery, 1,-2) .. "," .. dateString .. ")"
    end
  else
    if datetime then
      local dateString = buildDatetime(datetime)
      updatedAndQuery = "(" .. dateString .. ")"
    end
  end
  return updatedAndQuery
end

function createSearchArgs(andQuery, sort, next, limit, fields)
  local defaultSelect = table.concat(defaultFields, ",")
  local searchArgs = {}
  searchArgs["select"] = defaultSelect
  if andQuery then
    searchArgs["and"] = andQuery
  end
  if fields then
    local selectFields, includeTable = fieldsExtension.buildFieldsObject(fields, query)
    searchArgs["select"] = selectFields
  end
  if next and limit then
    searchArgs["offset"] = next
    searchArgs["limit"] = limit
  end
  local order = sortExtension.buildSortString(sort)
  searchArgs["order"] = order
  return searchArgs
end

function createSearchBody(fields, bbox, intersects)
  local body = {}
  if fields then
    local selectFields, includeTable = fieldsExtension.buildFieldsObject(fields, query)
    body["include"] = includeTable
  end
  if bbox then
    body["bbox"] = bbox
  end
  if intersects then
    body["intersects"] = intersects
  end
  return body
end

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
      local andQuery = processSearchQuery(bodyJson.query, bodyJson.datetime)
      andQuery = processIdsFilter(andQuery, bodyJson.ids)
      local searchArgs = createSearchArgs(
                          andQuery,
                          bodyJson.sort,
                          bodyJson.next,
                          bodyJson.limit,
                          bodyJson.fields)
      local searchBody = createSearchBody(
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
        local andQuery = processDatetimeFilter(nil, args.datetime)
        andQuery = processIdsFilter(andQuery, args.ids)
        local filterArgs = createFilterArgs(
                            andQuery,
                            args.sort,
                            args.next,
                            args.limit)
        local filterBody = createFilterBody(args.bbox, args.intersects)
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
      local andQuery = processDatetimeFilter(andQuery, args.datetime)
      andQuery = processIdsFilter(andQuery, args.ids)
      local filterArgs = createFilterArgs(
                            andQuery,
                            args.sort,
                            args.next,
                            args.limit)
        local filterBody = createFilterBody(args.bbox, args.intersects)
        ngx.req.set_body_data(cjson.encode(filterBody))
        ngx.req.set_uri_args(filterArgs)
        setUri(args.bbox, args.intersects, uri)
    else
      idQuery = "eq." .. collectionId
      local defaultCollectionSelect = table.concat(defaultCollectionFields, ",")
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
