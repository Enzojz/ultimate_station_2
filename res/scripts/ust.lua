local func = require "ust/func"
local pipe = require "ust/pipe"
local coor = require "ust/coor"
local arc = require "ust/coorarc"
local quat = require "ust/quaternion"
local ust = require "ust_gridization"
local livetext = require "ust/livetext"
-- local dump = require "luadump"

local math = math
local abs = math.abs
local floor = math.floor
local unpack = table.unpack

local insert = table.insert

ust.infi = 1e8

---@alias id integer
---@alias slotid integer
---@alias slottype integer
---@alias slotbase integer
---
---@class slotinfo
---@field type slottype
---@field id id
---@field slotId slotid
---@field data integer
---@field pos coor3
---@field radius number
---@field straight boolean
---@field length number
---@field extraHeight number
---@field width number
---@field ref {left: boolean, right: boolean, prev:boolean, next: boolean}
---@field octa (boolean|integer)[]
---@field comp table<integer, boolean>
---@field compList table<integer, table<integer>>
---@field arcs {left: arc, right:arc, center:arc}
---@field pts {[1]: {[1]:coor3, [2]: coor3}, [2]: {[1]:coor3, [2]: coor3}}
---@field refPos coor3
---
---@class projection_size
---@field lb coor3
---@field lt coor3
---@field rb coor3
---@field rt coor3
---
---@class module
---@field name string
---@field variant integer
---@field info slotinfo
---@field metadata table
---@field makeData fun(type: slottype, data: integer): slotid
---
---@alias modules table<integer, module>
---
---@class classified
---@field slotId slotid
---@field type slottype
---@field id id
---@field data integer
---@field info any[]
---@field slot any[]
---@field metadata table
---
---@alias classified_modules table<integer, classified>
---@param id id
---@param type slottype
---@return slotbase
ust.base = function(id, type)
    return id * 100 + type
end

---@param base slotbase
---@param data integer
---@return slotid
ust.mixData = function(base, data)
        -- local data = data > 0 and data or (1000 - data)
        return (data < 0 and -base or base) + 1000000 * data
end

---@param info slotinfo
---@return slotbase
---@return { data_pos: slotid[], data_radius: slotid[], data_geometry: slotid[], data_ref: slotid[] }
ust.slotIds = function(info)
    local base = info.type + info.id * 100
    
    return base, {
        pos = {
            ust.mixData(ust.base(info.id, 51), info.pos.x),
            ust.mixData(ust.base(info.id, 52), info.pos.y),
            ust.mixData(ust.base(info.id, 53), info.pos.z)
        },
        radius = info.radius and {
            ust.mixData(ust.base(info.id, 54), info.radius > 0 and info.radius % 1000 or -(-info.radius % 1000)),
            ust.mixData(ust.base(info.id, 55), info.radius > 0 and math.floor(info.radius / 1000) or -(math.floor(-info.radius / 1000))),
        } or info.straight and {
            ust.mixData(ust.base(info.id, 56), 0)
        } or {},
        geometry = func.filter({
            ust.mixData(ust.base(info.id, 57), info.length),
            ust.mixData(ust.base(info.id, 59), math.floor((info.extraHeight or 0) * 10)),
            info.width and ust.mixData(ust.base(info.id, 58), info.width * 10) or false,
            info.leftOverlap and ust.mixData(ust.base(info.id, 67), info.leftOverlap * 10) or false,
            info.rightOverlap and ust.mixData(ust.base(info.id, 68), info.rightOverlap * 10) or false,
        }, pipe.noop()),
        ref = {
            info.ref and
            ust.mixData(ust.base(info.id, 60),
                (info.ref.left and 1 or 0) +
                (info.ref.right and 2 or 0) +
                (info.ref.next and 4 or 0) +
                (info.ref.prev and 8 or 0)
            ) or
            ust.base(info.id, 60)
        }
    }
end

