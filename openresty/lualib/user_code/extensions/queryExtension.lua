module("queryExtension", package.seeall)
require "string_utils"
wrapSingleQuote = string_utils.wrapSingleQuote
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
  local filter = ""
  for key, keyValue in pairs(query) do
    for operator, operatorValue in pairs(keyValue) do
      local castType = ""
      local sqlValue
      if type(keyValue[operator]) ~= "string" then
        castType = "::numeric"
        sqlValue = keyValue[operator]
      else
        sqlValue = wrapSingleQuote(keyValue[operator])
      end
      if (operator == "in") then
        local invalues = "("
        for _, initem in ipairs(keyValue[operator]) do
          if type(initem) == "string" then
            invalues = invalues .. wrapSingleQuote(initem) .. ","
          else
            invalues = invalues .. initem .. ","
          end
        end
        if string.sub(invalues, -1) == "," then
          invalues = string.sub(invalues, 1, string.len(invalues) - 1)
        end
        invalues = invalues .. ")"
        filter = wrapSingleQuote(key) .. ")" .. castType .. " " ..
         stacOperators[operator] .. " " .. invalues
      else
        filter = wrapSingleQuote(key) .. ")" .. castType .. " " ..
        stacOperators[operator] .. " " .. sqlValue
      end
      local propertyFilter = "(" .. propertiesAccessor .. filter
      local collectionPropertyFilter = "(" .. collectionPropertiesAccessor .. filter
      local logicalOr =
        "(" .. propertyFilter .. " OR " .. collectionPropertyFilter .. ")"
      table.insert(logicalAndTable, logicalOr)
    end
  end
  local logicalAndString = table.concat(logicalAndTable, " AND ")
  return logicalAndString
end
