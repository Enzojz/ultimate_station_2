local coor = require "ust/coor"
local line = {}

local math = math
local sin = math.sin
local cos = math.cos

-- line in form of
-- a.x + b.y + 1 = 0, if c != 0
-- if not
-- a.x + b.y + 0 = 0;
function line.new(a, b, c)
    local result = c ~= 0
        and {
            a = a / c,
            b = b / c,
            c = 1,
            vec = line.vec
        }
        or {
            a = a,
            b = b,
            c = 0,
            vec = line.vec
        }
    setmetatable(result,
        {
            __sub = line.intersection,
            __div = function(lhs, rhs) return rhs / lhs end
        })
    return result
end

function line.byVecPt(vec, pt)
    local a = vec.y
    local b = -vec.x
    local c = -(a * pt.x + b * pt.y)
    return line.new(a, b, c)
end

function line.byPtPt(pt1, pt2)
    return line.byVecPt(pt2 - pt1, pt2)
end

function line.byRadPt(rad, pt)
    return line.byVecPt({y = sin(rad), x = cos(rad)}, pt)
end

function line.vec(l)
    return coor.xy(-l.b, l.a):normalized()
end

function line.pend(l, pt)
    return line.byVecPt(coor.xy(l.a, l.b), pt)
end

function line.intersection(l1, l2)
    local a11 = l1.a
    local a12 = l1.b
    local a21 = l2.a
    local a22 = l2.b
    
    local b1 = -l1.c
    local b2 = -l2.c
    
    local iidet = (a11 * a22 - a21 * a12)
    if (iidet == 0) then 
        return nil
    else
        local idet = 1 / iidet
        local c11 = a22 * idet
        local c12 = -a12 * idet
        local c21 = -a21 * idet
        local c22 = a11 * idet
        
        return coor.xy(c11 * b1 + c12 * b2, c21 * b1 + c22 * b2)
    end
end

return line
