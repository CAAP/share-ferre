local int = math.tointeger

local centenas = {'CIENTO', 'DOSCIENTOS', 'TRESCIENTOS', 'CUATROSCIENTOS', 'QUINIENTOS', 'SEISCIENTOS', 'SETECIENTOS', 'OCHOCIENTOS', 'NOVECIENTOS'}

local unidades = {'UN', 'DOS', 'TRES', 'CUATRO', 'CINCO', 'SEIS', 'SIETE', 'OCHO', 'NUEVE'}

local decenas = {'', 'VEINTI', 'TREINTA Y', 'CUARENTA Y', 'CINCUENTA Y', 'SESENTA Y', 'SETENTA Y', 'OCHENTA Y', 'NOVENTA Y', 'DIEZ', 'ONCE', 'DOCE', 'TRECE', 'CATORCE', 'QUINCE', 'DIECISEIS', 'DIECISIETE', 'DIECIOCHO', 'DIECINUEVE', 'VEINTE'}

local suffix = {}
suffix[4] = 'MIL'; suffix[7] = 'MILLON'


local function enpesos(z)
    local y,c = z:match'(%d+)%.(%d%d)'
    local N = #y
    local ret = {}

    local function digit(i) return int(y:sub(i,i)) end

    if N == 1 and y == '1' then return string.format('UN PESO %s/100 M.N.',c) end
    if N == 0 then return string.format('ZERO PESOS %s/100 M.N.') end
    if N > 7 or (N==7 and digit(1) > 1) then suffix[7] = 'MILLONES' end

    y = y:reverse()

    while N > 0 do
	local M = N%3
	if M == 0 then ret[#ret+1] = int(y:sub(N-2, N):reverse()) == 100 and 'CIEN' or centenas[digit(N)] end
	if M == 1 then -- uniddades
	    ret[#ret+1] = unidades[digit(N)]
	    if suffix[N] then ret[#ret+1] = suffix[N] end
	end
	if M == 2 then -- decenas
	    local x = int(y:sub(N-1, N):reverse())
	    if x>9 then
		local p = decenas[x] or ((x%10 == 0) and decenas[digit(N)]:gsub(' Y', ''))
		if p then ret[#ret+1] = p; N = N - 1 else ret[#ret+1] = decenas[digit(N)] end
--		ret[#ret+1] = decenas[x] or ((x%10 == 0) and decenas[digit(N)]:gsub(' Y', '') or decenas[digit(N)])
	    end
	end
	N = N - 1
    end

    ret[#ret+1] = string.format('PESOS %s/100 M.N.', c)

    return table.concat(ret, ' '):gsub('VEINTI ','VEINTI')
end

local function test()
    assert(enpesos'100.50' == 'CIEN PESOS 50/100 M.N.')
    assert(enpesos'116.45' == 'CIENTO DIECISEIS PESOS 45/100 M.N.')
    assert(enpesos'218.64' == 'DOSCIENTOS DIECIOCHO PESOS 64/100 M.N.')
    assert(enpesos'23.63' == 'VEINTITRES PESOS 63/100 M.N.')
    assert(enpesos'2020.03' == 'DOS MIL VEINTE PESOS 03/100 M.N.')
    assert(enpesos'1040.21' == 'UN MIL CUARENTA PESOS 21/100 M.N.')
    assert(enpesos'2030153.12' == 'DOS MILLONES TREINTA MIL CIENTO CINCUENTA Y TRES 12/100 M.N.' )
end

return enpesos
