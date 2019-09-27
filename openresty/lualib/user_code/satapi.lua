module("satapi", package.seeall)
require "extensions.fieldsExtension"
require "extensions.queryExtension"
require "extensions.sortExtension"

local defaultFields = { "id", "collection", "geometry", "properties" ,"type" , "assets", "bbox" }

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

function processFilters(uriArgs, andQuery, datetime, sort, next, limit)
  if datetime then
    local dateString = buildDatetime(datetime)
    if andQuery then
      local andDateQuery =
      string.sub(andQuery, 1,-2) .. "," .. dateString .. ")"
      uriArgs["and"] = andDateQuery
    else
      uriArgs["and"] = "(" .. dateString .. ")"
    end
  end
  if next and limit then
    uriArgs["offset"] = next
    uriArgs["limit"] = limit
  end
  -- Sort is described as a filter here rather than a Search extension because
  -- default datetime sorting is required.
  local order = sortExtension.buildSortString(sort)
  uriArgs["order"] = order
  ngx.req.set_uri_args(uriArgs)
end

function processSearch(uriArgs, andQuery, bodyJson)
  local query = bodyJson.query
  if query then
    andQuery = queryExtension.buildQueryString(query)
    uriArgs["and"] = andQuery
  end

  local fields = bodyJson.fields
  if fields then
    local selectFields, includeTable = fieldsExtension.buildFieldsObject(fields, query)
    uriArgs["select"] = selectFields
    bodyJson["include"] = includeTable
    ngx.req.set_body_data(cjson.encode(bodyJson))
  end
end

function formatBboxQueryParameter(bbox)
  if type(bbox) == 'string' then
    modifiedBbox = bbox:gsub("%[", "{")
    modifiedBbox = modifiedBbox:gsub("%]", "}")
    local args = ngx.req.get_uri_args()
    args["bbox"] = modifiedBbox
    ngx.req.set_uri_args(args)
  end
end

function formatIntersectsQueryParameter(intersects)
	if type(intersects) == 'string' then
    local body = {}
    local intersectsTable = cjson.decode(intersects)
    body["intersects"] = intersectsTable
    ngx.req.set_body_data(cjson.encode(body))
    ngx.req.set_method(ngx.HTTP_POST)
	end
end

function setUri(bbox, intersects, uri)
  -- Must use the search function for spatial search.
  if bbox or intersects then
    ngx.req.set_uri("/rpc/search")
    formatIntersectsQueryParameter(intersects)
    formatBboxQueryParameter(bbox)
  else
    -- If using the search endpoint there is the potential for collection queries
    -- and filters so the searchnogeom function is required.
    if uri == "/rest/stac/search" then
      ngx.req.set_uri("/rpc/searchnogeom")
    end
    -- If not we can pass all the traffic down to the raw PostgREST items endpoint.
  end
end

function handleRequest()
  -- Change cjson encoding behavior to support empty arrays.
  cjson.encode_empty_table_as_object(false)

  local method = ngx.req.get_method()
  local defaultSelect = table.concat(defaultFields, ",")
  local uriArgs = { select=defaultSelect }
  local andQuery
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  local uri = string.gsub(ngx.var.request_uri, "?.*", "")
  if method == 'POST' then
    if uri == "/rest/stac/search" then
      if not body then
        body = "{}"
      end
      local bodyJson = cjson.decode(body)
      processSearch(uriArgs, andQuery, bodyJson)
      -- Use the filters from the body rather than uri args
      processFilters(
        uriArgs, andQuery, bodyJson.datetime, bodyJson.sort,
        bodyJson.next, bodyJson.limit
      )
      setUri(bodyJson.bbox, bodyJson.intersects, uri)
    end
  elseif method == 'GET' then
    if uri == "/rest/items" then
      local args = ngx.req.get_uri_args()
      processFilters(
        uriArgs, andQuery, args.datetime, args.sort,
        args.next, args.limit
      )
      setUri(args.bbox, args.intersects, uri)
    end
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
