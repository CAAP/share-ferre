local getenv = os.getenv

local query = getenv'QUERY_STRING'

local function hex(h) return string.char(tonumber(h,16)) end

local function urldecode(s) return s:gsub("+", " "):gsub("%%(%x%x)", hex) end

-- parse an application/x-www-form-urlencoded string
local function parse(q)
    local t = {args={}}
    for pair in q:gmatch'[^&]+' do
	if (pair and #pair>0) then
	local _, _, n, v = pair:find'([^=]*)=([^=]*)'
	n = n and urldecode(n) or ''
	v = v and urldecode(v) or ''
	if t[n] then
	    if type(t[n]) ~= 'table' then t[n] = {t[n]} end
	    table.insert(t[n], v)
	else t[n] = v end
	end
    end
    return t
end

local function action(f)
    if query then print( f(parse(query)) ) else print( f() ) end
end

return action
