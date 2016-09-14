-- RFC 1179
local socket = require'socket'

local lpd_port = 515 -- daemon listens

local function lpr(data, pname)
    -- source port must be in the range 721-731
    local skt
    local port, localhost, printer, ip = 721, 'localhost', pname or 'lp', '127.0.0.1'
    local jobid = string.format('%3.3d%-s', os.time()%999 + 1, localhost)

    repeat
	skt = assert(socket.tcp(), 'Failed initializing tcp socket.')
	local _, e = skt:bind(ip, port)
	if e then skt:close(); port = port + 1 else break end
    until port > 731
    skt = assert(socket.tcp(), 'Failed initializing tcp socket.')
    local _, e = skt:connect(ip, lpd_port)
    if e then skt:close(); error'Failed connecting to daemon.' end

    local function try(s, msg)
	local sz, e = skt:send( s )
	if e or (sz < 1) then skt:close(); error(msg) end
    end

    -- acknowledgment | handshake
    local function recv_ack()
	local cd, e = skt:receive(1)
	if e or (string.char(0) ~= cd) then skt:close(); error('Error receiving acknowledgment from server.') end
    end

    local function send_eof() try(string.char(0), 'Error sending EOF.') end

    -- Receive a printer job

    local function queue()
	try(string.format('\2%s\n', printer), 'Error sending print request.')
	recv_ack()
    end

	-- Subcommands

    local function send_ctr()
	local cmds = string.format('H%-s\nP%-s\nldfA%-s\n', localhost, 'anon', jobid)

	try(string.format('\2%d cfA%-s\n', #cmds, jobid), 'Error sending control header.')
	recv_ack()

	try(cmds, 'Error sending control commands.')
	send_eof()
	recv_ack()
    end

    local function send_data(data)
	try(string.format('\3%d dfA%-s\n', #data, jobid), 'Error sending data. header.')
	recv_ack()

	try(data, 'Error sending data.')
	send_eof()
	recv_ack()
    end

    queue()
    send_ctr()
    send_data(data)
    skt:close()
end

return lpr

--[[
local function test(a)
    local fs = require'carlos.files'
    fs.dump('datos.txt', a)
end

return test

--]]
