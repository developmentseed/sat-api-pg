require "satapi"
local function on_init()
    -- print "on_init called"
end

local function on_rest_request()
  satapi.handleRequest()
end

local function before_rest_response()
  local uri = string.gsub(ngx.var.request_uri, "?.*", "")
  local method = ngx.req.get_method()
  if uri == "/rest/items" then
    if method ~= "POST" then
      utils.set_body_postprocess_mode(utils.postprocess_modes.ALL)
      utils.set_body_postprocess_fn(satapi.wrapFeatureCollection)
    end
  end
  if uri == "/rest/search" then
    utils.set_body_postprocess_mode(utils.postprocess_modes.ALL)
    utils.set_body_postprocess_fn(satapi.wrapFeatureCollection)
  end
end

return {
    on_init = on_init,
    on_rest_request = on_rest_request,
    before_rest_response = before_rest_response,
}
