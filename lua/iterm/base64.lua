-- encode function from http://lua-users.org/wiki/BaseSixtyFour
-- licensed under the terms of the LGPL2

local M = {}

-- character table string
local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- encoding
M.encode = function(data)
  return ((data:gsub(".", function(x)
    local r,b="",x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and "1" or "0") end
    return r;
  end).."0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
  if (#x < 6) then return "" end
  local c=0
  for i=1,6 do c=c+(x:sub(i,i)=="1" and 2^(6-i) or 0) end
  return charset:sub(c+1,c+1)
end)..({ "", "==", "=" })[#data%3+1])
end

return M
