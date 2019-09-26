require "satapi"
local function on_init()
    -- print "on_init called"
end

local function on_rest_request()
  local method = ngx.var.request_method
  ngx.ctx.originalMethod = method
  satapi.handleRequest()
end

local function before_rest_response()
  local uri = string.gsub(ngx.var.request_uri, "?.*", "")
  if uri == "/rest/items" then
    -- If items are posted they should be created
    -- Handle the case when a GET /items request with intersects redirects
    -- to a POST request to the /search endpoint
    if ngx.ctx.originalMethod ~= "POST" then
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
