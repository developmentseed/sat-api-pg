module("search", package.seeall)
require "extensions.fieldsExtension"
require "extensions.queryExtension"
require "extensions.sortExtension"
require "datetimeBuilder"
-- local filters = require "filters"
local defaultFields = require "defaultFields"
local limit_constants = require "limit_constants"

function processSearchQuery(query, datetime)
  local updatedAndQuery
  if query then
    updatedAndQuery = queryExtension.buildQueryString(query)
    if datetime then
      local dateString = datetimeBuilder.buildDatetimeSQL(datetime)
      updatedAndQuery = updatedAndQuery  .. " AND " .. dateString
      updatedAndQuery = dateString
    end
  else
    if datetime then
      updatedAndQuery = datetimeBuilder.buildDatetimeSQL(datetime)
    end
  end
  if updatedAndQuery then
    updatedAndQuery = " AND " .. updatedAndQuery
  end
  print(updatedAndQuery)
  return updatedAndQuery
end

-- function createSearchArgs(andQuery, sort, next, limit, fields)
  -- local defaultSelect = table.concat(defaultFields.items, ",")
  -- local searchArgs = {}
  -- searchArgs["select"] = defaultSelect
  -- if fields then
    -- local selectFields, includeTable = fieldsExtension.buildFieldsObject(fields, query)
    -- searchArgs["select"] = selectFields
  -- end
  -- if next and limit then
    -- searchArgs["offset"] = next
    -- searchArgs["limit"] = limit
  -- else
    -- searchArgs["offset"] = limit_constants.offset
    -- searchArgs["limit"] = limit_constants.limit
  -- end
  -- local order = sortExtension.buildSortString(sort)
  -- searchArgs["order"] = order
  -- return searchArgs
-- end

function createSearchBody(fields, bbox, intersects, andQuery)
  local body = {}
  local searchArgs = {}
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
    body["bbox"] = bbox
  end
  if intersects then
    body["intersects"] = intersects
  end
  if andQuery then
    body["andquery"] = andQuery
  end
  return body
end

function buildSearch(json) local andQuery = processSearchQuery(json.query, json.datetime)
  -- andQuery = filters.processListFilter(andQuery, json.ids, "id")
  -- andQuery = filters.processListFilter(andQuery, json.collections, "collection")
  -- local searchArgs = createSearchArgs(andQuery, json.sort, json.next, json.limit, json.fields)
  local searchBody = createSearchBody(json.fields, json.bbox, json.intersects, andQuery)
  -- return searchArgs, searchBody
  return searchBody
end
