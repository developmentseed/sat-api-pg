module("queryExtension", package.seeall)

function buildQueryString(query)
  local logicalAndTable = {}
  for key, keyValue in pairs(query) do
    for operator, operatorValue in pairs(keyValue) do
      local filter = "\"" .. key .. "\"" .. "." .. operator .. "." .. keyValue[operator]
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
