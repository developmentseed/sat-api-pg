module("wfsBuilder", package.seeall)
require "string_utils"
wrapSingleQuote = string_utils.wrapSingleQuote
local pg_constants = require "pg_constants"

function buildQuery(id, wfsType)
  local wfsQuery
  if id and wfsType then
    wfsQuery = pg_constants[wfsType] .. " = " ..  wrapSingleQuote(id)
  end
  return wfsQuery
end
