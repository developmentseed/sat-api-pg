module("search", package.seeall)
require "extensions.fieldsExtension"
require "extensions.queryExtension"
require "extensions.sortExtension"
require "datetimeBuilder"
local filters = require "filters"
local defaultFields = require "defaultFields"
local limit_constants = require "limit_constants"

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
  else
    searchArgs["offset"] = limit_constants.offset
    searchArgs["limit"] = limit_constants.limit
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

function buildSearch(json)
  local andQuery = processSearchQuery(json.query, json.datetime)
  andQuery = filters.processListFilter(andQuery, json.ids, "id")
  andQuery = filters.processListFilter(andQuery, json.collections, "collection")
  local searchArgs = createSearchArgs(andQuery, json.sort, json.next, json.limit, json.fields)
  local searchBody = createSearchBody(json.fields, json.bbox, json.intersects)
  return searchArgs, searchBody
end
