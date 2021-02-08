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
local pipe = {}
local unpack = table.unpack

function pipe.fold(init, fun)
    return function(ls)
        for i = 1, #ls do init = fun(init, ls[i]) end
        return init
    end
end

function pipe.forEach(fun)
    return function(ls)
        for i = 1, #ls do fun(ls[i]) end
    end
end

function pipe.map(fun)
    return function(ls)
        local result = {}
        for i = 1, #ls do result[i] = fun(ls[i], i) end
        return result
    end
end

function pipe.keys()
    return function(ls)
        local result = {}
        for k, _ in pairs(ls) do result[#result + 1] = k end
        return result
    end
end


function pipe.values()
    return function(ls)
        local result = {}
        for i, e in pairs(ls) do result[#result + 1] = e end
        return result
    end
end

function pipe.mapValues(fun)
    return function(ls)
        local result = {}
        for i, e in pairs(ls) do result[i] = fun(e, i) end
        return result
    end
end

function pipe.mapPair(fun)
    return function(ls)
        local result = {}
        for i = 1, #ls do
            local k, v = fun(ls[i])
            result[k] = v
        end
        return result
    end
end

function pipe.filter(pre)
    return function(ls)
        local result = {}
        for i = 1, #ls do
            if (pre(ls[i])) then
                result[#result + 1] = ls[i]
            end
        end
        return result
    end
end

function pipe.concat(t2)
    return function(t1)
        local result = {}
        for i = 1, #t1 do result[#result + 1] = t1[i] end
        for i = 1, #t2 do result[#result + 1] = t2[i] end
        return result
    end
end

function pipe.flatten()
    return function(ls)
        local result = {}
        for i = 1, #ls do result = pipe.concat(ls[i])(result) end
        return result
    end
end

function pipe.mapFlatten(fun)
    return function(ls)
        return pipe.flatten()(pipe.map(fun)(ls))
    end
end

function pipe.map2(ls2, fun)
    return function(ls1)
        local result = {}
        for i = 1, #ls1 do result[i] = fun(ls1[i], ls2[i]) end
        return result
    end
end

function pipe.mapn(...)
    local ls = pipe.new * {...}
    return function(fun)
        local result = {}
        for i = 1, #ls[1] do
            local params = ls * pipe.map(pipe.select(i)) 
            result[i] = fun(unpack(params))
        end
        return result
    end
end

function pipe.mapx(...)
    local ls = pipe.new * {...}
    return function(fun)
        return function(l)
            local result = {}
            for i = 1, #l do
                local params = ls * pipe.map(pipe.select(i)) 
                result[i] = fun(l[i], unpack(params))
            end
            return result
        end
    end
end


function pipe.range(from, to)
    return function(ls)
        local result = {}
        for i = from, to do result[#result + 1] = ls[i] end
        return result
    end
end

function pipe.contains(e)
    return function(ls)
        for i = 1, #ls do if (ls[i] == e) then return true end end
        return false
    end
end

function pipe.max(less)
    local less = less or (function(x, y) return x < y end)
    return function(ls)
        return pipe.fold(ls[1], function(l, r) return less(l, r) and r or l end)(ls)
    end
end

function pipe.min(less)
    local less = less or (function(x, y) return x < y end)
    return function(ls)
        return pipe.fold(ls[1], function(l, r) return less(l, r) and l or r end)(ls)
    end
end

function pipe.with(newValues)
    return function(ls)
        local result = {}
        for i, e in pairs(ls) do result[i] = e end
        for i, e in pairs(newValues) do result[i] = e end
        return result
    end
end

function pipe.sort(fn)
    return function(ls)
        local result = pipe.with({})(ls)
        table.sort(result, fn)
        return result
    end
end

function pipe.rev()
    return function(ls)
        local result = {}
        for i = #ls, 1, -1 do
            table.insert(result, ls[i])
        end
        return result
    end
end

function pipe.plus(n)
    return function(e)
        return e + n
    end
end

function pipe.mul(n)
    return function(e)
        return e * n
    end
end

function pipe.neg()
    return function(e)
        return -e
    end
end

function pipe.zip(ls2, name)
    name = name or {1, 2}
    return function(ls1)
        local result = {}
        for i = 1, #ls1 do result[i] = {[name[1]] = ls1[i], [name[2]] = ls2[i]} end
        return result
    end
end

function pipe.rep(n)
    return function(content)
        local result = {}
        for i = 1, n do result[i] = content end
        return result
    end
end

function pipe.select(name, def)
    return function(el)
        return (el[name] == nil) and def or el[name]
    end
end

function pipe.noop()
    return function(x)
        return x
    end
end

function pipe.interlace(name)
    name = name or {1, 2}
    return function(ls)
        local result = {}
        for i = 1, #ls - 1 do result[i] = {[name[1]] = ls[i], [name[2]] = ls[i + 1]} end
        return result
    end
end

local pipeMeta = {
    __mul = function(lhs, rhs)
        local result = rhs(lhs)
        if (type(result) == "table" and not getmetatable(result)) then setmetatable(result, getmetatable(lhs)) end
        return result
    end
    ,
    __add = function(lhs, rhs)
        local result = pipe.concat(rhs)(lhs)
        setmetatable(result, getmetatable(lhs))
        return result
    end,
    __div = function(lhs, rhs)
        local result = pipe.concat({rhs})(lhs)
        setmetatable(result, getmetatable(lhs))
        return result
    end
    ,
    __call = function(r)
        return setmetatable(r, nil)
    end
}

pipe.new = {}
setmetatable(pipe.new,
    {
        __mul = function(_, rhs)
            setmetatable(rhs, pipeMeta)
            return rhs
        end,
        __add = function(_, rhs)
            setmetatable(rhs, pipeMeta)
            return rhs
        end,
        __div = function(_, rhs)
            local result = {rhs}
            setmetatable(result, pipeMeta)
            return result
        end
    }
)
pipe.from = function(...)
    local retVal = {...}
    setmetatable(retVal,
        {
            __mul = function(lhs, rhs)
                local result = rhs(unpack(lhs))
                setmetatable(result, pipeMeta)
                return result
            end,
            __add = function(lhs, rhs)
                local result = pipe.concat(rhs)(lhs)
                setmetatable(result, pipeMeta)
                return result
            end,
        })
    return retVal
end

pipe.exec = {}
setmetatable(pipe.exec,
    {
        __mul = function(_, rhs)
            return rhs()
        end
    }
)
return pipe
