module("sortExtension", package.seeall)

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
