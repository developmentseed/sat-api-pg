module("filters", package.seeall)
require "extensions.queryExtension"
require "extensions.sortExtension"
require "datetimeBuilder"
local defaultFields = require "defaultFields"

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
