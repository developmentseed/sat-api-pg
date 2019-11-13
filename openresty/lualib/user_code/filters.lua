module("filters", package.seeall)
require "extensions.sortExtension"
require "datetimeBuilder"
local defaultFields = require "defaultFields"
local limit_constants = require "limit_constants"

function processDatetimeFilter(andQuery, datetime)
  local updatedAndQuery
  if datetime then
    local dateString = datetimeBuilder.buildDatetime(datetime)
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

function processListFilter(andQuery, list, key)
  local updatedAndQuery
  local listString
  if list then
    if type(list) == "table" then
      listString = table.concat(list, ",")
    else
      listString = list
    end

    local listQuery = key .. ".in.(" .. listString .. ")"
    if andQuery then
      updatedAndQuery = string.sub(andQuery, 1,-2) .. "," .. listQuery .. ")"
    else
      updatedAndQuery = "(" .. listQuery .. ")"
    end
  else
    updatedAndQuery = andQuery
  end
  return updatedAndQuery
end

function createFilterArgs(andQuery, sort, next, limit)
  local defaultSelect = table.concat(defaultFields.items, ",")
  local filterArgs = {}
  filterArgs["select"] = defaultSelect
  if andQuery then
    filterArgs["and"] = andQuery
  end
  if next and limit then
    filterArgs["offset"] = next
    filterArgs["limit"] = limit
  else
    filterArgs["offset"] = limit_constants.offset
    filterArgs["limit"] = limit_constants.limit
  end
  -- If sort is null returns default sorting order
  local order = sortExtension.buildSortString(sort)
  filterArgs["order"] = order
  return filterArgs
end

function buildFilters(existingAndQuery, args)
  local andQuery = processDatetimeFilter(existingAndQuery, args.datetime)
  andQuery = filters.processListFilter(andQuery, args.ids, "id")
  andQuery = filters.processListFilter(andQuery, args.collections, "collection")
  local filterArgs = filters.createFilterArgs(andQuery, args.sort, args.next, args.limit)
  return filterArgs
end