---@param slotId slotid
---@return slottype
---@return id
---@return integer
ust.slotInfo = function(slotId)
        -- Platform/track
        -- 1 ~ 2 : 01 : track 02 platform 03 placeholder 04 streets
        -- 3 ~ 6 : id
        -- Component
        -- 1 ~ 2 : 20 reserved 21 underpass 22 overpass 24 fences/walls 25 bridge 26 tunnel 27 catenary 28 roof 29 type 31 5m Entry 32 10m Entry 33 20m Entry
        --         40 general comp
        -- 3 ~ 6 : id
        -- Information
        -- 1 ~ 2 : 50 reserved 51 x 52 y 53 z 54 55 radius 56 is_straight 57 length 58 width 59 extraHeight 60 ref
        --       : 67 overlap left 68 overlap right
        --       :
        -- 3 ~ 6 : id
        -- > 6: data
        -- Modifier
        -- 1 ~ 2 : 80 81 82 radius 83 84 extraHeight 85 86 width 87 88 gradient 89 90 wall height 91 92 ref 93 94 overlap 95 96 slope
        
        local slotIdAbs = math.abs(slotId)
        if slotIdAbs % 1 ~= 0 then -- trick for probably a bug from the game, slotId can be non interger
            slotIdAbs = floor(slotIdAbs + 0.5)
        end
        local type = slotIdAbs % 100
        local id = (slotIdAbs - type) / 100 % 1000
        local data = slotId > 0 and floor(slotIdAbs / 1000000) or -floor(slotIdAbs / 1000000)
        
        return type, id, data
end

---@param pt coor
---@param vec coor
---@param length number
---@param radius number
---@param isRev boolean
---@return fun(...: number): arc, arc ...
ust.arcPacker = function(pt, vec, length, radius, isRev)
    local nVec = vec:withZ(0):normalized()
    local tVec = coor.xyz(-nVec.y, nVec.x, 0)
    local radius = isRev and -radius or radius
    local o = pt + tVec * radius
    local ar = arc.byOR(o, abs(radius))
    local inf = ar:rad(pt)
    local sup = inf + length / radius
    if isRev then
        inf, sup = sup, inf
    end
    ar = ar:withLimits({
        sup = sup,
        inf = inf
    })
    ---@param ... number
    ---@return arc, arc ...
    return function(...)
        local result = func.map({...}, function(dr)
            local dr = isRev and -dr or dr
            return arc.byOR(o, abs(radius + dr), {
                sup = sup,
                inf = inf
            })
        end)
        return ar, unpack(result)
    end
end

---@param w number
---@param h number
---@param d number
---@param fitTop boolean
---@param fitLeft boolean
---@return fun(size: projection_size, mode: boolean, z?: number): matrix
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
    
    ---@type matrix[]
    local mX = func.map(s, function(s)
        return {
            {s[1].x, s[1].y, s[1].z, 1},
            {s[2].x, s[2].y, s[2].z, 1},
            {s[3].x, s[3].y, s[3].z, 1},
            {s[4].x, s[4].y, s[4].z, 1}
        }
    end)
    
    ---@type matrix[]
    local mXI = func.map(mX, coor.inv)
    
    local fitTop = {fitTop, not fitTop}
    local fitLeft = {fitLeft, not fitLeft}
    
    ---@param size projection_size
    ---@param mode boolean
    ---@param z? number
    ---@return matrix
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
        
        ---@type matrix
        local mU = {
            t[1].x, t[1].y, t[1].z, 1,
            t[2].x, t[2].y, t[2].z, 1,
            t[3].x, t[3].y, t[3].z, 1,
            t[1].x, t[1].y, t[1].z + z, 1
        }
        
        return mXI * mU
    end
end

ust.mRot = function(vec)
    return coor.scaleX(vec:length()) * quat.byVec(coor.xyz(1, 0, 0), vec):mRot()
end

---@param f coor3
---@param t coor3
---@param tag string
---@param mdl? string
---@return mdl|nil
ust.unitLane = function(f, t, tag, mdl) return
    ((t - f):length2() > 1e-2 and (t - f):length2() < 562500)
        and ust.newModel(mdl or "ust/person_lane.mdl", tag, ust.mRot(t - f), coor.trans(f))
        or nil
end

---@class mdl
---@field id string
---@field tag string
---@field transf matrix
---@param m string
---@param tag string
---@param ... matrix
---@return mdl
ust.newModel = function(m, tag, ...)
    return {
        id = m,
        transf = coor.mul(...),
        tag = tag
    }
end

local function posGen(restTrack, lastPlatform, lst, snd, ...)
    if restTrack == 0 then
        if lst and snd then
            return {false, lst, snd, ...}
        elseif lastPlatform and lst then
            return {false, lst, snd, ...}
        else
            return {lst, snd, ...}
        end
    else
        if lst and snd then
            return posGen(restTrack, lastPlatform, false, lst, snd, ...)
        elseif lst and snd == false then
            return posGen(restTrack - 1, lastPlatform, true, lst, snd, ...)
        elseif lst and snd == nil then
            return posGen(restTrack - 1, lastPlatform, false, lst)
        elseif not lst then
            return posGen(restTrack - 1, lastPlatform, true, lst, snd, ...)
        end
    end
