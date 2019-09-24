module("queryExtension", package.seeall)

function buildQueryString(query)
  local logicalAndTable = {}
  local filter = ''
  for key, keyValue in pairs(query) do
    for operator, operatorValue in pairs(keyValue) do
      if (operator == 'in') then
        local invalues = '('
        for _, initem in ipairs(keyValue[operator]) do
          invalues = invalues .. initem .. ','
        end
        invalues = invalues .. ')'
        filter = "\"" .. key .. "\"" .. "." .. operator .. "." .. invalues
        print(filter)
      else
        filter = "\"" .. key .. "\"" .. "." .. operator .. "." .. keyValue[operator]
      end
      local propertyFilter = "properties->>" .. filter
      local collectionPropertyFilter = "collectionproperties->>" .. filter
      local logicalOr =
        "or(" .. propertyFilter .. "," .. collectionPropertyFilter.. ")"
      table.insert(logicalAndTable, logicalOr)
    end
  end
  local logicalAndString = "(" .. table.concat(logicalAndTable, ",") .. ")"
  return logicalAndString
end
