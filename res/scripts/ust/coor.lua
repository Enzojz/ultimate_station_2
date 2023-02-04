--[[
Copyright (c) 2016 "Enzojz" from www.transportfever.net
(https://www.transportfever.net/index.php/User/27218-Enzojz/)

Github repository:
https://github.com/Enzojz/transportfever

Anyone is free to use the program below, however the auther do not guarantee:
* The correctness of program
* The invariance of program in future
=====!!!PLEASE  R_E_N_A_M_E  BEFORE USE IN YOUR OWN PROJECT!!!=====

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including the right to distribute and without limitation the rights to use, copy and/or modify
the Software, and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--]]
---@class coor2
---@field x number
---@field y number
---@field length fun(self: coor2): number
---@field length2 fun(self: coor) : number
---@field normalized fun(self: coor2) : coor2
---@field withZ fun(self: coor2, z: number) : coor3
---@field avg fun(self: coor2, others...: coor2) : coor2
---@field dot fun(lhs: coor2, rhs: coor2) : number
---@field cross fun(lhs: coor2, rhs: coor2) : number
---@operator add(coor2): coor2
---@operator sub(coor2): coor2
---@operator mul(number): coor2
---@operator div(number): coor2
---@operator mod(coor2): number
---@operator unm(coor2): coor2
---
---@class coor3
---@field x number
---@field y number
---@field z number
---@field length fun(self: coor3): number
---@field length2 fun(self: coor3): number
---@field normalized fun(self: coor3): coor3
---@field withZ fun(self: coor3, z: number): coor3
---@field avg fun(self: coor3, others...: coor3): coor3
---@field dot fun(lhs: coor3, rhs: coor3) : number
---@field cross fun(lhs: coor3, rhs: coor3) : coor3
---@field toTuple fun(self: coor3): table
---@operator add(coor3): coor3
---@operator sub(coor3): coor3
---@operator mul(number): coor3
---@operator div(number): coor3
---@operator mod(coor3): number
---@operator unm(coor3): coor3
---@operator concat(matrix): coor3
---
---@alias coor coor2|coor3
---@operator sub(coor): coor
---@operator add(coor): coor
---@operator mul(number): coor
---
---@class matrix
---@field [1] number
---@field [2] number
---@field [3] number
---@field [4] number
---@field [5] number
---@field [6] number
---@field [7] number
---@field [8] number
---@field [9] number
---@field [10] number
---@field [11] number
---@field [12] number
---@field [13] number
---@field [14] number
---@field [15] number
---@field [16] number
---@operator mul(matrix): matrix
---@operator call(coor3): coor3
local func = require "ust/func"

local coor = {}

local math = math
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local unpack = table.unpack
local insert = table.insert

local vecXyMeta = {
    __add = function(lhs, rhs)
        return coor.xy(lhs.x + rhs.x, lhs.y + rhs.y)
    end
    ,
    __sub = function(lhs, rhs)
        return coor.xy(lhs.x - rhs.x, lhs.y - rhs.y)
    end
    ,
    __mul = function(lhs, rhs)
        return coor.xy(lhs.x * rhs, lhs.y * rhs)
    end,
    __div = function(lhs, rhs)
        return coor.xy(lhs.x / rhs, lhs.y / rhs)
    end,
    __mod = function(lhs, rhs)
        return (lhs - rhs):length()
    end,
    __unm = function(lhs)
        return lhs * -1
    end,
    __index = function(xy, key)
        if key == 1 then
            return xy.x
        elseif key == 2 then
            return xy.y
        elseif key == 3 then
            return 0
        else
            return nil
        end
    end
}

---@param self coor2
---@return number
local vecXyLength = function(self) return sqrt(self:length2()) end

---@param self coor2
---@return number
local vecXyLength2 = function(self) return self.x * self.x + self.y * self.y end

---@param self coor2
---@return coor2
local vecXyNormalized = function(self) return self / self:length() end

---@param self coor2
---@return coor3
local vecXyZ = function(self, z) return coor.xyz(self.x, self.y, z) end

---@param self coor2
---@param other coor2
---@return number
local vecXyCross = function(self, other) return self.x * other.y - self.y * other.x end

---@param self coor2
---@param ...coor2
---@return coor2
local vecXyAvg = function(self, ...)
    local pts = {...}
    return func.fold(pts, self, function(l, r) return l + r end) / (#pts + 1)
end

---comment
---@param x number
---@param y number
---@return coor2
function coor.xy(x, y)
    local result = {
        x = x,
        y = y,
        length2 = vecXyLength2,
        length = vecXyLength,
        normalized = vecXyNormalized,
        withZ = vecXyZ,
        avg = vecXyAvg,
        dot = function(self, other) return self.x * other.x + self.y * other.y end,
        cross = vecXyCross
    }
    setmetatable(result, vecXyMeta)
    return result
end

local vecXyzMeta = {
    __add = function(lhs, rhs)
        return rhs.z and coor.xyz(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z) or coor.xy(lhs.x + rhs.x, lhs.y + rhs.y)
    end
    ,
    __sub = function(lhs, rhs)
        return rhs.z and coor.xyz(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z) or coor.xy(lhs.x - rhs.x, lhs.y - rhs.y)
    end
    ,
    __mul = function(lhs, rhs)
        return coor.xyz(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    end,
    __div = function(lhs, rhs)
        return coor.xyz(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    end,
    __concat = function(lhs, rhs)
        return coor.apply(lhs, rhs)
    end,
    __mod = function(lhs, rhs)
        return (lhs - rhs):length()
    end,
    __unm = function(lhs)
        return lhs * -1
    end,
    __index = function(xyz, key)
        if key == 1 then
            return xyz.x
        elseif key == 2 then
            return xyz.y
        elseif key == 3 then
            return xyz.z
        else
            return nil
        end
    end
}

---@param self coor3
---@return number
local vecXyzLength = function(self) return sqrt(self:length2()) end

---@param self coor3
---@return number
local vecXyzLength2 = function(self) return self.x * self.x + self.y * self.y + self.z * self.z end

---@param self coor3
---@return table
local vecXyzNormalized = function(self) return self / self:length() end
local vecXyzToTuple = function(self) return {self.x, self.y, self.z} end


---@param self coor3
---@param other coor3
---@return number
local vecXyzDot = function(self, other) return self.x * other.x + self.y * other.y + self.z * other.z end

---@param self coor3
---@param other coor3
---@return coor3
local vecXyzCross = function(self, other) return coor.xyz(
    self.y * other.z - self.z * other.y,
    self.z * other.x - self.x * other.z,
    self.x * other.y - self.y * other.x)
end

---@param self coor3
---@param ...coor3
---@return coor3
local vecXyzAvg = function(self, ...)
    local pts = {...}
    return func.fold(pts, self, function(l, r) return l + r end) / (#pts + 1)
end

coor.xyzAvg = vecXyAvg

---comment
---@param x number
---@param y number
---@param z number
---@return coor3
function coor.xyz(x, y, z)
    local result = {
        x = x,
        y = y,
        z = z or 0,
        length = vecXyzLength,
        length2 = vecXyzLength2,
        normalized = vecXyzNormalized,
        toTuple = vecXyzToTuple,
        dot = vecXyzDot,
        cross = vecXyzCross,
        withZ = function(self, z) return coor.xyz(self.x, self.y, z) end,
        avg = vecXyzAvg
    }
    setmetatable(result, vecXyzMeta)
    return result
end

coor.o = coor.xyz(0, 0, 0)

---@param tuple any
---@return coor3
function coor.tuple2Vec(tuple)
    return coor.xyz(unpack(tuple))
end

---@param vec coor3
---@return table
function coor.vec2Tuple(vec)
    return {vec.x, vec.y, vec.z}
end

---@param edge table[]
---@return coor3
---@return coor3
function coor.edge2Vec(edge)
    local pt, vec = unpack(edge)
    return coor.tuple2Vec(pt), coor.tuple2Vec(vec)
end

---@param pt coor3
---@param vec coor3
---@return table[]
function coor.vec2Edge(pt, vec)
    return {pt:toTuple(), vec:toTuple()}
end

-- the original transf.mul is ill-formed. The matrix is in form of Y = X.A + b, but mul transposed the matrix for Y = A.X + b
---comment
---@param m1 matrix
---@param m2 matrix
---@return matrix
local function mul(m1, m2)
    local m = function(line, col)
        local l = (line - 1) * 4
        return m1[l + 1] * m2[col + 0] + m1[l + 2] * m2[col + 4] + m1[l + 3] * m2[col + 8] + m1[l + 4] * m2[col + 12]
    end
    return {
        m(1, 1), m(1, 2), m(1, 3), m(1, 4),
        m(2, 1), m(2, 2), m(2, 3), m(2, 4),
        m(3, 1), m(3, 2), m(3, 3), m(3, 4),
        m(4, 1), m(4, 2), m(4, 3), m(4, 4)
    }
end

function coor.minor(m)
    local seq = func.seq(1, #m)
    return function(row, col)
        local seqL = func.filter(seq, function(l) return l ~= row end)
        local seqC = func.filter(seq, function(c) return c ~= col end)
        return func.map(seqL, function(l)
            return func.map(seqC, function(c) return m[l][c] end)
        end)
    end
end

function coor.det(m)
    if #m == 2 then
        return m[1][1] * m[2][2] - m[1][2] * m[2][1]
    else if #m == 1 then
        return m[1][1]
    else
        local mi = coor.minor(m)
        return func.fold(func.seq(1, #m), 0, function(r, c) return r + (c % 2 == 1 and 1 or -1) * m[1][c] * coor.det(mi(1, c)) end)
    end
    end
end

---@param m matrix
---@return matrix
function coor.inv(m)
    local dX = coor.det(m)
    
    local miX = coor.minor(m)
    local mXI = {}
    
    for l = 1, 4 do
        for c = 1, 4 do
            insert(mXI, ((l + c) % 2 == 0 and 1 or -1) * coor.det(miX(c, l)) / dX)
        end
    end
    
    return coor.I() * mXI
end

function coor.inv3(m)
    local dX = coor.det(m)
    
    local miX = coor.minor(m)
    
    local mXI = {}
    for l = 1, 3 do
        for c = 1, 3 do
            insert(mXI, ((l + c) % 2 == 0 and 1 or -1) * coor.det(miX(c, l)) / dX)
        end
    end
    
    return mXI
end

function coor.decomposite(m)
    local vecTrans = coor.xyz(m[13], m[14], m[15])
    local sx = coor.xyz(m[1], m[2], m[3]):length()
    local sy = coor.xyz(m[5], m[6], m[7]):length()
    local sz = coor.xyz(m[9], m[10], m[11]):length()
    local mRot = {
        m[1] / sx, m[2] / sx, m[3] / sx, 0,
        m[5] / sy, m[6] / sy, m[7] / sy, 0,
        m[9] / sz, m[10] / sz, m[11] / sz, 0,
        0, 0, 0, 1
    }
    return vecTrans, coor.I() * mRot, coor.xyz(sx, sy, sz)
end

function coor.apply(vec, trans)
    local applyVal = function(col)
        return vec.x * trans[0 + col] + vec.y * trans[4 + col] + vec.z * trans[8 + col] + trans[12 + col]
    end
    return coor.xyz(applyVal(1), applyVal(2), applyVal(3))
end

function coor.applyEdge(mpt, mvec)
    return function(edge)
        local pt, vec = coor.edge2Vec(edge)
        local newPt = coor.apply(pt, mpt)
        local newVec = coor.apply(vec, mvec)
        return coor.vec2Edge(newPt, newVec)
    end
end

function coor.applyEdges(mpt, mvec)
    return function(edges)
        return func.map(edges, coor.applyEdge(mpt, mvec))
    end
end

---@type matrix
local init = {}

local meta = {
    __mul = function(lhs, rhs)
        local result = mul(lhs, rhs)
        setmetatable(result, getmetatable(lhs))
        return result
    end,
    __call = function(lhs, rhs)
        return coor.apply(rhs, lhs)
    end
}

setmetatable(init,
    {
        __mul = function(_, rhs)
            setmetatable(rhs, meta)
            return rhs
        end
    })

---comment
---@return matrix
function coor.I()
    return init * {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }
end

---@param rad number
---@return matrix
function coor.rotZ(rad)
    local sx = sin(rad)
    local cx = cos(rad)
    
    return init * {
        cx, sx, 0, 0,
        -sx, cx, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }
end

---@param rad number
---@return matrix
function coor.rotY(rad)
    local sx = sin(rad)
    local cx = cos(rad)
    
    return init * {
        cx, 0, sx, 0,
        0, 1, 0, 0,
        -sx, 0, cx, 0,
        0, 0, 0, 1
    }
end

---@param rad number
---@return matrix
function coor.rotX(rad)
    local sx = sin(rad)
    local cx = cos(rad)
    
    return init * {
        1, 0, 0, 0,
        0, cx, sx, 0,
        0, -sx, cx, 0,
        0, 0, 0, 1
    }
end

---@return matrix
function coor.xXY()
    return init * {
        0, 1, 0, 0,
        1, 0, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }
end


---@return matrix
function coor.xXZ()
    return init * {
        0, 0, 1, 0,
        0, 1, 0, 0,
        1, 0, 0, 0,
        0, 0, 0, 1
    }
end

---@return matrix
function coor.flipX()
    return init * {
        -1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }
end

---@return matrix
function coor.flipY()
    return init * {
        1, 0, 0, 0,
        0, -1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }
end

---@return matrix
function coor.flipZ()
    return init * {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, -1, 0,
        0, 0, 0, 1
    }
end

---@param vec coor3
---@return matrix
function coor.trans(vec)
    return init * {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        vec.x, vec.y, vec.z, 1
    }
end

---@param dx number
---@return matrix
function coor.transX(dx)
    return init * {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        dx, 0, 0, 1
    }
end

---@param dy number
---@return matrix
function coor.transY(dy)
    return init * {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, dy, 0, 1
    }
end

---@param dz number
---@return matrix
function coor.transZ(dz)
    return init * {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, dz, 1
    }
end

---@param sx number
---@return matrix
function coor.scaleX(sx)
    return init * {
        sx, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }
end


---@param sy number
---@return matrix
function coor.scaleY(sy)
    return init * {
        1, 0, 0, 0,
        0, sy, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }
end

---@param sz number
---@return matrix
function coor.scaleZ(sz)
    return init * {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, sz, 0,
        0, 0, 0, 1
    }
end

---@param vec coor3
---@return matrix
function coor.scale(vec)
    return coor.scaleX(vec.x) * coor.scaleY(vec.y) * coor.scaleZ(vec.z)
end

---@param s number
---@return matrix
function coor.shearXoY(s)
    return init * {
        1, 0, 0, 0,
        s, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }
end

---@param s number
---@return matrix
function coor.shearXoZ(s)
    return init * {
        1, 0, 0, 0,
        0, 1, 0, 0,
        s, 0, 1, 0,
        0, 0, 0, 1
    }
end

coor.rotZ90P = coor.rotZ(0.5 * math.pi)
coor.rotZ90N = coor.rotZ(-0.5 * math.pi)
coor.rotX90P = coor.rotX(0.5 * math.pi)
coor.rotX90N = coor.rotX(-0.5 * math.pi)
coor.rotY90P = coor.rotY(0.5 * math.pi)
coor.rotY90N = coor.rotY(-0.5 * math.pi)
coor.rotZ180 = coor.rotZ(math.pi)

---@param ...matrix
---@return matrix
function coor.mul(...)
    local params = {...}
    local m = params[1]
    for i = 2, #params do
        m = m * params[i]
    end
    return m
end

return coor
