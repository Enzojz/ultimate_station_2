local func = require "ust/func"
local coor = require "ust/coor"
local arc = require "ust/coorarc"
local line = require "ust/coorline"
local quat = require "ust/quaternion"
local general = require "ust/general"
local pipe = require "ust/pipe"
-- local dump = require "luadump"
local ust = {}

local math = math
local pi = math.pi
local abs = math.abs
local ceil = math.ceil
local floor = math.floor
local unpack = table.unpack
local min = math.min

ust.infi = 1e8

ust.base = function(id, type)
    return id * 100 + type
end

ust.mixData = function(base, data)
        -- local data = data > 0 and data or (1000 - data)
        return (data < 0 and -base or base) + 1000000 * data
end

ust.slotIds = function(info)
    local base = info.type + info.id * 100
    return base, {
        posX = ust.mixData(ust.base(info.id, 51), info.pos.x),
        posY = ust.mixData(ust.base(info.id, 52), info.pos.y),
        posZ = ust.mixData(ust.base(info.id, 53), info.pos.z),
        radiusLow = info.radius and ust.mixData(ust.base(info.id, 54), info.radius > 0 and info.radius % 1000 or -(-info.radius % 1000)) or nil,
        radiusHigh = info.radius and ust.mixData(ust.base(info.id, 55), info.radius > 0 and math.floor(info.radius / 1000) or -(math.floor(-info.radius / 1000))) or nil,
        straight = info.straight and ust.mixData(ust.base(info.id, 56), 0) or nil,
        length = ust.mixData(ust.base(info.id, 57), info.length),
        width = ust.mixData(ust.base(info.id, 58), info.width)
    }
end

ust.slotInfo = function(slotId)
        -- Platform/track
        -- 1 ~ 2 : 01 : track 02 platform 03 placeholder
        -- 3 ~ 6 : id
        -- Component
        -- 1 ~ 2 : 20 reserved 21 underpass 22 overpass 23 entry 24 fences
        -- 3 ~ 6 : id
        -- Information
        -- 1 ~ 2 : 50 reserved 51 x 52 y 53 z 54 radius 56 is_straight 57 length 58 width
        -- 3 ~ 6 : id
        -- > 6: data
        local slotIdAbs = math.abs(slotId)
        local type = slotIdAbs % 100
        local id = (slotIdAbs - type) / 100 % 1000
        local data = slotId > 0 and floor(slotIdAbs / 1000000) or -floor(slotIdAbs / 1000000)
        
        return type, id, data
end

ust.arcPacker = function(pt, vec, length, radius)
    local nVec = vec:withZ(0):normalized()
    local tVec = coor.xyz(-nVec.y, nVec.x, 0)
    local o = pt + tVec * radius
    local ar = arc.byOR(o, abs(radius))
    local inf = ar:rad(pt)
    local sup = inf + length / radius
    ar = ar:withLimits({
        sup = sup,
        inf = inf
    })
    return function(...)
        local result = func.map({...}, function(dr)
            return arc.byOR(o, abs(radius + dr), {
                sup = sup,
                inf = inf
            })
        end)
        return ar, unpack(result)
    end
end

