local func = require "ust/func"
local pipe = require "ust/pipe"
local coor = require "ust/coor"
local arc = require "ust/coorarc"
local line = require "ust/coorline"
local quat = require "ust/quaternion"
local ust = {}
local dump = require "luadump"

local math = math
local pi = math.pi

local unpack = table.unpack
local insert = table.insert

-- It's a big function so I seperate it
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
        
        -- Build the gridization queue
        local parentMap = {}
        local childrenMap = {}
        
        local mDist = {}
        local gDist = {}
        local mGIndex = {}
        local groups = {}
        
        for x, g in pairs(g) do
            local ySeq = func.sort(func.keys(g))
            local slotSeqs = {}
            for _, y in ipairs(ySeq) do
                local slotId = g[y]
                local m = modules[slotId]
                if not mDist[slotId] then mDist[slotId] = {} end
                if m.info.octa[3] then
                    mDist[slotId][m.info.octa[3]] = 1
                end
                if m.info.octa[7] then
                    mDist[slotId][m.info.octa[7]] = -1
                end
                
                local data = {x = x, y = y, slotId = g[y]}
                if #slotSeqs == 0 then
                    slotSeqs[1] = {data}
                else
                    local lastSeq = slotSeqs[#slotSeqs]
                    if (lastSeq[#lastSeq].y == y - 1) then
                        insert(slotSeqs[#slotSeqs], data)
                    else
                        insert(slotSeqs, {data})
                    end
                end
            end
            for _, slots in ipairs(slotSeqs) do
                local gId = #groups + 1
                insert(groups, {slots = slots, x = x, order = gId, children = {}})
                for _, seq in ipairs(slots) do
                    mGIndex[seq.slotId] = gId
                end
            end
        end
        
        for i, groupL in ipairs(groups) do
            if not gDist[i] then gDist[i] = {} end
            for j, groupR in ipairs(groups) do
                if not gDist[j] then gDist[j] = {} end
                local distX = groupL.x - groupR.x
                if i < j and (distX == 1 or distX == -1) then
                    for _, slotL in ipairs(groupL.slots) do
                        for _, slotR in ipairs(groupR.slots) do
                            local slotIdL = slotL.slotId
                            local slotIdR = slotR.slotId
                            if mDist[slotIdL][slotIdR] then
                                gDist[i][j] = mDist[slotIdL][slotIdR]
                                gDist[j][i] = mDist[slotIdL][slotIdR]
                                break
                            end
                        end
                        if gDist[i][j] then break end
                    end
                end
            end
        end
        
        local function groupTreeGen(g, ...)
            if g then
                local rest = {...}
                for n, _ in pairs(gDist[g]) do
                    if not groups[n].parent then
                        insert(groups[g].children, n)
                        insert(rest, n)
                        groups[n].parent = g
                    end
                end
                groupTreeGen(unpack(rest))
            end
        end
        groups[mGIndex[g[0][0]]].parent = true
        groupTreeGen(groups[mGIndex[g[0][0]]].order)
        local groupRef = {}

        local function slotTreeGen(group, ...)
            if group then
                local g = groups[group]
                local rest = {...}
                
                local refY = groupRef[group] and modules[groupRef[group]].info.pos.y or 0
                local slots = {
                    func.filter(g.slots, function(s) return s.y >= refY end),
                    func.rev(func.filter(g.slots, function(s) return s.y <= refY end))
                }
                
                for _, slots in ipairs(slots) do
                    for i, slot in ipairs(slots) do
                        modules[slot.slotId].info.isRev = slot.y < refY 
                        if groupRef[group] and groupRef[group] == slot.slotId then
                            local parent = parentMap[slot.slotId]
                            if parent then
                                modules[slot.slotId].info.isRev = modules[parent].info.isRev
                            end
                        end
                        dump()({
                            slotId = slot.slotId,
                            parent = groupRef[group],
                            y = slot.y,
                            refY = refY
                        })
                        if not childrenMap[slot.slotId] then childrenMap[slot.slotId] = {} end
                        if slots[i + 1] and not parentMap[slots[i + 1]] then
                            parentMap[slots[i + 1].slotId] = slot.slotId
                            insert(childrenMap[slot.slotId], slots[i + 1].slotId)
                        end
                    end
                    for i, slot in ipairs(slots) do
                        for slotIdR, v in pairs(mDist[slot.slotId] or {}) do
                            local groupR = mGIndex[slotIdR]
                            if func.contains(g.children, groupR) and not func.contains(rest, groupR) and not parentMap[slotIdR] then
                                groupRef[groupR] = slotIdR
                                insert(rest, groupR)
                                parentMap[slotIdR] = slot.slotId
                                insert(childrenMap[slot.slotId], slotIdR)
                            end
                        end
                    end
                end
                slotTreeGen(unpack(rest))
            end
        end
        slotTreeGen(groups[mGIndex[g[0][0]]].order)

        local function queueGen(slotId, ...)
            if slotId then
                local rest = func.concat({...}, childrenMap[slotId] or {})
                return { slotId, unpack(queueGen(unpack(rest))) }
            else
                return {}
            end
        end

        local queue = queueGen(g[0][0])
        
        -- Build the gridization queue
        -- Collect X postion and width information
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
                                insert(xGroup[x][#xGroup[x]], y)
                            else
                                insert(xGroup[x], {y})
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
        
        -- Collect X postion and width information
        -- Process in Y axis
        local processY = function(x, y)
            return function()
                local slotId = grid[z][x][y]
                local m = modules[slotId]
                
                -- First round, for both tracks and platforms
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
                    
                    local ref = parentMap[slotId]-- Anchor is the reference point
                                        
                    if x == 0 and y == 0 then
                        -- The base ref can not be inferred
                        yState.pos = coor.xyz(infoX.pos[0], 0, 0)
                        yState.vec = coor.xyz(0, 1, 0)
                    else
                        if ref == m.info.octa[5] then
                            yState.pos = modules[ref].info.pts[4][1]
                            yState.vec = modules[ref].info.pts[4][2]
                        elseif ref == m.info.octa[1] then
                            yState.pos = modules[ref].info.pts[3][1]
                            yState.vec = -modules[ref].info.pts[3][2]
                        elseif ref == m.info.octa[3] then
                            local pos = modules[ref].info.pts[1][1]
                            local vec = modules[ref].info.pts[1][2]
                            
                            yState.pos = pos + (vec:normalized() .. coor.rotZ((y < 0 and 0.5 or -0.5) * pi)) * (infoX.pos[x] - infoX.pos[x + 1])
                            yState.vec = vec
                        elseif ref == m.info.octa[7] then
                            local pos = modules[ref].info.pts[1][1]
                            local vec = modules[ref].info.pts[1][2]
                            
                            yState.pos = pos + (vec:normalized() .. coor.rotZ((y < 0 and 0.5 or -0.5) * pi)) * (infoX.pos[x] - infoX.pos[x - 1])
                            yState.vec = vec
                        end
                    end
                    
                    if not yState.radius then
                        -- If no radius defined
                        if ref == m.info.octa[5] or ref == m.info.octa[1] then
                            local refM = modules[ref]
                            yState.radius = (refM.info.isRev and m.info.isRev) == (refM.info.isRev or m.info.isRev) and refM.info.radius or -refM.info.radius
                        elseif ref == m.info.octa[3] then
                            yState.radius = modules[m.info.octa[3]].info.radius - (modules[m.info.octa[3]].metadata.width + m.metadata.width) * 0.5
                        elseif ref == m.info.octa[7] then
                            yState.radius = modules[m.info.octa[7]].info.radius + (modules[m.info.octa[7]].metadata.width + m.metadata.width) * 0.5
                        end
                        
                        if not yState.radius then
                            -- If the the radius is still unknown
                            local loop = {}
                            if m.metadata.isTrack or m.metadata.isPlaceholder then
                                -- For tracks search innner side
                                loop = {x + (x < 0 and 1 or -1), (x < 0 and func.max(xPos) or func.min(xNeg) or 0), (x < 0 and 1 or -1)}
                            elseif m.metadata.isPlatform then
                                if (x < 0) then
                                    if m.info.octa[3] and m.info.octa[7] and modules[m.info.octa[3]].metadata.isPlatform and (modules[m.info.octa[7]].metadata.isTrack or modules[m.info.octa[7]].metadata.isPlaceholder) and modules[m.info.octa[7]].info.radius then
                                        -- Left track right platform, and track with radius defined, search the outter side
                                        loop = {x - 1, func.min(xNeg), -1}
                                    else
                                        loop = {x + 1, func.max(xPos) or 0, 1}
                                    end
                                else
                                    if m.info.octa[7] and m.info.octa[3] and modules[m.info.octa[7]].metadata.isPlatform and (modules[m.info.octa[3]].metadata.isTrack or modules[m.info.octa[7]].metadata.isPlaceholder) and modules[m.info.octa[3]].info.radius then
                                        -- Right track and left platform...
                                        loop = {x + 1, func.max(xPos), 1}
                                    else
                                        loop = {x - 1, func.min(xNeg) or 0, -1}
                                    end
                                end
                            end
                            for i = loop[1], loop[2], loop[3] do
                                if grid[z][i] and grid[z][i][y] and modules[grid[z][i][y]].info.radius then
                                    yState.radius = modules[grid[z][i][y]].info.radius + (infoX.pos[x] - infoX.pos[i])
                                    break
                                end
                            end
                            if not yState.radius then
                                -- Make it straight
                                yState.radius = 10e8
                            end
                        end
                    end
                    
                    
                    modules[slotId].info.radius = yState.radius
                    modules[slotId].info.length = yState.length
                    -- Base radius and length
                    -- Initial arch
                    local packer = ust.arcPacker(yState.pos, yState.vec, yState.length, yState.radius)
                    local ar, arL, arR = packer(-yState.width * 0.5, yState.width * 0.5)
                    if m.info.isRev then arL, arR = arR, arL end
                    
                    -- ALignement of starting point and ending point
                    if (x < 0 and m.info.octa[3] and (modules[m.info.octa[3]].metadata.isTrack or modules[m.info.octa[3]].metadata.isPlaceholder) and not modules[m.info.octa[3]].info.ref.left) or
                        (m.metadata.isTrack and ref == m.info.octa[3]) then
                        -- Left side, a track on the right
                        if (y >= 0 and m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform)
                            or (y < 0 and m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform) then
                            -- Next is a platform
                            local sup = modules[m.info.octa[3]].info.arcs.center.sup
                            arL.sup = sup
                            arR.sup = sup
                            ar.sup = sup
                        end
                        if (y >= 0 and m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform)
                            or (y < 0 and m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform) then
                            -- Prev is a platform
                            local inf = modules[m.info.octa[3]].info.arcs.center.inf
                            arL.inf = inf
                            arR.inf = inf
                            ar.inf = inf
                        end
                    elseif (x >= 0 and m.info.octa[7] and (modules[m.info.octa[7]].metadata.isTrack or modules[m.info.octa[7]].metadata.isPlaceholder) and not modules[m.info.octa[7]].info.ref.right) or
                        (m.metadata.isTrack and ref == m.info.octa[5]) then
                        -- Right side, a track on the left
                        if (y >= 0 and m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform)
                            or (y < 0 and m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform) then
                            -- Next is a platform
                            local sup = modules[m.info.octa[7]].info.arcs.center.sup
                            arL.sup = sup
                            arR.sup = sup
                            ar.sup = sup
                        end
                        if (y >= 0 and m.info.octa[5] and modules[m.info.octa[5]].metadata.isPlatform)
                            or (y < 0 and m.info.octa[1] and modules[m.info.octa[1]].metadata.isPlatform) then
                            -- Prev is a platform
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
                    
                    -- Generic ref pts
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
                        -- Platform on second loop
                        local ref = modules[slotId].info.ref or {}
                        modules[slotId].info.ref = ref
                        
                        
                        local aligned = false;
                        
                        if ref.left and ref.right then
                            local leftModule = modules[grid[z][x - 1][y]]
                            local leftO = leftModule.info.arcs.center.o
                            local leftRadius = leftModule.info.radius + (infoX.pos[x] - infoX.pos[x - 1])
                            arL = arc.byOR(leftO, leftRadius - m.info.width * 0.5, leftModule.info.arcs.center:limits())
                            
                            local rightModule = modules[grid[z][x + 1][y]]
                            local rightO = rightModule.info.arcs.center.o
                            local rightRadius = rightModule.info.radius + (infoX.pos[x] - infoX.pos[x + 1])
                            arR = arc.byOR(rightO, rightRadius + m.info.width * 0.5, rightModule.info.arcs.center:limits())
                            
                            local supL = leftModule.info.arcs.center.sup
                            local supR = rightModule.info.arcs.center.sup
                            
                            if leftModule.metadata.isTrack and rightModule.metadata.isTrack then
                                local sup = leftModule.info.pts[2][1]:avg(rightModule.info.pts[2][1])
                                
                                local vecSupL = (leftModule.info.radius > 0 and (leftModule.info.pts[2][1] - arL.o) or (arL.o - leftModule.info.pts[2][1])):normalized()
                                local vecSupR = (rightModule.info.radius > 0 and (rightModule.info.pts[2][1] - arR.o) or (arR.o - rightModule.info.pts[2][1])):normalized()
                                local vecSup = (vecSupL + vecSupR):normalized()
                                local limitSup = line.byVecPt(vecSup, sup)
                                
                                supL = calculateLimit(arL)(limitSup, leftModule.info.pts[2])
                                supR = calculateLimit(arR)(limitSup, rightModule.info.pts[2])
                            end
                            
                            local infL = arL:rad(yState.pos)
                            if (y == 0 or y == -1) then
                                infL = leftModule.info.arcs.center.inf
                            elseif (y > 0 and m.info.octa[5]) then
                                infL = arL:rad(modules[m.info.octa[5]].info.pts[2][1])
                            elseif (y < 0 and m.info.octa[1]) then
                                infL = arL:rad(modules[m.info.octa[1]].info.pts[2][1])
                            end
                            
                            local infR = arR:rad(yState.pos)
                            if (y == 0 or y == -1) then
                                infR = rightModule.info.arcs.center.inf
                            elseif (y > 0 and m.info.octa[5]) then
                                infR = arR:rad(modules[m.info.octa[5]].info.pts[2][1])
                            elseif (y < 0 and m.info.octa[1]) then
                                infR = arR:rad(modules[m.info.octa[1]].info.pts[2][1])
                            end
                            
                            arL = arL:withLimits({sup = supL, inf = infL})
                            arR = arR:withLimits({sup = supR, inf = infR})
                            aligned = true
                        elseif ref.left then
                            local leftModule = modules[grid[z][x - 1][y]]
                            local leftO = leftModule.info.arcs.center.o
                            local leftRadius = leftModule.info.radius + (infoX.pos[x] - infoX.pos[x - 1])
                            arL = arc.byOR(leftO, leftRadius - m.info.width * 0.5, leftModule.info.arcs.center:limits())
                            arR = arc.byOR(leftO, leftRadius + m.info.width * 0.5, leftModule.info.arcs.center:limits())
                            
                            local supL = leftModule.info.arcs.center.sup
                            local supR = leftModule.info.arcs.center.sup
                            
                            if (leftModule.metadata.isTrack) then
                                local limitSup = leftModule.info.limits[2]
                                supL = calculateLimit(arL)(limitSup, leftModule.info.pts[2])
                                supR = calculateLimit(arR)(limitSup, leftModule.info.pts[2])
                            end
                            
                            local inf = arL:rad(yState.pos)
                            if (y == 0 or y == -1) then
                                inf = leftModule.info.arcs.center.inf
                            elseif (y > 0 and m.info.octa[5]) then
                                inf = arL:rad(modules[m.info.octa[5]].info.pts[2][1])
                            elseif (y < 0 and m.info.octa[1]) then
                                inf = arL:rad(modules[m.info.octa[1]].info.pts[2][1])
                            end
                            
                            arL = arL:withLimits({sup = supL, inf = inf})
                            arR = arR:withLimits({sup = supR, inf = inf})
                            aligned = true
                        elseif ref.right then
                            local rightModule = modules[grid[z][x + 1][y]]
                            local rightO = rightModule.info.arcs.center.o
                            local rightRadius = rightModule.info.radius + (infoX.pos[x] - infoX.pos[x + 1])
                            arL = arc.byOR(rightO, rightRadius - m.info.width * 0.5, rightModule.info.arcs.center:limits())
                            arR = arc.byOR(rightO, rightRadius + m.info.width * 0.5, rightModule.info.arcs.center:limits())
                            
                            local supL = rightModule.info.arcs.center.sup
                            local supR = rightModule.info.arcs.center.sup
                            
                            if (rightModule.metadata.isTrack) then
                                local limitSup = rightModule.info.limits[2]
                                supL = calculateLimit(arL)(limitSup, rightModule.info.pts[2])
                                supR = calculateLimit(arR)(limitSup, rightModule.info.pts[2])
                            end
                            
                            local inf = arL:rad(yState.pos)
                            if (y == 0 or y == -1) then
                                inf = rightModule.info.arcs.center.inf
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
                            
                            if (m.info.isRev and modules[m.info.octa[5]].info.isRev) ~= (m.info.isRev or modules[m.info.octa[5]].info.isRev) then
                                arL.sup, arL.inf = arL.inf, arL.sup
                                arR.sup, arR.inf = arR.inf, arR.sup
                            end
                            
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
                            
                            if (m.info.isRev and modules[m.info.octa[1]].info.isRev) ~= (m.info.isRev or modules[m.info.octa[1]].info.isRev) then
                                arL.sup, arL.inf = arL.inf, arL.sup
                                arR.sup, arR.inf = arR.inf, arR.sup
                            end
                            
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
                            modules[slotId].info.radius = (length > 0 and 1 or -1) * (m.info.isRev and -1 or 1) * r
                            modules[slotId].info.length = math.abs(length)
                        end
                        
                        refArc = {
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
                error(debug.traceback(cr[current]))
            end
        end
    end
    return grid, lowestHeight
end

return ust
