module("queryExtension", package.seeall)
local stacOperators = {}
stacOperators["eq"] = "="
stacOperators["gt"] = ">"
stacOperators["lt"] = "<"
stacOperators["gte"] = ">="
stacOperators["lte"] = "<="
stacOperators["neq"] = "!="
stacOperators["in"] = "in"

function buildQueryString(query)
  local logicalAndTable = {}
  local propertiesAccessor = "properties->>"
  local collectionPropertiesAccessor = "collectionproperties->>"
  local filter = ''
  for key, keyValue in pairs(query) do
    for operator, operatorValue in pairs(keyValue) do
      local castType = ""
      if type(keyValue[operator]) != "string" then
        castType = "::numeric"
      end
      if (operator == 'in') then
        local invalues = '('
        local containsStrings
        for _, initem in ipairs(keyValue[operator]) do
          invalues = invalues .. initem .. ','
          if type(initem) == "string" then
            containsStrings = true
          end
        end
        if string.sub(invalues, -1) == "," then
          invalues = string.sub(invalues, 1, string.len(invalues) - 1)
        end
        invalues = invalues .. ')'
        filter = "'" .. key .. "'" .. ')' .. castType .. " " .. stacOperators[operator] .. " " .. invalues
      else
        filter = "'" .. key .. "'" .. ')' .. castType .. " " .. stacOperators[operator] .. " " .. keyValue[operator]
      end
      local propertyFilter = "(" .. propertiesAccessor .. filter
      local collectionPropertyFilter = "(" .. collectionPropertiesAccessor .. filter
      local logicalOr =
        propertyFilter .. " OR " .. collectionPropertyFilter
      table.insert(logicalAndTable, logicalOr)
    end
  end
  local logicalAndString = table.concat(logicalAndTable, " AND ")
  return logicalAndString
end
