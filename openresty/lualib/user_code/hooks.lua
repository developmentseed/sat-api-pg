require "satapi"
local function on_init()
    -- print "on_init called"
end

local function on_rest_request()
  local uriArgs = { select="collection,geometry,properties,type,assets" }
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  local bodyJson = cjson.decode(body)
  local query = bodyJson.query
  if query then
    local andString = satapi.buildQueryString(query)
    uriArgs["and"] = andString
  end
 ngx.req.set_uri_args(uriArgs)
end

local function before_rest_response()
    -- print "before_rest_response called"
end

return {
    on_init = on_init,
    on_rest_request = on_rest_request,
    before_rest_response = before_rest_response,
}
