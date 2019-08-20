module("satapi", package.seeall)

function testing() -- create it as if it's a global function
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  local json = cjson.decode(body)
  print (json.intersects.type)
end

function buildQueryString()
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  local bodyJson = cjson.decode(body)
  local query = bodyJson.query
  if query then
    local logicalAndTable = {}
    for key, keyValue in pairs(query) do
      for operator, operatorValue in pairs(keyValue) do
        local filter = key .. "." .. operator .. "." .. keyValue[operator]
        local propertyFilter = "properties->>" .. filter
        local collectionPropertyFilter = "collectionproperties->>" .. filter
        local logicalOr =
          "or(" .. propertyFilter .. "," .. collectionPropertyFilter.. ")"
        table.insert(logicalAndTable, logicalOr)
      end
    end
    local logicalAndString = "and=(" .. table.concat(logicalAndTable, ",") .. ")"
    print(logicalAndString)
  end
end
