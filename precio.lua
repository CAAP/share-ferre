local fd = require'carlos.fold'
local sql = require'carlos.sqlite'

local function precio(w)
    local j = w.precio:sub(-1)
    w.clave = w.clave
    w.qty = w.qty
    w.rea = w.rea
    if not w.desc then
	local ret = fd.first( conn.query(string.format(PRC, j, j, w.clave)), function(x) return x end )
	w.desc = ret.desc
	w.prc = ret.prc
    end
    w.subTotal = string.format('%.2f', w.totalCents/100)
    return w
end

return precio

