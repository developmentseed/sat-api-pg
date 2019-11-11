module("sortExtension", package.seeall)
require "string_utils"
local pg_constants = require "pg_constants"
wrapSingleQuote = string_utils.wrapSingleQuote

function buildSortString(sort)
  local order = ""
  if sort then
    local orderTable = {}
    for _, rule in ipairs(sort) do
      local pgField = "properties->" .. "\"" .. rule.field .. "\""
      -- local prefix, key = string.match(rule.field, "(.*)%.(.*)")
      -- if key then
        -- pgField = "properties->" .. "\"" .. key .. "\""
      -- else
        -- pgField = key
      -- end
      local orderValue = pgField .. "." .. rule.direction
      table.insert(orderTable, orderValue)
    end
    order = table.concat(orderTable, ",")
  else
    -- Defaut sort by datetime
    order = 'datetime.desc'
  end
  return order
end

function buildSortSQL(sort)
  local order = ""
  if sort then
    local orderTable = {}
    for _, rule in ipairs(sort) do
      local pgField = "properties->" .. wrapSingleQuote(rule.field)
      local orderValue = pgField .. " " .. rule.direction
      table.insert(orderTable, orderValue)
    end
    order = table.concat(orderTable, ",")
  else
    -- Defaut sort by datetime
    order = pg_constants.datetime .. " " .. "desc"
  end
  if string.sub(order, -1) == "," then
    order = string.sub(order, 1, string.len(order) - 1)
  end
  local orderby = "ORDER BY " .. order 
  return orderby
end
