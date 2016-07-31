local fd = require'carlos.fold'
local sql = require'carlos.sqlite'

local function asJSON( w )
    local ret = {}
    for k,v in pairs(w) do
	ret[#ret+1] = string.format('%q: %q', k , math.tointeger(v) or v)
    end
    return string.format( '{%s}', table.concat(ret, ', ') )
end

local function sql2json( q )
    local db = sql.connect( q.dbname )
    assert(db, 'Could not connect to DB')
    if db.count(q.tbname, q.clause) > 0 then
	local ret = fd.reduce( db.query( q.QRY ), fd.map( asJSON ), fd.into, {} )
	return string.format('Content-Type: text/plain; charset=utf-8\r\n\r\n[%s]\n', table.concat(ret, ', '))
    else
	return 'Content-Type: text/plain\r\n\r\n[]\n'
    end
end

return sql2json