end

ust.posGen = posGen

---@param arc arc
---@param n integer
---@return coor3[]
---@return coor3[]
ust.basePts = function(arc, n)
    if not arc.basePts[n] then
        local radDelta = (arc.sup - arc.inf) / n
        local rads = func.map(func.seq(0, n), function(i) return arc.inf + i * radDelta end)
        local pts = func.map(rads, function(rad) return arc:pt(rad) end)
        local vecs = func.map(rads, function(rad) return arc:tangent(rad) end)
        arc.basePts[n] = {pts, vecs}
    end
    local pts, vec = unpack(arc.basePts[n])
    return func.map(pts, function(pt) return coor.xyz(pt.x, pt.y, pt.z) end),
        func.map(vec, function(pt) return coor.xyz(pt.x, pt.y, pt.z) end)
end

---@param params any
---@param pos coor3
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
        params.slotGrid[pos.z][x][y].street = {
            id = makeData(4, octa),
            transf = transf,
            type = "ust_street",
            spacing = {0, 0, 0, 0}
        }
    end
end

---@param modules table<slotid, module>
---@param classified classified_modules
---@param slotId slotid
---@return slottype
---@return slotid
---@return integer
ust.classifyComp = function(modules, classified, slotId)
    local type, id, data = ust.slotInfo(slotId)
    
    modules[slotId].info = {
        data = data,
        type = type,
        slotId = slotId,
        id = id
    }
    
    modules[classified[id].slotId].info.comp[type] = true

    if not modules[classified[id].slotId].info.compList[type] then
        modules[classified[id].slotId].info.compList[type] = { slotId }
    else
        insert(modules[classified[id].slotId].info.compList[type], slotId)
    end

    modules[slotId].makeData = function(type, data)
        return ust.mixData(ust.base(id, type), data)
    end
    
    return type, id, data
end

---@param modules table<slotid, module>
---@param classified classified_modules
---@param slotId slotid
---@return slottype
---@return slotid
---@return integer
ust.classifyData = function(modules, classified, slotId)
    local type, id, data = ust.slotInfo(slotId)
    
    classified[id].slot[type] = slotId
    classified[id].metadata[type] = modules[slotId].metadata
    
    modules[slotId].info = {
        data = data,
        type = type,
        slotId = slotId,
        id = id
    }
    
    return type, id, data
end

---@param modules table<slotid, module>
---@param classified classified_modules
---@param slotId slotid
---@return slottype
---@return slotid
---@return integer
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
        comp = {},
        compList = {},
        pos = coor.xyz(0, 0, 0),
        width = modules[slotId].metadata.width or 5,
        length = 20,
    }
    
    modules[slotId].makeData = function(type, data)
        return ust.mixData(ust.base(id, type), data)
    end
    
    return type, id, data
end

ust.marking = function(result, slotId, params)
    local id = params.modules[slotId].info.id
    local sId = params.classedModules[id].slotId
    local info = params.modules[sId].info
    
    local hRef = info.height
    local hVec = coor.xyz(0, 0, hRef)
    local hTrans = coor.trans(hVec)
    
    local n = 10
    local ptsL, vecL = ust.basePts(info.arcs.left, n)
    local ptsR, vecR = ust.basePts(info.arcs.right, n)
    local ptsC, vecC = ust.basePts(info.arcs.center, n)
    
    local addText = function(label, transf, f)
        local nameModelsF, width = livetext(2)(label)
        for _, m in ipairs(nameModelsF(function() return (f or coor.I()) * coor.transZ(-0.85) * coor.rotX90N * hTrans * transf end)) do
            table.insert(result.models, m)
        end
    end
    
    for i = 1, 11 do
        addText("⋮", quat.byVec(coor.xyz(0, 1, 0), vecL[i]):mRot() * coor.trans(ptsL[i]), coor.transX(-0.1))
        addText("⋮", quat.byVec(coor.xyz(0, 1, 0), vecR[i]):mRot() * coor.trans(ptsR[i]), coor.transX(-0.1))
    end
    
    for _, i in ipairs({1, 11}) do
        addText("⋯", quat.byVec(coor.xyz(0, 1, 0), vecL[i]):mRot() * coor.trans(ptsL[i]), coor.transX(-0.5))
        addText("⋯", quat.byVec(coor.xyz(0, 1, 0), vecR[i]):mRot() * coor.trans(ptsR[i]), coor.transX(-0.5))
        addText("⋯", quat.byVec(coor.xyz(0, 1, 0), vecC[i]):mRot() * coor.trans(ptsC[i]), coor.transX(-0.5))
    end
    
    if info.ref.left then
        local refPt = ptsL[6]
        local refVec = vecL[6]
        local transf = quat.byVec(coor.xyz(0, 1, 0), refVec):mRot() * coor.trans(refPt)
        addText("⋘", transf, coor.transX(0.2))
    end
    
    if info.ref.right then
        local refPt = ptsR[6]
        local refVec = vecR[6]
        local transf = quat.byVec(coor.xyz(0, -1, 0), refVec):mRot() * coor.trans(refPt)
        addText("⋘", transf, coor.transX(0.2))
    end
    
    if info.ref.next then
        local i = 11
        local refPt = ptsC[i]
        local refVec = vecC[i]
        local transf = quat.byVec(coor.xyz(-1, 0, 0), refVec):mRot() * coor.trans(refPt)
        addText("⋘", transf, coor.transX(0.2))
    end
    
    if info.ref.prev then
        local i = 1
        local refPt = ptsC[i]
        local refVec = vecC[i]
        local transf = quat.byVec(coor.xyz(1, 0, 0), refVec):mRot() * coor.trans(refPt)
        addText("⋘", transf, coor.transX(0.2))
    end
