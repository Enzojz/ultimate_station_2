--[[
Copyright (c) 2016 "Enzojz" from www.transportfever.net
(https://www.transportfever.net/index.php/User/27218-Enzojz/)

Github reposistey:
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
WHETHER IN AN ACTION OF CONTRACT, steT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--]]

---@class quaternion
---@field w number
---@field x number
---@field y number
---@field z number
---@field length fun(self: quaternion): number
---@field length2 fun(self: quaternion): number
---@field normalized fun(self: quaternion): quaternion
---@field mRot fun(self: quaternion): matrix
---@field inv fun(self: quaternion) : quaternion
---@field conj fun(self: quaternion) : quaternion
---@field cross fun(lhs: quaternion, rhs: quaternion) : quaternion
---@operator add(quaternion) : quaternion
---@operator sub(quaternion) : quaternion
---@operator mul(number) : quaternion
---@operator div(number) : quaternion
---@operator unm : quaternion

local coor = require "ust/coor"
local quaternion = {}

local math = math
local sqrt = math.sqrt

---comment
---@param self quaternion
---@return number
local qLength = function(self) return sqrt(self:length2()) end
---comment
---@param self quaternion
---@return number
local qLength2 = function(self) return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w end

---comment
---@param self quaternion
---@return quaternion
local qNormalized = function(self) return self:length2() == 0 and self or (self / self:length()) end

---comment
---@param q quaternion
---@return matrix
local qMRot = function(q)
    return coor.I() * {
        1 - 2 * q.y * q.y - 2 * q.z * q.z,     2 * q.x * q.y + 2 * q.w * q.z,     2 * q.x * q.z - 2 * q.w * q.y,     0,
        2 * q.x * q.y - 2 * q.w * q.z,         1 - 2 * q.x * q.x - 2 * q.z * q.z, 2 * q.y * q.z + 2 * q.w * q.x,     0,
        2 * q.x * q.z + 2 * q.w * q.y,         2 * q.y * q.z - 2 * q.w * q.x,     1 - 2 * q.x * q.x - 2* q.y * q.y,  0,
        0,                                     0,                                 0,                                 1
    }
end

---comment
---@param qu quaternion
---@return quaternion
local qConj = function(qu)
    return quaternion.wxyz(qu.w, -qu.x, -qu.y, -qu.z)
end

---comment
---@param q quaternion
---@return quaternion
local qInv = function(q)
    return q:conj() / q:length2()
end

---comment
---@param p quaternion
---@param q quaternion
---@return quaternion
local qCross = function(p, q)
    return quaternion.wxyz(
        p.w * q.w - p.x * q.x - p.y * q.y - p.z * q.z,
        p.w * q.x + p.x * q.w + p.y * q.z - p.z * q.y,
        p.w * q.y + p.y * q.w + p.z * q.x - p.x * q.z,
        p.w * q.z + p.z * q.w + p.x * q.y - p.y * q.x
    )
end

local qMeta = {
    __add = function(lhs, rhs)
        return quaternion.wxyz(lhs.w + rhs.w, lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    end
    ,
    __sub = function(lhs, rhs)
        return quaternion.wxyz(lhs.w - rhs.w, lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    end,
    __mul = function(lhs, rhs)
        return quaternion.wxyz(lhs.w * rhs, lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    end,
    __div = function(lhs, rhs)
        return quaternion.wxyz(lhs.w / rhs, lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    end,
    __unm = function(lhs)
        return quaternion.wxyz(-lhs.w, -lhs.x, -lhs.y, -lhs.z)
    end
}

function quaternion.wxyz(w, x, y, z)
    local result = {
        w = w,
        x = x,
        y = y,
        z = z,
        length = qLength,
        length2 = qLength2,
        normalized = qNormalized,
        mRot = qMRot,
        inv = qInv,
        conj = qConj,
        cross = qCross
    }
    setmetatable(result, qMeta)
    return result
end

---@param pt coor3
---@param w number
---@return quaternion
function quaternion.xyzw(pt, w)
    return quaternion.wxyz(w, pt.x, pt.y, pt.z)
end

---@param vec1 coor3
---@param vec2 coor3
---@return quaternion
function quaternion.byVec(vec1, vec2)
    local cr = vec1:cross(vec2)
    return quaternion.xyzw(cr, sqrt(vec1:length2() * vec2:length2()) + vec1:dot(vec2)):normalized()
end

return quaternion