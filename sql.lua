local sql = require'carlos.sqlite'

local function action( w )
    local conn = sql.connect(w.dbname)
    conn.exec( string.format(sql.newTable, w.tbname, w.schema) )
    sql[w.method](w.args)(conn)(w.x, 1)
end

return action
