local fd = require'carlos.fold'
local sql = require'carlos.sqlite'
local hdr = require'ferre.header'

local function sql2json( q )
    assert(io.open(q.dbname)) -- file MUST exists
    local db = assert(sql.connect(q.dbname) , 'Could not connect to DB')
    if db.count(q.tbname, q.clause) > 0 then
	local ret = fd.reduce( db.query( q.QRY ), fd.map( hdr.asJSON ), fd.into, {} )
	return string.format('Content-Type: text/plain; charset=utf-8\r\n\r\n[%s]\n', table.concat(ret, ', '))
    else
	return 'Content-Type: text/plain\r\n\r\n[]\n'
    end
end

return sql2json
