module("search", package.seeall)
require "extensions.fieldsExtension"
require "extensions.queryExtension"
require "extensions.sortExtension"
require "datetimeBuilder"
local filters = require "filters"
local defaultFields = require "defaultFields"

function processSearchQuery(query, datetime)
  local updatedAndQuery
  if query then
    updatedAndQuery = queryExtension.buildQueryString(query)
    if datetime then
      local dateString = datetimeBuilder.buildDatetime(datetime)
      updatedAndQuery = string.sub(updatedAndQuery, 1,-2) .. "," .. dateString .. ")"
    end
  else
    if datetime then
      local dateString = datetimeBuilder.buildDatetime(datetime)
      updatedAndQuery = "(" .. dateString .. ")"
    end
  end
  return updatedAndQuery
end

function createSearchArgs(andQuery, sort, next, limit, fields)
  local defaultSelect = table.concat(defaultFields.items, ",")
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

function buildSearch(
  query,
  datetime,
  ids,
  collections
  sort,
  next,
  limit,
  fields,
  bbox,
  intersects
)
  local andQuery = processSearchQuery(query, datetime)
  andQuery = filters.processListFilter(andQuery, ids, "id")
  andQuery = filters.processListFilter(andQuery, collections, "collection")
  local searchArgs = createSearchArgs(andQuery, sort, next, limit, fields)
  local searchBody = createSearchBody(fields, bbox, intersects)
  return searchArgs, searchBody
end
