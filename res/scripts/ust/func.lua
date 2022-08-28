--[[
Copyright (c) 2017 "Enzojz" from www.transportfever.net
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
local unpack = table.unpack
local func = {}

func.pi = require "ust/pipe"

---@generic T : any
---@generic S : any
---@param ls `S`[]
---@param init `T`
---@param fun fun(init: `T`, e: `S`) : T
---@return `T`
function func.fold(ls, init, fun)
    return func.pi.fold(init, fun)(ls)
end

---@generic T : any
---@param ls `T`[]
---@param fun fun(e: `T`)
function func.forEach(ls, fun)
    func.pi.forEach(fun)(ls)
end

---@generic T : any
---@generic S : any
---@param ls `T`[]
---@param fun fun(e: `T`): `S`
---@return `S`[]
function func.map(ls, fun)
    return func.pi.map(fun)(ls)
end

---@generic K : any
---@generic V : any
---@param ls table<`K`, `V`>
---@return `K`[]
function func.keys(ls)
    return func.pi.keys()(ls)
end

---@generic K : any
---@generic V : any
---@param ls table<`K`, `V`>
---@return `V`[]
function func.values(ls)
    return func.pi.values()(ls)
end

---@generic K : any
---@generic V : any
---@generic T : any
---@param fun fun(e: `V`, i?: `K`): `T`
---@param ls table<`K`, `V`>
---@return table<`K`, `T`>
function func.mapValues(ls, fun)
    return func.pi.mapValues(fun)(ls)
end

---@generic T : any
---@generic K : any
---@generic V : any
---@param fun fun(e: `T`): `K`, `V`
---@param ls `T`[]
---@return table<`K`, `T`>
function func.mapPair(ls, fun)
    return func.pi.mapPair(fun)(ls)
end

---@generic T : any
---@param pre fun(e: `T`): boolean
---@param ls `T`[]
---@return `T`[]
function func.filter(ls, pre)
    return func.pi.filter(pre)(ls)
end

---@generic T : any
---@param t1 `T`[]
---@param t2 `T`[]
---@return `T`[]
function func.concat(t1, t2)
    return func.pi.concat(t2)(t1)
end

---@generic T : any
---@param ls `T`[][]
---@return `T`[]
function func.flatten(ls)
    return func.pi.flatten()(ls)
end

---@generic T : any
---@generic S : any
---@param fun fun(e: `T`): `S`
---@param ls `T`[][]
---@return `S`[]
function func.mapFlatten(ls, fun)
    return func.pi.mapFlatten(fun)(ls)
end

---@generic T : any
---@generic S : any
---@generic X : any
---@param fun fun(e1: `T`, e2: `S`): `X`
---@param ls1 `T`[]
---@param ls2 `S`[]
---@return `X`[]
function func.map2(ls1, ls2, fun)
    return func.pi.map2(ls2, fun)(ls1)
end

function func.range(ls, from, to)
    return func.pi.range(from, to)(ls)
end

---@generic T : any
---@param less? fun(lhs: `T`, rhs: `T`): boolean
---@param ls `T`[]
---@return `T`
function func.max(ls, less)
    return func.pi.max(less)(ls)
end

---@generic T : any
---@param less? fun(lhs: `T`, rhs: `T`): boolean
---@param ls `T`[]
---@return `T`
function func.min(ls, less)
    return func.pi.min(less)(ls)
end

---@param newValues table
---@param ls table
---@return table
function func.with(ls, newValues)
    local newValue = func.pi.with(newValues)(ls)
    setmetatable(newValue, getmetatable(ls) or nil)
    return newValue
end

---@generic T : any
---@param fn? fun(lhs: `T`, rhs: `T`): boolean
---@param ls `T`[]
---@return `T`[]
function func.sort(ls, fn)
    return func.pi.sort(fn)(ls)
end

---@generic T : any
---@param ls `T`[]
---@return `T`[]
function func.rev(ls)
    return func.pi.rev()(ls)
end

---@generic T : any
---@param ls `T`[]
---@param e `T`
---@return boolean
function func.contains(ls, e)
    return func.pi.contains(e)(ls)
end

---@param from integer
---@param to integer
---@return integer[]
function func.seq(from, to)
    local result = {}
    for i = from, to do result[#result + 1] = i end
    return result
end

---@generic T : any
---@param ls `T`[]
---@param name? string[]
function func.interlace(ls, name)
    return func.pi.interlace(name)(ls)
end

---@generic T : any
---@generic S : any
---@param ls1 `T`[]
---@param ls2 `S`[]
---@param name? string[]
function func.zip(ls1, ls2, name)
    return func.pi.zip(ls2, name)(ls1)
end

---@generic T : any
---@param n integer
---@param value `T`
---@return `T`[]
function func.seqValue(n, value)
    return func.seqMap({1, n}, function(_) return value end)
end

---@generic T : any
---@param range {[1]: integer, [2]: integer}
---@param fun fun(integer): `T`
---@return `T`[]
function func.seqMap(range, fun)
    return func.map(func.seq(unpack(range)), fun)
end

func.p = func.pi.new

---@generic T : any
---@param x `T`
---@return `T`
func.nop = function(x) return x end

return func
