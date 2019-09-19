module("satapi", package.seeall)
local defaultFields = { "id", "collection", "geometry", "properties" ,"type" , "assets" }

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

function buildFieldsObject(fields, query)
  local selectTable = { "id", "type", "geometry", "properties", "assets" }
  local includeTable = {}
  local excludeTable = {}
  local selectFields
  if fields.include then
    for _, field in ipairs(fields.include) do
      -- This splits out properties fields
      local prefix, key = string.match(field, "(.*)%.(.*)")
      -- If the key is present it is a properties field
      if key then
        table.insert(includeTable, key)
      else
        table.insert(selectTable, field)
      end
    end
  end
  if fields.exclude then
    for _, field in ipairs(fields.exclude) do
      -- This splits out properties fields
      local prefix, key = string.match(field, "(.*)%.(.*)")
      -- If the key is present it is a properties field
      if key then
        table.insert(excludeTable, key)
      else
        selectTable[field] = nil
      end
    end
  end
  -- This is a temporary hack as the nature of the query requires the fields to be present
  if query then
    for key, keyValue in pairs(query) do
      table.insert(includeTable, key)
      excludeTable[key] = nil
    end
  end
  if (#includeTable) == 0 and (#excludeTable) == 0 then
    table.insert(includeTable, "datetime")
  end
  selectFields = table.concat(selectTable, ",")
  return selectFields, includeTable
end

function buildDatetime(datetime)
  local dateString
  local startdate, enddate = string.match(datetime, "(.*)/(.*)")
  print (startdate, enddate)
  if startdate and enddate then
    dateString = "datetime.gt." .. startdate .. "," .. "datetime.lt." .. enddate
  else
    dateString = "datetime.eq." .. datetime
  end
  return dateString
end

function handleRequest()
  local defaultSelect = table.concat(defaultFields, ",")
  local uriArgs = { select=defaultSelect }
  local andQuery
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  local uri = string.gsub(ngx.var.request_uri, "?.*", "")
  if uri == "/rest/search" then
    if (body) then
      local bodyJson = cjson.decode(body)

      local query = bodyJson.query
      if query then
        andQuery = buildQueryString(query)
        uriArgs["and"] = andQuery
      end

      local fields = bodyJson.fields
      if fields then
        local selectFields, includeTable = buildFieldsObject(fields, query)
        uriArgs["select"] = selectFields
        bodyJson["include"] = includeTable
        ngx.req.set_body_data(cjson.encode(bodyJson))
      end

      local datetime = bodyJson.datetime
      if datetime then
        local dateString = buildDatetime(datetime)
        if andQuery then
          local andDateQuery =
            string.sub(andQuery, 1,-2) .. "," .. dateString .. ")"
            uriArgs["and"] = andDateQuery
        else
          uriArgs["and"] = "(" .. dateString .. ")"
        end
      end
      ngx.req.set_uri_args(uriArgs)

      local bbox = bodyJson.bbox
      local intersects = bodyJson.intersects
      if bbox or intersects then
        ngx.req.set_uri("/rpc/search")
      else
        if fields then
          ngx.req.set_uri("/rpc/searchnogeom")
        end
      end
    end
  end
end

function wrapFeatureCollection(body)
  local features = cjson.decode(body)
  local itemCollection = {
    type="FeatureCollection",
    features=features
  }
  return cjson.encode(itemCollection)
end
