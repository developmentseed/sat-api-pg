module("datetimeBuilder", package.seeall)
require "string_utils"
wrapSingleQuote = string_utils.wrapSingleQuote
local pg_constants = require "pg_constants"

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

function buildDatetimeSQL(datetime)
  local dateString
  local unknown = "::unknown"
  local startdate, enddate = string.match(datetime, "(.*)/(.*)")
  if startdate and enddate then
    dateString = pg_constants.datetime .. " > " .. wrapSingleQuote(startdate) .. unknown .. 
    " AND " .. pg_constants.datetime .. " < " .. wrapSingleQuote(enddate) .. unknown
  else
    dateString = pg_constants.datetime ..  " = " .. datetime
  end
  return dateString
end
