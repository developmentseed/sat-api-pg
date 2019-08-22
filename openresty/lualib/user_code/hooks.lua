require "satapi"
local function on_init()
    -- print "on_init called"
end

local function on_rest_request()
  satapi.handleRequest()
end

local function before_rest_response()
  utils.set_body_postprocess_mode(utils.postprocess_modes.ALL)
  utils.set_body_postprocess_fn(function(body)
    local features = cjson.decode(body)
    local itemCollection = {
      type="FeatureCollection",
      features=features
    }
    return cjson.encode(itemCollection)
  end)
end

return {
    on_init = on_init,
    on_rest_request = on_rest_request,
    before_rest_response = before_rest_response,
}
