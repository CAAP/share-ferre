#!/usr/local/bin/lua

local fd = require'carlos.fold'
local letra = require'ferre.enpesos'

local width = 38
local forth = {5, 7, 4, 12, 10}

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

local function ticket(w)
    local ret = {'\27\60', '',
	centrado'FERRETERIA AGUILAR',
	centrado'FERRETERIA Y REFACCIONES EN GENERAL',
	centrado'Benito Ju\225rez 1-C, Ocotl\225n, Oaxaca',
	centrado'Tel. (951) 57-10076',
	'',
	'',
	campos{'CLAVE', 'CNT', '%', 'PRECIO', 'TOTAL'},
	''
    }

    local function procesar(w)
	ret[#ret+1] = w.desc
	ret[#ret+1] = campos{w.clave, w.qty, w.rea, w.prc, w.subTotal}
	if w.uidSAT then
	    ret[#ret+1] = campos{w.uidSAT > 0 and math.tointeger(w.uidSAT) or 'XXXXX', '', '', '', ''}
        end
    end

    local function finish(w)
	local fecha, hora = w.uid:match('([^T]+)T([^P]+)')
	ret[2] = centrado(w.tag:upper())
	ret[7] = centrado(string.format('Fecha: %s | Hora: %s', fecha, hora))
	ret[#ret+1] = ''
	ret[#ret+1] = derecha(w.total)
	if w.iva then
	    table.remove(ret, 3); table.remove(ret, 3); table.remove(ret, 3); table.remove(ret, 3); table.remove(ret, 3)
	    ret[#ret+1] = derecha(string.format('I.V.A.   %s', w.iva))
	    return
        end
	if #w.total > width then local m = letra(w.total); ret[#ret+1] = m:sub(1, width); ret[#ret+1] = m:sub(width+1)
	else ret[#ret+1] = letra(w.total) end
    end

    if w.datos then fd.reduce(w.datos, procesar); finish(w) end
    ret[#ret+1] = string.format('\n%s', w.person:upper() or '')
    ret[#ret+1] = centrado'GRACIAS POR SU COMPRA'
    ret[#ret+1] = '\27\100\7 \27\105'
    return table.concat(ret, '\n')
end

return ticket
