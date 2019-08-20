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
  local json = cjson.decode(body)
  if json.query then
    local propertiesQuery = {}
    for key, keyValue in pairs(json.query) do
      for operator, operatorValue in pairs(keyValue) do
        local propertyFilter = "properties->>"
          .. key .. "." .. operator .. "." .. keyValue[operator]
        table.insert(propertiesQuery, propertyFilter)
      end
    end
    local query = table.concat(propertiesQuery, ",")
    print(query)
  end
end
