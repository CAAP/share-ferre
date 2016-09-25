local int = math.tointeger

local centenas = {'CIENTO', 'DOSCIENTOS', 'TRESCIENTOS', 'CUATROSCIENTOS', 'QUINIENTOS', 'SEISCIENTOS', 'SETECIENTOS', 'OCHOCIENTOS', 'NOVECIENTOS'}

local unidades = {'UNO', 'DOS', 'TRES', 'CUATRO', 'CINCO', 'SEIS', 'SIETE', 'OCHO', 'NUEVE', 'DIEZ', 'ONCE', 'DOCE', 'TRECE', 'CATORCE', 'QUINCE', 'DIECISEIS', 'DIECISIETE', 'DIECIOCHO', 'DIECINUEVE', 'VEINTE'}
unidades[0] = 'ZERO'

local decenas = {'', 'VEINTI', 'TREINTA Y', 'CUARENTA Y', 'CINCUENTA Y', 'SESENTA Y', 'SETENTA Y', 'OCHENTA Y', 'NOVENTA Y'}

local suffix = {}
suffix[4] = 'MIL'; suffix[7] = 'MILLON'


local function enpesos(z)
    local y,c = z:match'(%d+)%.(%d%d)'
    local N = #y
    local ret = {}

    local function digit(i) return int(y:sub(i,i)) end

    if N == 1 and y == '1' then return string.format('UN PESO %s/100 M.N.',c) end
    if N == 0 then return string.format('ZERO PESOS %s/100 M.N.') end

    y = y:reverse()

    while N > 0 do
	local M = N%3
	if M == 0 then ret[#ret+1] = centenas[digit(N)] end
	if M == 1 then
	    print(digit(N))
	    ret[#ret+1] = digit(N) == 1 and 'UN' or unidades[digit(N)]
	    if suffix[N] then ret[#ret+1] = suffix[N] end
	end
	if M == 2 then
	    local x = int(y:sub(N-1, N):reverse())
	    if x == 20 then ret[#ret+1] = 'VEINTE'; N = N - 1
	    elseif digit(N) == 2 then ret[#ret+1] = decenas[2]..(digit(N-1) == 1 and 'UN' or unidades[digit(N-1)]); N = N - 1
	    elseif x>9 and unidades[x] then ret[#ret+1] = unidades[x]; N = N - 1
	    else ret[#ret+1] = decenas[digit(N)] end
	end
	N = N - 1
    end

    ret[#ret+1] = string.format('PESOS %s/100 M.N.', c)

    return table.concat(ret, ' ')
end


return enpesos
