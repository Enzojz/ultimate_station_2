local func = require "ust/func"
local coor = require "ust/coor"
local arc = require "ust/coorarc"
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

local segmentLength = 20

ust.typeList = {
    [1] = "ust_track",
    [2] = "ust_platform",
}

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

ust.slotInfo = function(slotId, classedModules)
        -- Platform/track
        -- 1 ~ 2 : 01 : track 02 platform
        -- 3 ~ 6 : id
        -- Information
        -- 1 ~ 2 : 51 x 52 y 53 z 54 radius 55 length 56 width
        -- 3 ~ 6 : id
        -- > 6: data
        local slotIdAbs = math.abs(slotId)
        local type = slotIdAbs % 100
        local id = (slotIdAbs - type) / 100 % 1000
        
        if (type < 50) then
            local info = classedModules[id].info
            local x = info[51]
            local y = info[52]
            local z = info[53] or 0
            local radius = (info[54] or 0) + (info[55] or 0) * 1000
            local straight = info[56] and true or nil
            local length = info[57] or 20
            local width = info[58]
            local canModifyRadius = info[80] == 0 and true or false
            local canModifyDest = info[80] == 1 and true or false
            local data = classedModules[id].data
            
            if straight or radius == 0 then
                radius = nil
            end

            return {
                type = type,
                id = id,
                pos = coor.xyz(x, y, z),
                radius = radius,
                straight = straight,
                length = length,
                width = width,
                data = data,
                canModifyRadius = canModifyRadius,
                canModifyDest = canModifyDest,
                octa = {false, false, false, false, false, false, false, false}
            }
        else
            return {
                type = type,
                id = id,
                data = classedModules[id].info[type]
            }
        end
end

ust.normalizeRad = function(rad)
    return (rad < pi * -0.5) and ust.normalizeRad(rad + pi * 2) or
        ((rad > pi + pi * 0.5) and ust.normalizeRad(rad - pi * 2) or rad)
end

ust.arc2Edges = function(arc)
    local extLength = 2
    local extArc = arc:extendLimits(-extLength)
    local length = arc.r * abs(arc.sup - arc.inf)
    
    local sup = arc:pt(arc.sup)
    local inf = arc:pt(arc.inf)
    
    local supExt = arc:pt(extArc.sup)
    local infExt = arc:pt(extArc.inf)
    
    local vecSupExt = arc:tangent(extArc.sup)
    local vecInfExt = arc:tangent(extArc.inf)
    
    local vecSup = arc:tangent(arc.sup)
    local vecInf = arc:tangent(arc.inf)
    
    return {
        {inf, vecInf * extLength},
        {infExt, vecInfExt * extLength},
        
        {infExt, vecInfExt * (length - extLength)},
        {supExt, vecSupExt * (length - extLength)},
        
        {supExt, vecSupExt * extLength},
        {sup, vecSup * extLength}
    }
end

ust.arcPacker = function(pt, vec, length, radius)
    local nVec = vec:withZ(0):normalized()
    local tVec = radius > 0 and coor.xyz(-nVec.y, nVec.x, 0) or coor.xyz(nVec.y, nVec.x, 0)
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
            return arc.byOR(o, abs(radius - dr), {
                sup = sup,
                inf = inf
            })
        end)
        return ar, table.unpack(result)
    end
end

local retriveNSeg = function(length, l, ...)
    return (function(x) return (x < 1 or (x % 1 > 0.5)) and ceil(x) or floor(x) end)(l:length() / length), l, ...
end

local retriveBiLatCoords = function(nSeg, l, ...)
    local rst = pipe.new * {l, ...}
    local lscale = l:length() / (nSeg * segmentLength)
    return unpack(
        func.map(rst,
            function(s) return abs(lscale) < 1e-5 and pipe.new * {} or pipe.new * func.seqMap({0, nSeg},
                function(n) return s:pt(s.inf + n * ((s.sup - s.inf) / nSeg)) end)
            end)
)
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

