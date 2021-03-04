local pipe = require "ust/pipe"
local func = require "ust/func"
local coor = require "ust/coor"

local bit32 = bit32
local band = bit32.band
local lshift = bit32.lshift
local bor = bit32.bor

local unpack = table.unpack
local abc, kern = unpack(require "ust/alte_din_1451_mittelschrift_bold")

local function utf2unicode(str)
    if (str == nil) then return pipe.new / 0 end
    local function continue(val, c, ...)
        if (c and band(c, 0xC0) == 0x80) then
            return continue(bor(lshift(val, 6), band(c, 0x3F)), ...)
        else
            return val, {c, ...}
        end
    end
    local function convert(rs, c, ...)
        if (c == nil) then return rs
        elseif (c < 0x80) then
            return convert(rs / c, ...)
        else
            local lGr = c < 0xE0 and 2
                or c < 0xF0 and 3
                or c < 0xF8 and 4
                or error("invalid UTF-8 character sequence")
            local val, rest = continue(band(c, 2 ^ (8 - lGr) - 1), ...)
            return convert(rs / val, unpack(rest))
        end
    end
    return convert(pipe.new, str:byte(1, -1))
end

local gen = function(scale, z)
    local scale = scale or 1
    local z = z or 0
    return function(text)
        local result = utf2unicode(text)
            * pipe.fold(pipe.new * {},
                function(r, c)
                    local lastPos = #r > 0 and r[#r].to or 0
                    local abc = abc[c]
                    local kern = kern[c]
                    if (abc) then
                        local pos = lastPos + abc.a + (#r > 0 and kern and kern[r[#r].c] or 0)
                        local nextPos = pos + abc.b + abc.c
                        return r / {c = c, from = pos, to = nextPos}
                    else
                        return r
                    end
                end)
        if (#result > 0) then
            local width = result[#result].to * scale
            return
                function(fTrans) return func.map(result, function(r)
                    return {
                        id = "ust/alte_din_1451_mittelschrift_bold/" .. tostring(r.c) .. ".mdl",
                        transf = coor.transX(r.from) * coor.scale(coor.xyz(scale, scale, scale)) * coor.transZ(z * scale) * (fTrans(width) or coor.I())
                    }
                end)
                end, width
        else
            return false, false
        end
    end
end

return gen
