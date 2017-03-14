local sql = require'carlos.sqlite'

local MM = {}

local function now() return os.time()-21600 end -- 18000

local function asweek(t) return os.date('Y%YW%U', t) end

local function dbconn(path) return sql.connect(string.format('/db/%s.db', path)) end

local function which( db )
    local conn = dbconn( db )
    if conn.exists'updates' then return conn.count'updates' else return 0 end
end

function MM.week() return asweek(now()) end

function MM.version(w)
    local time = now()
    local week = asweek(time)
    local vers = which( week )
    while vers == 0 do
	time = time - 3600*24*7
	week = asweek(time)
	vers = which( week )
    end
    w.week = week; w.vers = vers
    return w
end

MM.now = now

MM.asweek = asweek

MM.dbconn = dbconn

return MM
