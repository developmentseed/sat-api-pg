module("satapi", package.seeall)

function testing() -- create it as if it's a global function
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  local json = cjson.decode(body)
  print (json.intersects.type)
end
