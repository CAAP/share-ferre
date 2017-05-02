local M = {}

local post = 'POST %s HTTP/1.1\r\nHost: %s\r'
local protocol = 'HTTP/1.1 %s\r'
local access = 'Access-Control-Allow-Origin: %s\r\nAccess-Control-Allow-Methods: GET\r\n\r'
local content = { text='Content-Type: text/plain\r',
		  soap='Content-Type: application/soap+xml; charset=utf-8\r',
		  xml='Content-Type: text/xml; charset=utf-8\r',
		  urlencoded='Content-Type: application/x-www-form-urlencoded\r',
		  json='Content-Type: application/json\r\nConnection: keep-alive\r\nAccept: */*\r',
		  stream='Content-Type: text/event-stream\r\nConnection: keep-alive\r\nCache-Control: no-cache\r' }

local status = {ok='200 OK'}

local function hex(h) return string.char(tonumber(h,16)) end

local function urldecode(s) return s:gsub("+", "|"):gsub("%%(%x%x)", hex) end

local function asJSON( w )
--    assert(type(w) == 'table')
    local ret = {}
    for k,v in pairs(w) do
	local u = type(v) == 'table' and asJSON(v) or (math.tointeger(v) or v)
	ret[#ret+1] = string.format('%q: %'..(tonumber(u) and 's' or 'q'), k, u)
    end
    return string.format( '{%s}', table.concat(ret, ', ') ):gsub('"%[', '['):gsub(']"',']'):gsub("'", '"')
end

M.asJSON = asJSON

function M.args(keys, ...)
    local ret = {...}
    return function(s)
	local t = {table.unpack(ret)}
	for k,v in s:gmatch'([^|]+)|([^|]+)' do if keys[k] then t[keys[k]] = v end end
	return t
    end
end

-- parse an application/x-www-form-urlencoded string
function M.parse(q)
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

local function wrap(z)
    local MM = {}
    function MM.insert(s) z[#z+1] = s end
    function MM.asstr() z[#z+1] = '\n'; return table.concat(z, '\n') end
    return MM
end

-- w | status='ok', content='text', ip='*', [body]
function M.response(w)
    local ret = { string.format(protocol, status[w.status] or status.ok),
		  content[w.content] or content.text,
		  string.format(access, w.ip or '*') }
    if w.body then ret[#ret+1] = w.body end
    return wrap(ret)
end

function M.post(w)
    local k = w.url:find'/'
    local ret = { string.format(post, w.url:sub(k), w.url:sub(1,k-1)),
		  content[w.content] or content.urlencoded,
		  string.format('Content-Length: %d\r\n\r', #w.body) }
    if w.action then ret[#ret+1] = ret[#ret]; ret[#ret-1] = string.format('SOAPAction: %q\r', w.action) end
    ret[#ret+1] = w.body
--    ret[#ret+1] = '\n'
    return table.concat(ret, '\n')
end

function M.method(s) return s:match'GET /(%g+) HTTTP' end

function M.valid(line) return line and (line ~= '' and line or nil) end

return M
