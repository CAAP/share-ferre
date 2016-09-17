local getenv = os.getenv

local hdr = require'ferre.header'

local query = getenv'QUERY_STRING'

local function action(f)
    if query then print( f(hdr.parse(query)) ) else print( f() ) end
end

return action
