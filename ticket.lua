#!/usr/local/bin/lua

local fd = require'carlos.fold'
local mx = require'ferre.timezone'

local width = 38
local forth = {6, 5, 4, 13, 10}

local function centrado(s)
    local m = s:len()
    local n = math.floor((width-m)/2 + 0.5) + m
    return string.format('%'..n..'s', s)
end

local function derecha(s)
    return string.format('%'..width..'s', s)
end

local function campos(w)
    return table.concat(fd.reduce(w, fd.map(function(x,j) return string.format('%'..forth[j]..'s', x) end), fd.into, {}), '')
end

local ret = {'',
	centrado'FERRETERIA AGUILAR',
	centrado'FERRETERIA Y REFACCIONES EN GENERAL',
	centrado'Benito Juárez 1-C, Ocotlán, Oaxaca',
	centrado'Tel. 57-10076',
	centrado(os.date('%FT%T', mx())),
	'',
	campos({'CLAVE', 'CNT', '%', 'PRECIO', 'TOTAL'}),
	''}

local function procesar(w)
    ret[#ret+1] = string.format('%38s', w.desc) -- w.desc
    ret[#ret+1] = campos{w.clave, w.qty, w.rea, w.prc:gsub('%s',''), w.subTotal}
end

local function finish(w)
    ret[1] = centrado(w.tag:upper())
    ret[#ret+1] = ''
    ret[#ret+1] = derecha(w.total)
--    ret[#ret+1] = w.person:upper()
end

--{centrado('GRACIAS POR SU COMPRA')}

local function ticket(w)
    if w.data then fd.reduce(w.data, procesar); finish(w) end
    ret[#ret+1] = string.format('\n%s', w.person:upper() or '')
    ret[#ret+1] = centrado'GRACIAS POR SU COMPRA'
    ret[#ret+1] = '\27\100\7 \27\105'
    return table.concat(ret, '\n')
end

return ticket
