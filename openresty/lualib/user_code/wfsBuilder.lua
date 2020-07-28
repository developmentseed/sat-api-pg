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

function buildInQuery(ids, wfsType)
  local wfsQuery
  if ids and wfsType then
    wrappedIds = {}
    for index, value in ipairs(ids) do
      table.insert(wrappedIds, wrapSingleQuote(value))
    end
    wfsQuery = pg_constants[wfsType] .. " IN " .. "(" .. table.concat(wrappedIds, ",") .. ")"
  end
  return wfsQuery
end
