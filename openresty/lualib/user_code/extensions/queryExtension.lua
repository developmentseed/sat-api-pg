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
  local propertiesAccessor = "properties->"
  local collectionPropertiesAccessor = "collectionproperties->"
  for key, keyValue in pairs(query) do
    for operator, operatorValue in pairs(keyValue) do
      local castType = ""
      local sqlValue
      if type(keyValue[operator]) == "number" then
        castType = "::numeric"
        sqlValue = keyValue[operator]
      elseif type(keyValue[operator]) == "string" then
        propertiesAccessor =  "properties->>"
        collectionPropertiesAccessor = "collectionproperties->>"
        sqlValue = wrapSingleQuote(keyValue[operator])
      end
      if (operator == "in") then
        local invalues = "("
        for _, initem in ipairs(keyValue[operator]) do
          if type(initem) == "number" then
            castType = "::numeric"
            invalues = invalues .. initem .. ","
          elseif type(initem) == "string" then
            propertiesAccessor =  "properties->>"
            collectionPropertiesAccessor = "collectionproperties->>"
            invalues = invalues .. wrapSingleQuote(initem) .. ","
          end
        end
        if string.sub(invalues, -1) == "," then
          invalues = string.sub(invalues, 1, string.len(invalues) - 1)
        end
        sqlValue = invalues .. ")"
      else
        stacOperators[operator] .. " " .. sqlValue
      end
      local logicalCoalesce = "COALESCE(" .. propertiesAccessor ..
        wrapSingleQuote(key) .. "," .. collectionPropertiesAccessor ..
        wrapSingleQuote(key) .. ")" .. castType .. " " .. stacOperators[operator]
        .. " " .. sqlValue
      table.insert(logicalAndTable, logicalCoalesce)
    end
  end
  local logicalAndString = table.concat(logicalAndTable, " AND ")
  return logicalAndString
end
