module("datetimeBuilder", package.seeall)

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
  local startdate, enddate = string.match(datetime, "(.*)/(.*)")
  if startdate and enddate then
    dateString = "datetime >= " .. startdate .. " AND " .. "datetime <= " .. enddate
  else
    dateString = "datetime = " .. datetime
  end
  return dateString
end
