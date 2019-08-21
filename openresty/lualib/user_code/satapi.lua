module("satapi", package.seeall)
local defaultFields = { "id", "collection", "geometry", "properties" ,"type" , "assets" }

function testing() -- create it as if it's a global function
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  local json = cjson.decode(body)
  print (json.intersects.type)
end

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

function buildFieldsObject(fields)
  local selectTable = { "id", "type", "geometry", "properties" }
  local includeTable = {}
  local selectFields
  if fields.include then
    for _, field in ipairs(fields.include) do
      local prefix, key = string.match(field, "(.*)%.(.*)")
      if key then
        table.insert(includeTable, key)
      else
        table.insert(selectTable, field)
      end
    end
  end
  if (#selectTable) == 0 and (#includeTable) == 0 then
    selectTable = defaultFields
  end
  if (#includeTable) == 0 then
    table.insert(includeTable, "datetime")
  end
  selectFields = table.concat(selectTable, ",")
  return selectFields, includeTable
end

function handleRequest()
  local defaultSelect = table.concat(defaultFields, ",")
  local uriArgs = { select=defaultSelect }
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  if (body) then
    local bodyJson = cjson.decode(body)
    local query = bodyJson.query
    if query then
      local andString = buildQueryString(query)
      uriArgs["and"] = andString
    end
    local fields = bodyJson.fields
    if fields then
      local selectFields, includeTable = buildFieldsObject(fields)
      uriArgs["select"] = selectFields
      bodyJson["include"] = includeTable
      ngx.req.set_body_data(cjson.encode(bodyJson))
    end
    ngx.req.set_uri_args(uriArgs)
    ngx.req.set_uri("/rpc/search")
  end
end
