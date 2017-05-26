local hd = require'ferre.header'
local fd = require'carlos.fold'

local key = 'api-5BE260CC05B511E7B892F23C91C88F4E'

local url = 'https://api.smtp2go.com/v3'

local M = {}

function M.summary()
    print( hd.post{url=(url..'/stats/email_summary'), content='json'} )
end

return M
