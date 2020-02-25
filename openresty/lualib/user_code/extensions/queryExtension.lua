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
  for key, keyValue in pairs(query) do
    for operator, operatorValue in pairs(keyValue) do
      local propertiesAccessor
      local collectionPropertiesAccessor
      local castType = ""
      local sqlValue
      if type(keyValue[operator]) == "number" then
        castType = "::numeric"
        sqlValue = keyValue[operator]
        propertiesAccessor =  "properties->"
        collectionPropertiesAccessor = "collectionproperties->"
      elseif type(keyValue[operator]) == "string" then
        sqlValue = wrapSingleQuote(keyValue[operator])
        propertiesAccessor =  "properties->>"
        collectionPropertiesAccessor = "collectionproperties->>"
      end
      if (operator == "in") then
        local invalues = "("
        for _, initem in ipairs(keyValue[operator]) do
          if type(initem) == "number" then
            castType = "::numeric"
            invalues = invalues .. initem .. ","
            propertiesAccessor =  "properties->"
            collectionPropertiesAccessor = "collectionproperties->"
          elseif type(initem) == "string" then
            invalues = invalues .. wrapSingleQuote(initem) .. ","
            propertiesAccessor =  "properties->>"
            collectionPropertiesAccessor = "collectionproperties->>"
          end
        end
        if string.sub(invalues, -1) == "," then
          invalues = string.sub(invalues, 1, string.len(invalues) - 1)
        end
        sqlValue = invalues .. ")"
      end
      -- local logicalCoalesce = "COALESCE(" .. propertiesAccessor ..
        -- wrapSingleQuote(key) .. "," .. collectionPropertiesAccessor ..
        -- wrapSingleQuote(key) .. ")" .. castType .. " " .. stacOperators[operator]
        -- .. " " .. sqlValue
      local andClause =  "(" .. propertiesAccessor ..
        wrapSingleQuote(key) .. ")" .. castType .. " " ..
        stacOperators[operator] ..  " " .. sqlValue
      table.insert(logicalAndTable, andClause)
    end
  end
  local logicalAndString = table.concat(logicalAndTable, " AND ")
  return logicalAndString
end
