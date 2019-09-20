module("fieldsExtension", package.seeall)

function buildFieldsObject(fields, query)
  local selectTable = { "id", "type", "geometry", "properties", "assets" }
  local includeTable = {}
  local selectFields
  -- A default property which must be specified in the includes body for seach
  table.insert(includeTable, "datetime")
  if fields.exclude then
    for _, field in ipairs(fields.exclude) do
      -- This splits out properties fields
      local prefix, key = string.match(field, "(.*)%.(.*)")
      -- If the key is present it is a properties field
      if key then
        table.remove(includeTable, includeTable[key])
      else
        -- Lua is a mystery
        table.remove(selectTable, selectTable[field])
      end
    end
  end
  if fields.include then
    for _, field in ipairs(fields.include) do
      -- This splits out properties fields
      local prefix, key = string.match(field, "(.*)%.(.*)")
      -- If the key is present it is a properties field
      if key then
        table.insert(includeTable, key)
      else
        table.insert(selectTable, field)
      end
    end
  end
  -- This is a temporary hack as the nature of the query requires the fields to be present
  if query then
    for key, keyValue in pairs(query) do
      table.insert(includeTable, key)
    end
  end
  selectFields = table.concat(selectTable, ",")
  return selectFields, includeTable
end