end

ust.initTerrainList = function(result, id)
    if not result.terrainLists[id] then
        result.terrainLists[id] = {
            equal = {},
            less = {},
            greater = {},
            equalOpt = {},
            lessOpt = {},
            greaterOpt = {},
        }
    end
end

local function searchTerminalGroups(params, fn)
    local nbGroup = #params.trackGroup
    local modules = pipe.new
        * func.keys(params.classedModules)
        * pipe.map(function(id) return params.classedModules[id].slotId end)
        * pipe.map(function(slotId) return params.modules[slotId] end)
        * pipe.filter(fn)
    
    local sortedModules = modules
        * pipe.sort(function(lhs, rhs) return (lhs.info.pos.x == rhs.info.pos.x) and (lhs.info.pos.y < rhs.info.pos.y) or (lhs.info.pos.x < rhs.info.pos.x) end)
    
    for _, m in ipairs(sortedModules) do
        if not m.info.trackGroup then
            local groupsLeft = {{}}
            local groupsRight = {{}}
            
            repeat
                if not m.info.trackGroup then
                    m.info.trackGroup = {}
                end
                if m.info.octa[7] and params.modules[m.info.octa[7]].metadata.isPlatform then
                    insert(groupsLeft[#groupsLeft], m.info.slotId)
                elseif #groupsLeft[#groupsLeft] > 0 then
                    insert(groupsLeft, {})
                end
                
                if m.info.octa[3] and params.modules[m.info.octa[3]].metadata.isPlatform then
                    insert(groupsRight[#groupsRight], m.info.slotId)
                elseif #groupsRight[#groupsRight] > 0 then
                    insert(groupsRight, {})
                end
                m = params.modules[m.info.octa[1]]
            until not m or not fn(m)
            
            for _, groupLeft in ipairs(groupsLeft) do
                if (#groupLeft > 0) then
                    insert(params.trackGroup, groupLeft)
                    for pos, slotId in ipairs(groupLeft) do
                        params.modules[slotId].info.trackGroup.left = #params.trackGroup
                        params.modules[slotId].info.trackGroup.leftPos = pos
                    end
                end
            end
            
            for _, groupRight in ipairs(groupsRight) do
                if (#groupRight > 0) then
                    insert(params.trackGroup, groupRight)
                    for pos, slotId in ipairs(groupRight) do
                        params.modules[slotId].info.trackGroup.right = #params.trackGroup
                        params.modules[slotId].info.trackGroup.rightPos = pos
                    end
                end
            end
        end
    end
    return nbGroup, #params.trackGroup
end

local searchTrackTerminals = function(params, result)
    local f, t = searchTerminalGroups(params, function(m) return m.metadata.isTrack end)
    if t > f then
        insert(result.stations, {
            terminals = func.seq(f, t - 1),
            tag = 1
        })
    end
end


local searchStreetTerminals = function(params, result)
    local f, t = searchTerminalGroups(params, function(m) return m.metadata.isStreet end)
    if t > f then
        insert(result.stations, {
            terminals = func.seq(f, t - 1),
            tag = 2
        })
    end
end

ust.searchTerminalGroups = function(params, result)
    searchTrackTerminals(params, result)
    searchStreetTerminals(params, result)
    
    result.terminalGroups = func.map(params.trackGroup, function() return {} end)
end

return ust