ust.biLatCoords = function(length)
    return function(...)
        local arcs = pipe.new * {...}
        local arcsInf = func.map({...}, pipe.select(1))
        local arcsSup = func.map({...}, pipe.select(2))
        local nSegInf = retriveNSeg(length, unpack(arcsInf))
        local nSegSup = retriveNSeg(length, unpack(arcsSup))
        if (nSegInf % 2 ~= nSegSup % 2) then
            if (nSegInf > nSegSup) then
                nSegSup = nSegSup + 1
            else
                nSegInf = nSegInf + 1
            end
        end
        return unpack(ungroup
            (retriveBiLatCoords(nSegInf, unpack(arcsInf)))
            (retriveBiLatCoords(nSegSup, unpack(arcsSup)))
            (pipe.new)
    )
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

ust.unitLane = function(f, t) return ((t - f):length2() > 1e-2 and (t - f):length2() < 562500) and general.newModel("ust/person_lane.mdl", general.mRot(t - f), coor.trans(f)) or nil end

ust.stepLane = function(f, t)
    local vec = t - f
    local length = vec:length()
    if (length > 750 or length < 0.1) then return {} end
    local dZ = abs((f - t).z)
    if (length > dZ * 3 or length < 5) then
        return {general.newModel("ust/person_lane.mdl", general.mRot(vec), coor.trans(f))}
    else
        local hVec = vec:withZ(0) / 3
        local fi = f + hVec
        local ti = t - hVec
        return {
            general.newModel("ust/person_lane.mdl", general.mRot(fi - f), coor.trans(f)),
            general.newModel("ust/person_lane.mdl", general.mRot(ti - fi), coor.trans(fi)),
            general.newModel("ust/person_lane.mdl", general.mRot(t - ti), coor.trans(ti))
        }
    end
end

ust.buildSurface = function(tZ)
    return function(fitModel, fnSize)
        local fnSize = fnSize or function(_, lc, rc) return ust.assembleSize(lc, rc) end
        return function(i, s, ...)
            local sizeS = fnSize(i, ...)
            return s
                and pipe.new
                / func.with(general.newModel(s .. "_tl.mdl", tZ and (tZ * fitModel(sizeS, true)) or fitModel(sizeS, true)), {pos = i})
                / func.with(general.newModel(s .. "_br.mdl", tZ and (tZ * fitModel(sizeS, false)) or fitModel(sizeS, false)), {pos = i})
                or pipe.new * {}
        end
    end
end

