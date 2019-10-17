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

function processListFilter(andQuery, list, key)
  local updatedAndQuery
  if list then
    local listTable
    if type(list) == "table" then
      listTable = list
    else
      listTable = cjson.decode(list)
    end

    local listString = table.concat(listTable, ",")
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

function buildFilters(existingAndQuery, args)
    -- andQuery,
    -- datetime,
    -- ids,
    -- collections,
    -- sort,
    -- next,
    -- limit,
    -- bbox,
    -- intersects)
  local andQuery = processDatetimeFilter(existingAndQuery, args.datetime)
  andQuery = filters.processListFilter(andQuery, args.ids, "id")
  andQuery = filters.processListFilter(andQuery, args.collections, "collection")
  local filterArgs = filters.createFilterArgs(andQuery, args.sort, args.next, args.limit)
  local filterBody = filters.createFilterBody(args.bbox, args.intersects)
  return filterArgs, filterBody
end
