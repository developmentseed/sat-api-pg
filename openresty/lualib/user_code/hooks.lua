require "satapi"
local path_constants = require "path_constants"
local apiPath = path_constants.apiPath
local searchPath = path_constants.searchPath
local itemsPath = path_constants.itemsPath
local collectionsPath = path_constants.collectionsPath
local conformancePath = path_constants.conformancePath
local stacPath = path_constants.stacPath
local ngx_re = require "ngx.re"

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
  local uriComponents = ngx_re.split(uri, '/')
  local collections = uriComponents[2]
  local collectionId = uriComponents[3]
  local items = uriComponents[4]
  local itemId = uriComponents[5]

  -- Don't wrap in a feature collection
  if ((collections == 'collections' and items == nil) or itemId or uri == apiPath or uri == stacPath or uri == (stacPath .. '/')) then
  else
    if uri == conformancePath then
      utils.set_body_postprocess_mode(utils.postprocess_modes.ALL)
      utils.set_body_postprocess_fn(satapi.returnConformance)
    else
      -- If items are posted they should be created
      -- Handle the case when a GET /items request with intersects redirects
      -- to a POST request to the /search endpoint
      if ngx.ctx.originalMethod == "POST" then
        if uri ~= itemsPath then
          utils.set_body_postprocess_mode(utils.postprocess_modes.ALL)
          utils.set_body_postprocess_fn(satapi.wrapFeatureCollection)
        end
      else
        utils.set_body_postprocess_mode(utils.postprocess_modes.ALL)
        utils.set_body_postprocess_fn(satapi.wrapFeatureCollection)
      end
    end
  end
end

return {
    on_init = on_init,
    on_rest_request = on_rest_request,
    before_rest_response = before_rest_response,
}