ust.linkConnectors = function(allConnectors)
    return
        #allConnectors < 2
        and {}
        or allConnectors
        * pipe.interlace()
        * pipe.map(function(conn)
            local recordL = {}
            local recordR = {}
            if (#conn[1] == 0 and #conn[2] == 0) then return {} end
            
            for i, l in ipairs(conn[1]) do
                for j, r in ipairs(conn[2]) do
                    local vec = l - r
                    local dist = vec:length2()
                    recordL[i] = recordL[i] and recordL[i].dist < dist and recordL[i] or {dist = dist, vec = vec, i = i, j = j, l = l, r = r}
                    recordR[j] = recordR[j] and recordR[j].dist < dist and recordR[j] or {dist = dist, vec = vec, i = i, j = j, l = l, r = r}
                end
            end
            
            return #recordL == 0 and #recordR == 0 and {} or (pipe.new + recordL + recordR)
                * pipe.sort(function(l, r) return l.i < r.i or (l.i == r.i and l.j < r.j) end)
                * pipe.fold(pipe.new * {}, function(result, e)
                    if #result > 0 then
                        local lastElement = result[#result]
                        return (lastElement.i == e.i and lastElement.j == e.j) and result or (result / e)
                    else
                        return result / e
                    end
                end)
                * pipe.map(function(e) return ust.unitLane(e.l, e.r) end)
        end)
        * pipe.flatten()
end

ust.models = function(set)
    local c = "ust/ceil/"
    local t = "ust/top/"
    local p = "ust/platform/" .. set.platform .. "/"
    local w = "ust/wall/" .. set.wall .. "/"
    return {
        platform = {
            edgeLeft = p .. "platform_edge_left",
            edgeRight = p .. "platform_edge_right",
            central = p .. "platform_central",
            left = p .. "platform_left",
            right = p .. "platform_right",
        },
        upstep = {
            a = p .. "platform_upstep_a",
            b = p .. "platform_upstep_b",
            aLeft = w .. "platform_upstep_a_left",
            aRight = w .. "platform_upstep_a_right",
            aInner = w .. "platform_upstep_a_inner",
            bLeft = w .. "platform_upstep_b_left",
            bRight = w .. "platform_upstep_b_right",
            bInner = w .. "platform_upstep_b_inner",
            back = w .. "platform_upstep_back"
        },
        downstep = {
            right = w .. "platform_downstep_left",
            left = w .. "platform_downstep_right",
            central = p .. "platform_downstep",
            back = w .. "platform_downstep_back"
        },
        ceil = {
            edge = c .. "ceil_edge",
            central = c .. "ceil_central",
            left = c .. "ceil_left",
            right = c .. "ceil_right",
            aLeft = c .. "ceil_upstep_a_left",
            aRight = c .. "ceil_upstep_a_right",
            bLeft = c .. "ceil_upstep_b_left",
            bRight = c .. "ceil_upstep_b_right",
        },
        top = {
            track = {
                left = t .. "top_track_left",
                right = t .. "top_track_right",
                central = t .. "top_track_central"
            },
            platform = {
                left = t .. "top_platform_left",
                right = t .. "top_platform_right",
                central = t .. "top_platform_central"
            },
        },
        wallTrack = w .. "wall_track",
        wallPlatform = w .. "wall_platform",
        wallExtremity = w .. "wall_extremity",
        wallExtremityEdge = w .. "wall_extremity_edge",
        wallExtremityPlatform = w .. "wall_extremity_platform",
        wallExtremityTop = w .. "wall_extremity_top",
        chair = p .. "platform_chair"
    }
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

local makeLayout = function(totalTracks, ignoreFst, ignoreLst)
    local function makeLayout(nbTracks, result)
        local p = false
        local t = true
        if (nbTracks == 0) then
            local result = ignoreLst and result or (result[#result] and (result / p) or result)
            return result
        elseif (nbTracks == totalTracks and ignoreFst) then
            return makeLayout(nbTracks - 1, result / t)
        elseif (nbTracks == totalTracks and not ignoreFst) then
            return makeLayout(nbTracks - 1, result / p / t)
        elseif (nbTracks == 1 and ignoreLst) then
            return makeLayout(nbTracks - 1, ((not result) or result[#result]) and (result / p / t) or (result / t))
        elseif (nbTracks == 1 and not ignoreLst) then
            return makeLayout(nbTracks - 1, result / t / p)
        elseif (result[#result] == t) then
            return makeLayout(nbTracks - 2, result / t / p / t)
        else
            return makeLayout(nbTracks - 1, result / t)
        end
    end
    return makeLayout(totalTracks, pipe.new)
end

-- ust.createTemplateFn = function(params)
--     local radius = ustm.rList[params.radius + 1] * 1000
--     local length = min(ustm.trackLengths[params.lPlatform + 1], abs(radius * pi * 1.5))
--     local nbTracks = ustm.trackNumberList[params.trackNb + 1]
--     local layout = makeLayout(nbTracks, params.platformLeft == 0, params.platformRight == 0)
--     local midPos = ceil(#layout / 2)
--     local nSeg = length / 5
--     local stair = floor(nSeg / 4)
--     local result = {}
--     local trackType = ("%s%s.module"):format(params.capturedParams.moduleList[params.trackType + 1], params.catenary == 1 and "_catenary" or "")
--     local platformType = ustm.platformWidthList[(params.platformWidth) + 1]
--     for i, t in ipairs(layout) do
--         if t then
--             result[(i - midPos >= 0 and i or 1000 + i) - midPos] = trackType
--         else
--             local slot = (i - midPos >= 0 and i or 1000 + i) + 1000 - midPos
--             result[slot] = platformType
--             result[slot + 2000 + stair * 100000] = "station/rail/ust_platform_upstair.module"
--             result[slot + 2000 + (stair + 1) * 100000] = "station/rail/ust_platform_upstair.module"
--         end
--     end
--     return result
-- end
return ust
