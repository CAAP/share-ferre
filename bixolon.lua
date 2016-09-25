-- RFC 1179
local socket = require'socket'

local bix_port = 9100 -- daemon listens

local bix_ip = '192.168.10.21'

local function lpr(data)
    local skt = assert(socket.tcp(), 'Failed initializing tcp socket.')
    local _, e = skt:connect(bix_ip, bix_port)
    if e then skt:close(); error'Failed connecting to daemon.' end

    local function try(s, msg)
	local sz, e = skt:send( s )
	if e or (sz < 1) then skt:close(); error(msg) end
    end

    try(data)
    skt:close()
    return true
end

return lpr

