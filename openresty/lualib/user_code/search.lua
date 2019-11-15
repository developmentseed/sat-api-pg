module("search", package.seeall)
require "extensions.fieldsExtension"
require "extensions.queryExtension"
require "extensions.sortExtension"
require "datetimeBuilder"
local defaultFields = require "defaultFields"
local limit_constants = require "limit_constants"

function processSearchQuery(query, datetime)
  local updatedAndQuery
  if query then
    updatedAndQuery = queryExtension.buildQueryString(query)
    if datetime then
      local dateString = datetimeBuilder.buildDatetimeSQL(datetime)
      updatedAndQuery = updatedAndQuery  .. " AND " .. dateString
    end
  else
    if datetime then
      updatedAndQuery = datetimeBuilder.buildDatetimeSQL(datetime)
    end
  end
  if updatedAndQuery then
    updatedAndQuery = " AND " .. updatedAndQuery
  end
  return updatedAndQuery
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

function buildSearch(json)
  local andQuery = processSearchQuery(json.query, json.datetime)
  local sort = sortExtension.buildSortSQL(json.sort)
  local searchBody, searchArgs = createSearch(json.fields, json.bbox, json.intersects, json.next, json.limit, andQuery, sort)
  return searchBody, searchArgs
end