local function ungroup(fst, ...)
    local f = {...}
    return function(lst, ...)
        local l = {...}
        return function(result, c)
            if (fst and lst) then
                return ungroup(unpack(f))(unpack(l))(
                    result /
                    (
                    (fst[1] - lst[1]):length2() < (fst[1] - lst[#lst]):length2()
                    and (fst * pipe.range(2, #fst) * pipe.rev() + {fst[1]:avg(lst[1])} + lst * pipe.range(2, #lst))
                    or (fst * pipe.range(2, #fst) * pipe.rev() + {fst[1]:avg(lst[#lst])} + lst * pipe.rev() * pipe.range(2, #lst))
                    ),
                    floor((#fst + #lst) * 0.5)
            )
            else
                return result / c
            end
        end
    end
end

ust.assembleSize = function(lc, rc)
    return {
        lb = lc.i,
        lt = lc.s,
        rb = rc.i,
        rt = rc.s
    }
end

local function mul(m1, m2)
    local m = function(line, col)
        local l = (line - 1) * 3
        return m1[l + 1] * m2[col + 0] + m1[l + 2] * m2[col + 3] + m1[l + 3] * m2[col + 6]
    end
    return {
        m(1, 1), m(1, 2), m(1, 3),
        m(2, 1), m(2, 2), m(2, 3),
        m(3, 1), m(3, 2), m(3, 3),
    }
end

ust.fitModel2D = function(w, h, d, fitTop, fitLeft)
    local s = {
        {
            coor.xy(0, 0),
            coor.xy(fitLeft and w or -w, 0),
            coor.xy(0, fitTop and -h or h),
        },
        {
            coor.xy(0, 0),
            coor.xy(fitLeft and -w or w, 0),
            coor.xy(0, fitTop and h or -h),
        }
    }
    
    local mX = func.map(s,
        function(s) return {
            {s[1].x, s[1].y, 1},
            {s[2].x, s[2].y, 1},
            {s[3].x, s[3].y, 1},
        }
        end)
    
    local mXI = func.map(mX, coor.inv3)
    
    local fitTop = {fitTop, not fitTop}
    local fitLeft = {fitLeft, not fitLeft}
    
    return function(size, mode, z)
        local mXI = mXI[mode and 1 or 2]
        local fitTop = fitTop[mode and 1 or 2]
        local fitLeft = fitLeft[mode and 1 or 2]
        local refZ = size.lt.z
        
        local t = fitTop and
            {
                fitLeft and size.lt or size.rt,
                fitLeft and size.rt or size.lt,
                fitLeft and size.lb or size.rb,
            } or {
                fitLeft and size.lb or size.rb,
                fitLeft and size.rb or size.lb,
                fitLeft and size.lt or size.rt,
            }
        
        local mU = {
            t[1].x, t[1].y, 1,
            t[2].x, t[2].y, 1,
            t[3].x, t[3].y, 1,
        }
        
        local mXi = mul(mXI, mU)
        
        return coor.I() * {
            mXi[1], mXi[2], 0, mXi[3],
            mXi[4], mXi[5], 0, mXi[6],
            0, 0, 1, 0,
            mXi[7], mXi[8], 0, mXi[9]
        } * coor.scaleZ(z and (z / d) or 1) * coor.transZ(refZ)
    end
end

ust.fitModel = function(w, h, d, fitTop, fitLeft)
    local s = {
        {
            coor.xyz(0, 0, 0),
            coor.xyz(fitLeft and w or -w, 0, 0),
            coor.xyz(0, fitTop and -h or h, 0),
            coor.xyz(0, 0, d)
        },
        {
            coor.xyz(0, 0, 0),
            coor.xyz(fitLeft and -w or w, 0, 0),
            coor.xyz(0, fitTop and h or -h, 0),
            coor.xyz(0, 0, d)
        },
    }
    
    local mX = func.map(s, function(s)
        return {
            {s[1].x, s[1].y, s[1].z, 1},
            {s[2].x, s[2].y, s[2].z, 1},
            {s[3].x, s[3].y, s[3].z, 1},
            {s[4].x, s[4].y, s[4].z, 1}
        }
    end)
    
    local mXI = func.map(mX, coor.inv)
    
    local fitTop = {fitTop, not fitTop}
    local fitLeft = {fitLeft, not fitLeft}
    
    return function(size, mode, z)
        local z = z or d
        local mXI = mXI[mode and 1 or 2]
        local fitTop = fitTop[mode and 1 or 2]
        local fitLeft = fitLeft[mode and 1 or 2]
        local t = fitTop and
            {
                fitLeft and size.lt or size.rt,
                fitLeft and size.rt or size.lt,
                fitLeft and size.lb or size.rb,
            } or {
                fitLeft and size.lb or size.rb,
                fitLeft and size.rb or size.lb,
                fitLeft and size.lt or size.rt,
            }
        local mU = {
            t[1].x, t[1].y, t[1].z, 1,
            t[2].x, t[2].y, t[2].z, 1,
            t[3].x, t[3].y, t[3].z, 1,
            t[1].x, t[1].y, t[1].z + z, 1
        }
        
        return mXI * mU
    end
end

ust.interlace = pipe.interlace({"s", "i"})

ust.unitLane = function(f, t, tag, mdl) return
    ((t - f):length2() > 1e-2 and (t - f):length2() < 562500)
        and general.newModel(mdl or "ust/person_lane.mdl", tag, general.mRot(t - f), coor.trans(f))
        or nil
end

ust.stepLane = function(f, t, tag)
    local vec = t - f
    local length = vec:length()
    if (length > 750 or length < 0.1) then return {} end
    local dZ = abs((f - t).z)
    if (length > dZ * 3 or length < 5) then
        return {general.newModel("ust/person_lane.mdl", tag, general.mRot(vec), coor.trans(f))}
    else
        local hVec = vec:withZ(0) / 3
        local fi = f + hVec
        local ti = t - hVec
        return {
            general.newModel("ust/person_lane.mdl", tag, general.mRot(fi - f), coor.trans(f)),
            general.newModel("ust/person_lane.mdl", tag, general.mRot(ti - fi), coor.trans(fi)),
            general.newModel("ust/person_lane.mdl", tag, general.mRot(t - ti), coor.trans(ti))
        }
    end
end

ust.defaultParams = function(params)
    local defParams = params()
    return function(param)
        local function limiter(d, u)
            return function(v) return v and v < u and v or d end
        end
        param.trackType = param.trackType or 0
        param.catenary = param.catenary or 0
        
        func.forEach(
            func.filter(defParams, function(p) return p.key ~= "tramTrack" end),
            function(i)param[i.key] = limiter(i.defaultIndex or 0, #i.values)(param[i.key]) end)
        return param
    end
end

ust.terrain = function(config, ref)
    return pipe.mapn(
        ref.lc,
        ref.rc
    )(function(lc, rc)
        local size = ust.assembleSize(lc, rc)
        return pipe.new / size.lt / size.lb / size.rb / size.rt * pipe.map(coor.vec2Tuple)
    end)
end


function ust.posGen(restTrack, lst, snd, ...)
    if restTrack == 0 then
        if lst and snd then
            return {false, lst, snd, ...}
        else
            return {lst, snd, ...}
        end
    elseif lst == nil then
        return {}
    elseif snd == nil then
        if lst then
            return ust.posGen(restTrack, false, true)
        else
            return ust.posGen(restTrack - 1, true, false)
        end
    else
        if lst and snd then
            return ust.posGen(restTrack, false, lst, snd, ...)
        else
            return ust.posGen(restTrack - 1, true, lst, snd, ...)
        end
    end
end


local calculateLimit = function(arc)
    return function(l, ptvec)
        local pt = func.min(arc / l, function(lhs, rhs) return (lhs - ptvec[1]):length2() < (rhs - ptvec[1]):length2() end)
        return arc:rad(pt)
    end
end

ust.gridization = function(modules, classedModules)
    local lowestHeight = 2
    local grid = {}
    for id, info in pairs(classedModules) do
        local pos = modules[info.slotId].info.pos
        local x, y, z = pos.x, pos.y, pos.z
        if not grid[z] then grid[z] = {} end
        if not grid[z][x] then grid[z][x] = {} end
        grid[z][x][y] = info.slotId
    end
    
    for slotId, module in pairs(modules) do
        if module.metadata.isTrack or module.metadata.isPlatform or module.metadata.isPlaceholder then
            local info = module.info
            local x, y, z = info.pos.x, info.pos.y, info.pos.z
            
            if grid[z][x][y - 1] then
                modules[grid[z][x][y - 1]].info.octa[1] = slotId
                module.info.octa[5] = grid[z][x][y - 1]
            end
            
            if grid[z][x][y + 1] then
                modules[grid[z][x][y + 1]].info.octa[5] = slotId
                module.info.octa[1] = grid[z][x][y + 1]
            end
            
            if grid[z][x - 1] and grid[z][x - 1][y] then
                modules[grid[z][x - 1][y]].info.octa[3] = slotId
                module.info.octa[7] = grid[z][x - 1][y]
            end
            
            if grid[z][x + 1] and grid[z][x + 1][y] then
                modules[grid[z][x + 1][y]].info.octa[7] = slotId
                module.info.octa[3] = grid[z][x + 1][y]
            end
            
            if grid[z][x - 1] and grid[z][x - 1][y - 1] then
                modules[grid[z][x - 1][y - 1]].info.octa[2] = slotId
                module.info.octa[6] = grid[z][x - 1][y - 1]
            end
            
            if grid[z][x + 1] and grid[z][x + 1][y - 1] then
                modules[grid[z][x + 1][y - 1]].info.octa[8] = slotId
                module.info.octa[4] = grid[z][x + 1][y - 1]
            end
            
            if grid[z][x - 1] and grid[z][x - 1][y + 1] then
                modules[grid[z][x - 1][y + 1]].info.octa[4] = slotId
                module.info.octa[8] = grid[z][x - 1][y + 1]
            end
            
            if grid[z][x + 1] and grid[z][x + 1][y + 1] then
                modules[grid[z][x + 1][y + 1]].info.octa[6] = slotId
                module.info.octa[2] = grid[z][x + 1][y + 1]
            end
        end
    end
    
    for z, g in pairs(grid) do
        
        local queue = {}
        local parentMap = {}
        
        local enqueue = function(slotId, parent)
            if slotId and not parentMap[slotId] then
                table.insert(queue, slotId)
                parentMap[slotId] = parent
            end
        end
        
        local function searchMap(index)
            local current = queue[index]
            if (current) then
                local m = modules[current]
                local info = m.info
                local x, y = info.pos.x, info.pos.y
                if y >= 0 then
                    enqueue(info.octa[1], current)
                    enqueue(info.octa[5], current)
                else
                    enqueue(info.octa[5], current)
                    enqueue(info.octa[1], current)
                end
                if x >= 0 then
                    enqueue(info.octa[3], current)
                    enqueue(info.octa[7], current)
                else
                    enqueue(info.octa[7], current)
                    enqueue(info.octa[3], current)
                end
                searchMap(index + 1)
            end
        end
        
        enqueue(g[0][0], true)
        searchMap(1)
        
        local xPos = func.seq(0, func.max(func.keys(g)))
        local xNeg = func.seq(func.min(func.keys(g)), -1)
        
        local infoX = {
            pos = {[0] = 0},
            width = {}
        }
        do
            local xGroup = {}
            
            for _, x in ipairs(func.concat(xPos, func.rev(xNeg))) do
                local width = nil
                if grid[z][x] then
                    local yList = func.concat(
                        func.sort(func.filter(func.keys(grid[z][x]), function(k) return k >= 0 end)),
                        func.rev(func.sort(func.filter(func.keys(grid[z][x]), function(k) return k < 0 end)))
                    )
                    for _, y in ipairs(func.rev(yList)) do
                        local slotId = grid[z][x][y]
                        local m = modules[slotId]
                        local w = m.info.width or m.metadata.width
                        if not width or width < w then
                            width = w
                        end
                    end
                    
                    local sortedY = func.sort(yList)
                    for i, y in ipairs(sortedY) do
                        if xGroup[x] then
                            if y - sortedY[i - 1] == 1 then
                                table.insert(xGroup[x][#xGroup[x]], y)
                            else
                                table.insert(xGroup[x], {y})
                            end
                        else
                            xGroup[x] = {{y}}
                        end
                    end
                else
                    width = 5
                end
                
                if width then
                    infoX.width[x] = width
                    if x > 0 then
                        infoX.pos[x] = infoX.pos[x - 1] + infoX.width[x - 1] * 0.5 + width * 0.5
                    elseif x < 0 then
                        infoX.pos[x] = infoX.pos[x + 1] - infoX.width[x + 1] * 0.5 - width * 0.5
                    end
                end
            end
        end
        
        local processY = function(x, y)
            return function()
                local slotId = grid[z][x][y]
                local m = modules[slotId]
                
                if m.metadata.isTrack or m.metadata.isPlatform or m.metadata.isPlaceholder then
                    if not m.info.width then
                        m.info.width = m.metadata.width or 5
                    end
                    
                    if m.metadata.isTrack then
                        if m.metadata.height < lowestHeight then
                            lowestHeight = m.metadata.height
                        end
                    end
                    
                    local width = m.info.width
                    
                    local yState = {
                        width = width,
                        radius = m.info.straight and 10e8 or m.info.radius,
                        length = m.info.length
                    }
                    
                    local anchor = parentMap[slotId]
                    
                    if (anchor == m.info.octa[3] or anchor == m.info.octa[7]) then
                        local octa5 = m.info.octa[5] and modules[m.info.octa[5]]
                        local octa1 = m.info.octa[1] and modules[m.info.octa[1]]
                        if octa5 or octa1 then
                            if octa5 and octa5.info and octa5.info.pts and octa1 and octa1.info and octa1.info.pts then
                                anchor = m.info.octa[y >= 0 and 5 or 1]
                            elseif octa5 and octa5.info and octa5.info.pts then
                                anchor = m.info.octa[5]
                            elseif octa1 and octa1.info and octa1.info.pts then
                                anchor = m.info.octa[1]
                            end
                        end
                    end
                    
                    if x == 0 and y == 0 then
                        yState.pos = coor.xyz(infoX.pos[0], 0, 0)
                        yState.vec = coor.xyz(0, 1, 0)
                    else
                        if anchor == m.info.octa[5] then
                            yState.pos = modules[anchor].info.pts[4][1]
                            yState.vec = modules[anchor].info.pts[4][2]
                        elseif anchor == m.info.octa[1] then
                            yState.pos = modules[anchor].info.pts[3][1]
                            yState.vec = -modules[anchor].info.pts[3][2]
                        elseif anchor == m.info.octa[3] then
                            local pos = modules[anchor].info.pts[1][1]
                            local vec = modules[anchor].info.pts[1][2]
                            
                            yState.pos = pos + (vec:normalized() .. coor.rotZ((y < 0 and 0.5 or -0.5) * pi)) * (infoX.pos[x] - infoX.pos[x + 1])
                            yState.vec = vec
                        elseif anchor == m.info.octa[7] then
                            local pos = modules[anchor].info.pts[1][1]
                            local vec = modules[anchor].info.pts[1][2]
                            
                            yState.pos = pos + (vec:normalized() .. coor.rotZ((y < 0 and 0.5 or -0.5) * pi)) * (infoX.pos[x] - infoX.pos[x - 1])
                            yState.vec = vec
                        end
                    end
                    
                    if not yState.radius then
                        if anchor == m.info.octa[5] or anchor == m.info.octa[1] then
                            for i = y + (y < 0 and 1 or -1), 0, (y < 0 and 1 or -1) do
                                if grid[z][x] and grid[z][x][i] then
                                    yState.radius = modules[grid[z][x][i]].info.radius
                                    break
                                end
                            end
                        end
                        if not yState.radius then
                            local loop = {}
                            if m.metadata.isTrack or m.metadata.isPlaceholder then
                                loop = {x + (x < 0 and 1 or -1), (x < 0 and func.max(xPos) or func.min(xNeg) or 0), (x < 0 and 1 or -1)}
                            elseif m.metadata.isPlatform then
                                if (x < 0) then
                                    if m.info.octa[3] and m.info.octa[7] and modules[m.info.octa[3]].metadata.isPlatform and (modules[m.info.octa[7]].metadata.isTrack or modules[m.info.octa[7]].metadata.isPlaceholder) and modules[m.info.octa[7]].info.radius then
                                        loop = {x - 1, func.min(xNeg), -1}
                                    else
                                        loop = {x + 1, func.max(xPos) or 0, 1}
                                    end
                                else
                                    if m.info.octa[7] and m.info.octa[3] and modules[m.info.octa[7]].metadata.isPlatform and (modules[m.info.octa[3]].metadata.isTrack or modules[m.info.octa[7]].metadata.isPlaceholder) and modules[m.info.octa[3]].info.radius then
                                        loop = {x + 1, func.max(xPos), 1}
                                    else
                                        loop = {x - 1, func.min(xNeg) or 0, -1}
                                    end
                                end
                            end
                            for i = loop[1], loop[2], loop[3] do
                                if grid[z][i] and grid[z][i][y] then
                                    yState.radius = modules[grid[z][i][y]].info.radius + (infoX.pos[x] - infoX.pos[i])
                                    yState.radiusRef = i
                                    break
                                end
                            end
                        end
                        if not yState.radius then
                            yState.radius = 10e8
                        end
                    end
                    
                    modules[slotId].info.radius = yState.radius
                    modules[slotId].info.length = yState.length
                    
                    local packer = ust.arcPacker(yState.pos, yState.vec, yState.length, y < 0 and -yState.radius or yState.radius)
                    local ar, arL, arR = packer(-yState.width * 0.5, yState.width * 0.5)
                    if y < 0 then arL, arR = arR, arL end
                    
                    if x < 0 and m.info.octa[3] and (modules[m.info.octa[3]].metadata.isTrack or modules[m.info.octa[3]].metadata.isPlaceholder) then
                        if (y >= 0 and m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform)
                            or (y < 0 and m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform) then
                            local sup = modules[m.info.octa[3]].info.arcs.center.sup
                            arL.sup = sup
                            arR.sup = sup
                            ar.sup = sup
                        elseif (y >= 0 and m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform)
                            or (y < 0 and m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform) then
                            local inf = modules[m.info.octa[3]].info.arcs.center.inf
                            arL.inf = inf
                            arR.inf = inf
                            ar.inf = inf
                        end
                    elseif x >= 0 and m.info.octa[7] and (modules[m.info.octa[7]].metadata.isTrack or modules[m.info.octa[7]].metadata.isPlaceholder) then
                        if (y >= 0 and m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform)
                            or (y < 0 and m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform) then
                            local sup = modules[m.info.octa[7]].info.arcs.center.sup
                            arL.sup = sup
                            arR.sup = sup
                            ar.sup = sup
                        elseif (y >= 0 and m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform)
                            or (y < 0 and m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform) then
                            local inf = modules[m.info.octa[7]].info.arcs.center.inf
                            arL.inf = inf
                            arR.inf = inf
                            ar.inf = inf
                        end
                    end
                    
                    local refArc = {
                        left = arL,
                        right = arR,
                        center = ar
                    }
                    
                    modules[slotId].info.arcs = refArc
                    
                    modules[slotId].info.pts = {
                        {
                            refArc.center:pt(refArc.center.inf),
                            refArc.center:tangent(refArc.center.inf)
                        },
                        {
                            refArc.center:pt(refArc.center.sup),
                            refArc.center:tangent(refArc.center.sup)
                        }
                    }
                    
                    if y >= 0 then
                        modules[slotId].info.pts[3] = modules[slotId].info.pts[1]
                        modules[slotId].info.pts[4] = modules[slotId].info.pts[2]
                    else
                        modules[slotId].info.pts[3] = {
                            modules[slotId].info.pts[2][1],
                            -modules[slotId].info.pts[2][2]
                        }
                        modules[slotId].info.pts[4] = {
                            modules[slotId].info.pts[1][1],
                            -modules[slotId].info.pts[1][2]
                        }
                    end
                    
                    modules[slotId].info.limits = func.map(modules[slotId].info.pts, function(ptvec) return line.byVecPt(ptvec[2] .. coor.rotZ(0.5 * pi), ptvec[1]) end)
                    
                    if m.metadata.isPlatform then
                        coroutine.yield()
                        
                        local function findLeftTrack(slotId)
                            if not slotId or not modules[slotId] then
                                return nil
                            elseif (modules[slotId].metadata.isTrack or modules[slotId].metadata.isPlaceholder) then
                                return modules[slotId].info.pos
                            elseif modules[slotId].metadata.isPlatform then
                                return findLeftTrack(modules[slotId].info.octa[7])
                            else
                                return nil
                            end
                        end
                        
                        local function findRightTrack(slotId)
                            if not slotId or not modules[slotId] then
                                return nil
                            elseif (modules[slotId].metadata.isTrack or modules[slotId].metadata.isPlaceholder) then
                                return modules[slotId].info.pos
                            elseif modules[slotId].metadata.isPlatform then
                                return findRightTrack(modules[slotId].info.octa[3])
                            else
                                return nil
                            end
                        end
                        
                        local leftTrackPos = findLeftTrack(slotId)
                        local rightTrackPos = findRightTrack(slotId)
                        
                        local ref = {
                            left = (leftTrackPos and not rightTrackPos) or (leftTrackPos and rightTrackPos and leftTrackPos.x == x - 1 and rightTrackPos.x ~= x + 1),
                            right = (rightTrackPos and not leftTrackPos) or (leftTrackPos and rightTrackPos and leftTrackPos.x ~= x - 1 and rightTrackPos.x == x + 1),
                            leftRight = leftTrackPos and rightTrackPos and leftTrackPos.x == x - 1 and rightTrackPos.x == x + 1,
                        }
                        
                        if y >= 0 then
                            if (x >= 0) then
                                if (ref.left and not ref.right and leftTrackPos ~= x - 1) then
                                    if (m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform and modules[m.info.octa[5]].info.ref and modules[m.info.octa[5]].info.ref.right) then
                                        ref = {prev = true}
                                    end
                                end
                            else
                                if (ref.right and not ref.left and rightTrackPos ~= x + 1) then
                                    if (m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform and modules[m.info.octa[5]].info.ref and modules[m.info.octa[5]].info.ref.left) then
                                        ref = {prev = true}
                                    end
                                end
                            end
                        else
                            if (x >= 0) then
                                if (ref.left and not ref.right and leftTrackPos ~= x - 1) then
                                    if (m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform and modules[m.info.octa[1]].info.ref and modules[m.info.octa[1]].info.ref.right) then
                                        ref = {next = true}
                                    end
                                end
                            else
                                if (not ref.leftRight and m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform and modules[m.info.octa[1]].info.ref and modules[m.info.octa[1]].info.ref.leftRight) then
                                    ref = {next = true}
                                elseif (ref.right and not ref.left and rightTrackPos ~= x + 1) then
                                    if (m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform and modules[m.info.octa[1]].info.ref and modules[m.info.octa[1]].info.ref.left) then
                                        ref = {next = true}
                                    end
                                end
                            end
                        end
                        
                        modules[slotId].info.ref = ref
                        
                        local packer = ust.arcPacker(yState.pos, yState.vec, yState.length, y < 0 and -yState.radius or yState.radius)
                        local ar, arL, arR = packer(-yState.width * 0.5, yState.width * 0.5)
                        if y < 0 then arL, arR = arR, arL end
                        
                        local aligned = false;
                        
                        if ref.leftRight then
                            local leftTrack = modules[grid[z][leftTrackPos.x][y]]
                            local leftO = leftTrack.info.arcs.center.o
                            local leftRadius = leftTrack.info.radius + (infoX.pos[x] - infoX.pos[leftTrackPos.x])
                            arL = arc.byOR(leftO, leftRadius - m.info.width * 0.5, leftTrack.info.arcs.center:limits())
                            
                            local rightTrack = modules[grid[z][rightTrackPos.x][y]]
                            local rightO = rightTrack.info.arcs.center.o
                            local rightRadius = rightTrack.info.radius + (infoX.pos[x] - infoX.pos[rightTrackPos.x])
                            arR = arc.byOR(rightO, rightRadius + m.info.width * 0.5, rightTrack.info.arcs.center:limits())
                            
                            local sup = leftTrack.info.pts[2][1]:avg(rightTrack.info.pts[2][1])
                            
                            local vecSupL = (leftTrack.info.radius > 0 and (leftTrack.info.pts[2][1] - arL.o) or (arL.o - leftTrack.info.pts[2][1])):normalized()
                            local vecSupR = (rightTrack.info.radius > 0 and (rightTrack.info.pts[2][1] - arR.o) or (arR.o - rightTrack.info.pts[2][1])):normalized()
                            local vecSup = (vecSupL + vecSupR):normalized()
                            local limitSup = line.byVecPt(vecSup, sup)
                            
                            supL = calculateLimit(arL)(limitSup, leftTrack.info.pts[2])
                            supR = calculateLimit(arR)(limitSup, rightTrack.info.pts[2])
                            
                            local infL = arL:rad(yState.pos)
                            if (y == 0 or y == -1) then
                                infL = leftTrack.info.arcs.center.inf
                            elseif (y > 0 and m.info.octa[5]) then
                                infL = arL:rad(modules[m.info.octa[5]].info.pts[2][1])
                            elseif (y < 0 and m.info.octa[1]) then
                                infL = arL:rad(modules[m.info.octa[1]].info.pts[2][1])
                            end
                            
                            local infR = arR:rad(yState.pos)
                            if (y == 0 or y == -1) then
                                infR = rightTrack.info.arcs.center.inf
                            elseif (y > 0 and m.info.octa[5]) then
                                infR = arR:rad(modules[m.info.octa[5]].info.pts[2][1])
                            elseif (y < 0 and m.info.octa[1]) then
                                infR = arR:rad(modules[m.info.octa[1]].info.pts[2][1])
                            end
                            
                            arL = arL:withLimits({sup = supL, inf = infL})
                            arR = arR:withLimits({sup = supR, inf = infR})
                            aligned = true
                        elseif ref.left then
                            local leftTrack = modules[grid[z][leftTrackPos.x][y]]
                            local leftO = leftTrack.info.arcs.center.o
                            local leftRadius = leftTrack.info.radius + (infoX.pos[x] - infoX.pos[leftTrackPos.x])
                            arL = arc.byOR(leftO, leftRadius - m.info.width * 0.5, leftTrack.info.arcs.center:limits())
                            arR = arc.byOR(leftO, leftRadius + m.info.width * 0.5, leftTrack.info.arcs.center:limits())
                            
                            local limitSup = leftTrack.info.limits[2]
                            local supL = calculateLimit(arL)(limitSup, leftTrack.info.pts[2])
                            local supR = calculateLimit(arR)(limitSup, leftTrack.info.pts[2])
                            
                            local inf = arL:rad(yState.pos)
                            if (y == 0 or y == -1) then
                                inf = leftTrack.info.arcs.center.inf
                            elseif (y > 0 and m.info.octa[5]) then
                                inf = arL:rad(modules[m.info.octa[5]].info.pts[2][1])
                            elseif (y < 0 and m.info.octa[1]) then
                                inf = arL:rad(modules[m.info.octa[1]].info.pts[2][1])
                            end
                            
                            arL = arL:withLimits({sup = supL, inf = inf})
                            arR = arR:withLimits({sup = supR, inf = inf})
                            aligned = true
                        elseif ref.right then
                            local rightTrack = modules[grid[z][rightTrackPos.x][y]]
                            local rightO = rightTrack.info.arcs.center.o
                            local rightRadius = rightTrack.info.radius + (infoX.pos[x] - infoX.pos[rightTrackPos.x])
                            arL = arc.byOR(rightO, rightRadius - m.info.width * 0.5, rightTrack.info.arcs.center:limits())
                            arR = arc.byOR(rightO, rightRadius + m.info.width * 0.5, rightTrack.info.arcs.center:limits())
                            
                            local limitSup = rightTrack.info.limits[2]
                            local supL = calculateLimit(arL)(limitSup, rightTrack.info.pts[2])
                            local supR = calculateLimit(arR)(limitSup, rightTrack.info.pts[2])
                            
                            local inf = arL:rad(yState.pos)
                            if (y == 0 or y == -1) then
                                inf = rightTrack.info.arcs.center.inf
                            elseif (y > 0 and m.info.octa[5]) then
                                inf = arL:rad(modules[m.info.octa[5]].info.pts[2][1])
                            elseif (y < 0 and m.info.octa[1]) then
                                inf = arL:rad(modules[m.info.octa[1]].info.pts[2][1])
                            end
                            
                            arL = arL:withLimits({sup = supL, inf = inf})
                            arR = arR:withLimits({sup = supR, inf = inf})
                            aligned = true
                        elseif ref.prev then
                            local arcs = modules[m.info.octa[5]].info.arcs
                            
                            arL = arc.byOR(arcs.left.o, arcs.left.r, arcs.left:limits())
                            arR = arc.byOR(arcs.right.o, arcs.right.r, arcs.right:limits())
                            
                            arL = arL:withLimits({
                                inf = arL.sup,
                                sup = arL.sup + arL.sup - arL.inf
                            })
                            
                            arR = arR:withLimits({
                                inf = arR.sup,
                                sup = arR.sup - arR.inf + arR.sup
                            })
                            
                            aligned = true
                        elseif ref.next then
                            local arcs = modules[m.info.octa[1]].info.arcs
                            
                            arL = arc.byOR(arcs.left.o, arcs.left.r, arcs.left:limits())
                            arR = arc.byOR(arcs.right.o, arcs.right.r, arcs.right:limits())
                            
                            arL = arL:withLimits({
                                inf = arL.sup,
                                sup = arL.sup + arL.sup - arL.inf
                            })
                            
                            arR = arR:withLimits({
                                inf = arR.sup,
                                sup = arR.sup - arR.inf + arR.sup
                            })
                            
                            aligned = true
                        end
                        
                        if aligned then
                            local pts = {
                                arL:pt(arL.inf):avg(arR:pt(arR.inf)),
                                nil,
                                arL:pt(arL.sup):avg(arR:pt(arR.sup))
                            }
                            pts[2] = arL:ptByPt(pts[1]:avg(pts[3])):avg(arR:ptByPt(pts[1]:avg(pts[3])))
                            local midPts = {
                                pts[1]:avg(pts[2]),
                                pts[3]:avg(pts[2])
                            }
                            
                            local lines = {
                                line.pend(line.byPtPt(pts[1], pts[2]), midPts[1]),
                                line.pend(line.byPtPt(pts[3], pts[2]), midPts[2]),
                            }
                            
                            local o = lines[1] - lines[2]
                            if not o then
                                local halfChordLength2 = (pts[3] - pts[1]):length2() * 0.25
                                local normalLength = math.sqrt(10e8 * 10e8 - halfChordLength2)
                                local midPt = pts[1]:avg(pts[3])
                                o = midPt + ((pts[3] - pts[1]):normalized() .. coor.rotZ(0.5 * pi)) * normalLength
                                r = 10e8
                            end
                            
                            o = o:withZ(0)
                            
                            local vecInf = pts[1] - o
                            local vecSup = pts[3] - o
                            
                            local r = vecInf:length()
                            if r > 10e8 then
                                local halfChordLength2 = (pts[3] - pts[1]):length2() * 0.25
                                local normalLength = math.sqrt(10e8 * 10e8 - halfChordLength2)
                                o = pts[1]:avg(pts[3]) + (o - pts[2]):normalized() * normalLength
                                vecInf = pts[1] - o
                                vecSup = pts[3] - o
                                r = 10e8
                            end
                            ar = arc.byOR(o, r)
                            
                            local inf = ar:rad(pts[1])
                            
                            local length = math.asin(vecInf:cross(vecSup).z / (r * r)) * r
                            local sup = inf + length / r
                            ar = ar:withLimits({
                                sup = sup,
                                inf = inf
                            })
                            modules[slotId].info.radius = (length > 0 and 1 or -1) * (y < 0 and -1 or 1) * r
                            modules[slotId].info.length = math.abs(length)
                        end
                        
                        local refArc = {
                            left = arL,
                            right = arR,
                            center = ar
                        }
                        
                        modules[slotId].info.arcs = refArc
                        modules[slotId].info.pts = {
                            {
                                refArc.center:pt(refArc.center.inf),
                                refArc.center:tangent(refArc.center.inf)
                            },
                            {
                                refArc.center:pt(refArc.center.sup),
                                refArc.center:tangent(refArc.center.sup)
                            }
                        }
                        
                        if y >= 0 then
                            modules[slotId].info.pts[3] = modules[slotId].info.pts[1]
                            modules[slotId].info.pts[4] = modules[slotId].info.pts[2]
                        else
                            modules[slotId].info.pts[3] = {
                                modules[slotId].info.pts[2][1],
                                -modules[slotId].info.pts[2][2]
                            }
                            modules[slotId].info.pts[4] = {
                                modules[slotId].info.pts[1][1],
                                -modules[slotId].info.pts[1][2]
                            }
                        end
                    
                    else
                        coroutine.yield()
                    end
                    
                    local gravity = {
                        refArc.center:pt((refArc.center.inf + refArc.center.sup) * 0.5),
                        refArc.center:tangent((refArc.center.inf + refArc.center.sup) * 0.5)
                    }
                    
                    modules[slotId].info.transf =
                        quat.byVec(coor.xyz(0, y < 0 and -1 or 1, 0), gravity[2]):mRot() *
                        coor.trans(gravity[1])
                    
                    modules[slotId].info.gravity = gravity
                end
            end
        end
        
        local cr = {}
        
        for _, current in ipairs(queue) do
            local pos = modules[current].info.pos
            cr[current] = coroutine.create(processY(pos.x, pos.y))
        end
        
        for _, current in ipairs(func.concat(queue, queue)) do
            local result = coroutine.resume(cr[current])
            if not result then
                print(debug.traceback(cr[current]))
            end
        end
    end
    return grid, lowestHeight
end

ust.basePts = function(arc, n)
    local radDelta = (arc.sup - arc.inf) / n
    local rads = func.map(func.seq(0, n), function(i) return arc.inf + i * radDelta end)
    local pts = func.map(rads, function(rad) return arc:pt(rad) end)
    local vecs = func.map(rads, function(rad) return arc:tangent(rad) end)
    return pts, vecs
end

ust.initSlotGrid = function(params, pos)
    if not params.slotGrid[pos.z] then params.slotGrid[pos.z] = {} end
    if not params.slotGrid[pos.z][pos.x] then params.slotGrid[pos.z][pos.x] = {} end
    if not params.slotGrid[pos.z][pos.x][pos.y] then params.slotGrid[pos.z][pos.x][pos.y] = {} end
    if not params.slotGrid[pos.z][pos.x - 1] then params.slotGrid[pos.z][pos.x - 1] = {} end
    if not params.slotGrid[pos.z][pos.x + 1] then params.slotGrid[pos.z][pos.x + 1] = {} end
    if not params.slotGrid[pos.z][pos.x - 1][pos.y] then params.slotGrid[pos.z][pos.x - 1][pos.y] = {} end
    if not params.slotGrid[pos.z][pos.x + 1][pos.y] then params.slotGrid[pos.z][pos.x + 1][pos.y] = {} end
    if not params.slotGrid[pos.z][pos.x][pos.y - 1] then params.slotGrid[pos.z][pos.x][pos.y - 1] = {} end
    if not params.slotGrid[pos.z][pos.x][pos.y + 1] then params.slotGrid[pos.z][pos.x][pos.y + 1] = {} end
end

ust.newTopologySlots = function(params, makeData, pos)
    return function(x, y, transf, octa)
        params.slotGrid[pos.z][x][y].track = {
            id = makeData(1, octa),
            transf = transf,
            type = "ust_track",
            spacing = {0, 0, 0, 0}
        }
        params.slotGrid[pos.z][x][y].platform = {
            id = makeData(2, octa),
            transf = transf,
            type = "ust_platform",
            spacing = {0, 0, 0, 0}
        }
        params.slotGrid[pos.z][x][y].placeholder = {
            id = makeData(3, octa),
            transf = transf,
            type = "ust_placeholder",
            spacing = {0, 0, 0, 0}
        }
    end
end

ust.getTranfs = function(info, pos, width)
    local refArc = info.arcs.center
    if pos == 1 then
        local fwPt = refArc.sup + 0.5 * (refArc.sup - refArc.inf)
        return quat.byVec(coor.xyz(0, 1, 0), refArc:tangent(fwPt)):mRot() * coor.trans(refArc:pt(fwPt))
    elseif pos == 3 then
        local pt = 0.5 * (refArc.sup + refArc.inf)
        local transf = quat.byVec(coor.xyz(0, info.pos.y < 0 and -1 or 1, 0), refArc:tangent(pt)):mRot() * coor.trans(refArc:pt(pt))
        return coor.trans(coor.xyz(width, 0, 0)) * transf
    elseif pos == 5 then
        local bwPt = refArc.inf - 0.5 * (refArc.sup - refArc.inf)
        return quat.byVec(coor.xyz(0, -1, 0), refArc:tangent(bwPt)):mRot() * coor.trans(refArc:pt(bwPt))
    elseif pos == 7 then
        local pt = 0.5 * (refArc.sup + refArc.inf)
        local transf = quat.byVec(coor.xyz(0, info.pos.y < 0 and -1 or 1, 0), refArc:tangent(pt)):mRot() * coor.trans(refArc:pt(pt))
        return coor.trans(coor.xyz(-width, 0, 0)) * transf
    else
        local pt = 0.5 * (refArc.sup + refArc.inf)
        return quat.byVec(coor.xyz(0, 1, 0), refArc:tangent(pt)):mRot() * coor.trans(refArc:pt(pt))
    end
end


ust.classifyComp = function(modules, classified, slotId)
    local type, id, data = ust.slotInfo(slotId)
    
    modules[slotId].info = {
        data = data,
        type = type,
        slotId = slotId,
        id = id
    }

    modules[classified[id].slotId].info.comp[type] = true
end

ust.classifyData = function(modules, classified, slotId)
    local type, id, data = ust.slotInfo(slotId)
    
    classified[id].slot[type] = slotId
    classified[id].info[type] = data
    classified[id].metadata[type] = modules[slotId].metadata
    
    modules[slotId].info = {
        data = data,
        type = type,
        slotId = slotId,
        id = id
    }
    
    modules[slotId].makeData = function(type, data)
        return ust.mixData(ust.base(id, type), data)
    end
end

ust.preClassify = function(modules, classified, slotId)
    local type, id, data = ust.slotInfo(slotId)
    
    classified[id] = {
        type = type,
        id = id,
        slotId = slotId,
        data = data,
        info = {},
        slot = {},
        metadata = {}
    }
    
    modules[slotId].info = {
        type = type,
        id = id,
        slotId = slotId,
        data = data,
        octa = {false, false, false, false, false, false, false, false},
        comp = {}
    }
    
    modules[slotId].makeData = function(type, data)
        return ust.mixData(ust.base(id, type), data)
    end
end


ust.postClassify = function(modules, classified, slotId)
    local id = modules[slotId].info.id
    
    local info = classified[id].info
    local x = info[51]
    local y = info[52]
    local z = info[53] or 0
    local radius = (info[54] or 0) + (info[55] or 0) * 1000
    local straight = info[56] and true or nil
    local length = info[57] or 20
    local width = info[58]
    local canModifyRadius = info[80] and true or false
    -- local data = classedModules[id].data
    if straight or radius == 0 then
        radius = nil
    end
    
    modules[slotId].info.pos = coor.xyz(x, y, z)
    modules[slotId].info.radius = radius
    modules[slotId].info.straight = straight
    modules[slotId].info.length = length
    modules[slotId].info.width = width
    modules[slotId].info.canModifyRadius = canModifyRadius
    
end

return ust
