module("satapi", package.seeall)
require "extensions.fieldsExtension"
require "extensions.queryExtension"

local defaultFields = { "id", "collection", "geometry", "properties" ,"type" , "assets" }

function buildDatetime(datetime)
  local dateString
  local startdate, enddate = string.match(datetime, "(.*)/(.*)")
  if startdate and enddate then
    dateString = "datetime.gt." .. startdate .. "," .. "datetime.lt." .. enddate
  else
    dateString = "datetime.eq." .. datetime
  end
  return dateString
end

function handleRequest()
  -- Change cjson encoding behavior to support empty arrays.
  cjson.encode_empty_table_as_object(false)

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
        andQuery = queryExtension.buildQueryString(query)
        uriArgs["and"] = andQuery
      end

      local fields = bodyJson.fields
      if fields then
        local selectFields, includeTable = fieldsExtension.buildFieldsObject(fields, query)
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
        ngx.req.set_uri("/rpc/searchnogeom")
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
