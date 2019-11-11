module("string_utils", package.seeall)

function wrapSingleQuote(value)
  return "'" .. value .. "'"
end
