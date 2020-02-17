module("sortExtension", package.seeall)
require "string_utils"
local pg_constants = require "pg_constants"
wrapSingleQuote = string_utils.wrapSingleQuote

function setPropertiesPrefix(field)
  local prefix, key = string.match(field, "(.*)%.(.*)")
  local pgField = ""
  if key then
    pgField = "properties->" .. "'" .. key .. "'"
  else
    pgField = field
  end
  return pgField
end

function buildSortString(sort)
  -- Defaut sort by datetime
  order = 'datetime.desc'
  return order
end

function buildSortSQL(sort)
  local order = ""
  if sort then
    local orderTable = {}
    -- This rule.direction is a temporary fix until tokenized paging is
    -- implemented
    direction = "asc"
    for _, rule in ipairs(sort) do
      local pgField
      if rule.field == "properties.datetime" then
        pgField = pg_constants.datetime
      elseif rule.field == "properties.eo:cloud_cover" then
        pgField = "(" .. setPropertiesPrefix(rule.field) .. ")" .. "::numeric"
      else
        pgField = setPropertiesPrefix(rule.field)
      end
      local orderValue = pgField .. " " .. rule.direction
      direction = rule.direction
      table.insert(orderTable, orderValue)
    end
    order = table.concat(orderTable, ",")
    order = order .. "," .. pg_constants.tiebreak .. " " .. direction
  else
    -- Defaut sort by datetime
    order = pg_constants.datetime .. " " .. "desc" ..  "," ..
      pg_constants.tiebreak .. " " .. "desc" 
  end
  -- if string.sub(order, -1) == "," then
    -- -- order = string.sub(order, 1, string.len(order) - 1) 
    -- print ("test")
    -- order = "wat"
    -- -- order = order .. "," .. pg_constants.id .. " " .. "desc"
  -- end
  local orderby = "ORDER BY " .. order
  return orderby
end
