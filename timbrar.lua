local mime = require'mime'
local socket = require'socket'

local hdr = require'ferre.header'

local fd = require'carlos.fold'

local rfc = 'AUMA501114S7A'
local ip = '200.53.180.22'
local url = '200.53.180.22/serviciointegracion/Timbrado.asmx'

local codes = {['&'] = '&amp;', ['&amp;'] = '&',
	['<'] = '&lt;', ['&lt;'] = '<',
	['>'] = '&gt;', ['&gt;'] = '>',
	['"'] = '&quot;' , ['&quot;'] = '"',
	["'"] = '&apos;' , ['&apos;'] = "'"}

local xmlsoap = [==[<?xml version="1.0" encoding="utf-8"?>

<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">

<soap12:Body>
    <METHOD xmlns="http://localhost/">
	<usuarioIntegrador>hqca5emFndvjvqwoVegapw==|9oi8j3ydg</usuarioIntegrador>
	BODY
    </METHOD>
</soap12:Body>

</soap12:Envelope>]==]

local function escape(s) return s:gsub('[&<>\'"]', codes) end

local function unescape(s) return s:gsub('(&%a+;)', codes) end

local MM = {}

local function soaprequest(action, params)
    local body = xmlsoap:gsub('([A-Z]+)', {METHOD=action, BODY=params})
    local msg = hdr.post{url=url, content='soap', body=body}
    local skt = assert( socket.connect(ip, 80) )
    skt:settimeout(1)
    local sz, e = skt:send(msg)
    if e or (sz < 1) then skt:close(); error(msg) end
    local msg, e = skt:receive()
    local ret = {msg}
    if not(e) and msg:match'200 OK' then
	repeat t, e, msg = skt:receive(); ret[#ret+1] = t or msg until e
	skt:close()
	return table.concat(ret, '')
    else 
	skt:close()
	return nil, (msg or e)
    end
end

local function astag(a)
    local ret = {}
    for k,v in pairs(a) do ret[#ret+1] = string.format('<%s>%s</%s>', k, v, k) end
    return table.concat(ret, '')
end

local function parse(s)
    local ret = {}
    for k,v in s:gmatch'<anyType xsi:type="xsd:([^"]+)"[ /]->([^<]*)' do -- </anyType>
	if k == 'string' then ret[#ret+1] = unescape(v) end
	if k == 'base64Binary' then ret[#ret+1] = v end -- mime.unb64(
	if k == 'int' then ret[#ret+1] = tonumber(v) end
    end
    assert(ret[2] == 0, ret[3])
    return ret
end

local function valores(s, k, a) return fd.reduce(function() return s:gmatch'(%a+)="([^"]+)"' end, fd.rejig(function(v,kk) return v, string.format('%s.%s',k,kk) end), fd.merge, a) end

-- REMOVE XXX
--[[
local function xmlparser(s)
    local iter = s:gmatch'<(/?)cfdi:(%a+)([^>]-)(/?)>'

    local function curry(q, z, k, v, w)
	if not(z) or #z == 1 then return q end

	if #w == 1 then q[k] = {args=valores(v)} end

	if q.args then q[k] = curry({args=valores(v)}, iter())
	else q[k] = {args=valores(v)} end
	
	return curry(q, iter())
    end

    return curry({}, iter())
end
--]]

local function getcfdi(s)
    local ret = {Conceptos={}}
    local cptos = ret.Conceptos
    for k,v in s:gmatch'<[cfdit]+:(%a+) ([^>]+)>' do
	if k == 'Concepto' then cptos[#cptos+1] = valores(v, k, {})
	else valores(v, k, ret) end
    end
    return ret
end

function MM.timbres()
    local action = 'ObtieneTimbresDisponibles'
    local ans = assert( soaprequest(action, astag{rfcEmisor=rfc}) )
    ans = parse(ans)
    return {total=ans[4], usados=ans[5], disponibles=ans[6]}
end

function MM.obtener(uuid)
    local action = 'ObtieneCFDI'
    local ans = assert( soaprequest(action, astag{rfcEmisor=rfc, folioUUID=uuid}) )
    ans = parse(ans)
    local ret = getcfdi(ans[4])
    ret.QRCode = ans[5]
    ret.CadenaOriginal = ans[6]
    return ret
end

function MM.timbrar(xmldata, id)
    local action = 'TimbraCFDI'
    local ans = assert( soaprequest(action, astag{xmlComprobanteBase64=mime.b64(xmldata), idComprobante=id}) )
    ans = parse(ans)
    return {cfdi=getcfdi(ans[4]), qrcode=ans[5], cadena=ans[6]}
end

function MM.cancelar()
    local action = "CancelaCFDI"
    local ans = assert( soaprequest(action, astag{rfcEmisor=rfc, folioUUID=uuid}) )
    ans = parse(ans)
    return {cfdi=getcfdi(ans[4]), qrcode=ans[5], cadena=ans[6]}
end

return MM
