module("search", package.seeall)
require "extensions.fieldsExtension"
require "extensions.queryExtension"
require "extensions.sortExtension"
require "datetimeBuilder"
require "wfsBuilder"
local defaultFields = require "defaultFields"
local limit_constants = require "limit_constants"
wrapSingleQuote = string_utils.wrapSingleQuote

function processSearchQuery(query, datetime, collectionId, ids)
  local andComponents = {}
  if query then 
    andComponents[#andComponents + 1] = queryExtension.buildQueryString(query)
  end
  if datetime then
    andComponents[#andComponents + 1] = datetimeBuilder.buildDatetimeSQL(datetime)
  end
  if collectionId then
    andComponents[#andComponents + 1] = wfsBuilder.buildQuery(collectionId, "collection")
  end
  if ids then
    andComponents[#andComponents + 1] = wfsBuilder.buildInQuery(ids, "id")
  end
  local andQuery
  if #andComponents ~= 0 then
    andQuery = table.concat(andComponents, " AND ")
  end
  if andQuery then
    andQuery = " AND " .. andQuery
  end
  print(andQuery)
  return andQuery
end

function createSearch(fields, bbox, intersects, next, limit, andQuery, sort)
  local body = {}
  local searchArgs = {}
  local defaultSelect = table.concat(defaultFields.items, ",")
  if next and limit then
    body["next"] = next
    body["lim"] = limit
  else
    body["next"] = limit_constants.offset
    body["lim"] = limit_constants.limit
  end
  if fields then
    local selectFields, includeTable = fieldsExtension.buildFieldsObject(fields, query)
    body["include"] = includeTable
    searchArgs["select"] = selectFields
  else
    searchArgs["select"] = defaultSelect
  end
  if bbox then
    if type(bbox) == 'string' then
      modifiedBbox = "{" .. bbox .. "}"
      body["bbox"] = modifiedBbox
    else
      body["bbox"] = bbox
    end
  end
  if intersects then
    if type(intersects) == 'string' then
      print(intersects)
      local intersectsTable = cjson.decode(intersects)
      body["intersects"] = intersectsTable
    else
      body["intersects"] = intersects
    end
  end
  if andQuery then
    body["andquery"] = andQuery
  end
  body["sort"] = sort
  return body, searchArgs
end

function buildSearch(json, collectionId, ids)
  local andQuery = processSearchQuery(json.query, json.datetime, collectionId, ids)
  local sort = sortExtension.buildSortSQL(json.sort)
  local searchBody, searchArgs = createSearch(json.fields, json.bbox, json.intersects, json.next, json.limit, andQuery, sort)
  return searchBody, searchArgs
end
