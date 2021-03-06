local fd = require'carlos.fold'

local PRC = 'SELECT desc, precio%d prc, IFNULL(u%d,"?") unit FROM precios WHERE clave LIKE %q'
--local PRC = 'SELECT desc, precio%d ||"/"|| IFNULL(u%d,"?") prc FROM precios WHERE clave LIKE %q'

local function int(s) return (math.tointeger(s) or s) end

local function precio(conn)
    return function(w)
    local j = w.precio:sub(-1)
    w.clave = int(w.clave)
    w.qty = int(w.qty)
    w.rea = int(w.rea)
    if not w.desc then
	local ret = fd.first( conn.query(string.format(PRC, j, j, w.clave)), function(x) return x end )
	w.desc = ret.desc
	w.prc = string.format('%s/%s', ret.prc, ret.unit)
	w.bruto = ret.prc*(100-w.rea)/116
	w.unit = ret.unit
    end
    w.subTotal = string.format('%.2f', w.totalCents/100)
    return w
    end
end

return precio

