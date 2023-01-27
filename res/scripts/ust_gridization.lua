local func = require "ust/func"
local pipe = require "ust/pipe"
local coor = require "ust/coor"
local arc = require "ust/coorarc"
local line = require "ust/coorline"
local quat = require "ust/quaternion"
local ust = {}

local math = math
local pi = math.pi

local unpack = table.unpack
local insert = table.insert


---@param modules modules
---@param classedModules classified_modules
---@return grid
ust.octa = function(modules, classedModules)
    local grid = {}

    -- 8 1 2
    -- 7 x 3
    -- 6 5 4

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
    return grid
end

---@param g table<integer, table<integer, integer>>
---@param modules modules
---@return integer[]
---@return integer[]
local function fnQueue(g, modules)
    -- g: all modules in a same z layer
    -- Build the gridization queue
    ---@type integer[]
    local parentMap = {}
    
    ---@type integer[][]
    local childrenMap = {}
    
    -- Module distance
    ---@type integer[][]
    local mDist = {}
    
    -- Group distance
    ---@type integer[][]
    local gDist = {}
    
    -- Module Group Look up table
    ---@type integer[]
    local mGIndex = {}
    
    ---@class group
    ---@field x integer
    ---@field slots group_slot[]
    ---@field order integer
    ---@field children integer[]
    ---@field parent integer|boolean
    ---@class group_slot
    ---@field x integer
    ---@field y integer
    ---@field slotId integer
    -- Group list
    ---@type group[]
    local groups = {}
    
    for x, g in pairs(g) do
        ---@type integer[]
        local ySeq = func.sort(func.keys(g))
        
        ---@type group_slot[][]
        local slotSeqs = {}
        for _, y in ipairs(ySeq) do
            local slotId = g[y]
            local m = modules[slotId]
            if not mDist[slotId] then mDist[slotId] = {} end
            if m.info.octa[3] then -- Module on the right
                mDist[slotId][m.info.octa[3]] = 1
            end
            if m.info.octa[7] then -- Module on the left
                mDist[slotId][m.info.octa[7]] = -1
            end
            
            ---@type group_slot
            local data = {x = x, y = y, slotId = g[y]}
            
            -- To build a continous module group from ymin to ymax
            if #slotSeqs == 0 then
                slotSeqs[1] = {data}
            else
                local lastSeq = slotSeqs[#slotSeqs]
                if (lastSeq[#lastSeq].y == y - 1) then
                    insert(slotSeqs[#slotSeqs], data)-- If continous
                else
                    insert(slotSeqs, {data})-- Otherwise create a new seq
                end
            end
        end
        for _, slots in ipairs(slotSeqs) do
            local gId = #groups + 1 -- Define group id
            insert(groups, {slots = slots, x = x, order = gId, children = {}})
            for _, seq in ipairs(slots) do
                mGIndex[seq.slotId] = gId -- Module to group LUT
            end
        end
    end
    
    -- Calculate group distance
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
    
    -- Generate the group parent - children tree
    ---@param g integer
    ---@param ... integer
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
    
    ---@param group integer
    ---@param ... integer
    local function slotTreeGen(group, ...)
        if group then
            local g = groups[group]
            local parentG = g.parent ~= true and groups[g.parent] or nil
            local rest = {...}
            
            ---@type integer
            local refY = groupRef[group] and modules[groupRef[group]].info.pos.y or 0
            ---@type integer
            local refX = groupRef[group] and modules[groupRef[group]].info.pos.x or 0
            
            ---@type group_slot[][]
            local slots = {
                func.filter(g.slots, function(s) return s.y >= refY end),
                func.rev(func.filter(g.slots, function(s) return s.y <= refY end))
            }
            
            for _, slots in ipairs(slots) do
                for i, slot in ipairs(slots) do
                    modules[slot.slotId].info.refPos = coor.xyz(parentG and g.x - parentG.x or 0, slot.y - refY, 0)
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
    
    ---@param slotId integer
    ---@param ... integer
    ---@return integer[]
    local function queueGen(slotId, ...)
        if slotId then
            local rest = func.concat({...}, childrenMap[slotId] or {})
            return {slotId, unpack(queueGen(unpack(rest)))}
        else
            return {}
        end
    end
    
    return queueGen(g[0][0]), parentMap
end

ust.refArc2Pts = function(refArc)
    return {
        {
            refArc.center:pt(refArc.center.inf),
            refArc.center:tangent(refArc.center.inf)
        },
        {
            refArc.center:pt(refArc.center.sup),
            refArc.center:tangent(refArc.center.sup)
        }
    }
end

ust.calculateRaidus = function(x, y, z, data)
    local slotId = data.grid[z][x][y]
    local m = data.modules[slotId]
    
    if not m.info.width then
        m.info.width = m.info.width or m.metadata.width
    end
    
    coroutine.yield()
    
    local yState = {}
    
    local ref = data.parentMap[slotId]-- Anchor is the reference point
    
    if x == 0 and y == 0 then
        -- The base ref can not be inferred
        yState.pos = coor.xyz(data.xState.pos[0], 0, 0)
        yState.vec = coor.xyz(0, 1, 0)
    else
        if ref == m.info.octa[5] then
            yState.pos = data.modules[ref].info.pts[2][1]
            yState.vec = data.modules[ref].info.pts[2][2]
        elseif ref == m.info.octa[1] then
            yState.pos = data.modules[ref].info.pts[1][1]
            yState.vec = -data.modules[ref].info.pts[1][2]
        elseif ref == m.info.octa[3] then
            local pos = data.modules[ref].info.pts[1][1]
            local vec = data.modules[ref].info.pts[1][2]
            
            yState.pos = pos + (vec:normalized() .. coor.rotZ90N) * (data.xState.pos[x] - data.xState.pos[x + 1])
            yState.vec = vec
        elseif ref == m.info.octa[7] then
            local pos = data.modules[ref].info.pts[1][1]
            local vec = data.modules[ref].info.pts[1][2]
            
            yState.pos = pos + (vec:normalized() .. coor.rotZ90N) * (data.xState.pos[x] - data.xState.pos[x - 1])
            yState.vec = vec
        end
    end
    
    if not m.info.radius then
        -- If no radius defined
        if ref == m.info.octa[5] or ref == m.info.octa[1] then
            m.info.radius = data.modules[ref].info.radius
        elseif ref == m.info.octa[3] then
            m.info.radius = data.modules[m.info.octa[3]].info.radius - (data.xState.width[x + 1] + data.xState.width[x]) * 0.5
        elseif ref == m.info.octa[7] then
            m.info.radius = data.modules[m.info.octa[7]].info.radius + (data.xState.width[x - 1] + data.xState.width[x]) * 0.5
        end
        
        if not m.info.radius then
            -- If the the radius is still unknown
            local loop = {}
            if m.metadata.isTrack or m.metadata.isPlaceholder then
                -- For tracks search innner side
                loop = {x + (x < 0 and 1 or -1), (x < 0 and func.max(data.xPos) or func.min(data.xNeg) or 0), (x < 0 and 1 or -1)}
            elseif m.metadata.isPlatform then
                if (x < 0) then
                    if m.info.octa[3] and m.info.octa[7] and data.modules[m.info.octa[3]].metadata.isPlatform and (data.modules[m.info.octa[7]].metadata.isTrack or data.modules[m.info.octa[7]].metadata.isPlaceholder) and data.modules[m.info.octa[7]].info.radius then
                        -- Left track right platform, and track with radius defined, search the outter side
                        loop = {x - 1, func.min(data.xNeg), -1}
                    else
                        loop = {x + 1, func.max(data.xPos) or 0, 1}
                    end
                else
                    if m.info.octa[7] and m.info.octa[3] and data.modules[m.info.octa[7]].metadata.isPlatform and (data.modules[m.info.octa[3]].metadata.isTrack or data.modules[m.info.octa[7]].metadata.isPlaceholder) and data.modules[m.info.octa[3]].info.radius then
                        -- Right track and left platform...
                        loop = {x + 1, func.max(data.xPos), 1}
                    else
                        loop = {x - 1, func.min(data.xNeg) or 0, -1}
                    end
                end
            end
            for i = loop[1], loop[2], loop[3] do
                if data.grid[z][i] and data.grid[z][i][y] and data.modules[data.grid[z][i][y]].info.radius then
                    m.info.radius = data.modules[data.grid[z][i][y]].info.radius + (data.xState.pos[x] - data.xState.pos[i])
                    break
                end
            end
            if not m.info.radius then
                -- Make it straight
                m.info.radius = 10e8
            end
        end
    end
    
    data.yState = yState
end

ust.genericArcs = function(x, y, z, data)
    local slotId = data.grid[z][x][y]
    local ref = data.parentMap[slotId]
    local m = data.modules[slotId]
    local packer = ust.arcPacker(data.yState.pos, data.yState.vec, m.info.length, m.info.radius, ref == m.info.octa[1])
    local ar, arL, arR = packer(-m.info.width * 0.5, m.info.width * 0.5)
    
    -- ALignement of starting point and ending point
    if (
    ((m.info.refPos.x == 0 and x < 0) or m.info.refPos.x < 0)
        and m.info.octa[3]
        and (data.modules[m.info.octa[3]].metadata.isTrack or data.modules[m.info.octa[3]].metadata.isPlaceholder)
        and not data.modules[m.info.octa[3]].info.ref.left
        )
        or (m.metadata.isTrack and ref == m.info.octa[3])
    then
        -- Left side, a track on the right
        if m.info.octa[1] and data.modules[m.info.octa[1]].metadata.isPlatform then
            -- Next is a platform
            local sup = data.modules[m.info.octa[3]].info.arcs.center.sup
            arL.sup = sup
            arR.sup = sup
            ar.sup = sup
        end
        if m.info.octa[5] and data.modules[m.info.octa[5]].metadata.isPlatform then
            -- Prev is a platform
            local inf = data.modules[m.info.octa[3]].info.arcs.center.inf
            arL.inf = inf
            arR.inf = inf
            ar.inf = inf
        end
    elseif (
    ((m.info.refPos.x == 0 and x >= 0) or m.info.refPos.x > 0)
        and m.info.octa[7]
        and (data.modules[m.info.octa[7]].metadata.isTrack or data.modules[m.info.octa[7]].metadata.isPlaceholder)
        and not data.modules[m.info.octa[7]].info.ref.right
        ) or
        (m.metadata.isTrack and ref == m.info.octa[7])
    then
        -- Right side, a track on the left
        if m.info.octa[1] and data.modules[m.info.octa[1]].metadata.isPlatform then
            -- Next is a platform
            local sup = data.modules[m.info.octa[7]].info.arcs.center.sup
            arL.sup = sup
            arR.sup = sup
            ar.sup = sup
        end
        if m.info.octa[5] and data.modules[m.info.octa[5]].metadata.isPlatform then
            -- Prev is a platform
            local inf = data.modules[m.info.octa[7]].info.arcs.center.inf
            arL.inf = inf
            arR.inf = inf
            ar.inf = inf
        end
    end
    
    m.info.arcs = {
        left = arL,
        right = arR,
        center = ar
    }
    
    -- Generic ref pts
    m.info.pts = ust.refArc2Pts(m.info.arcs)
    m.info.limits = func.map(m.info.pts, function(ptvec) return line.byVecPt(ptvec[2] .. coor.rotZ90P, ptvec[1]) end)
end

---@param modules modules
---@param classedModules classified_modules
---@return table
---@return integer
ust.gridization = function(modules, classedModules)
    ---@type grid
    local grid = ust.octa(modules, classedModules)
    
    for z, g in pairs(grid) do
        
        local queue, parentMap = fnQueue(g, modules)
        
        -- Build the gridization queue
        -- Collect X postion and width information
        local xPos = func.seq(0, func.max(func.keys(g)))
        local xNeg = func.seq(func.min(func.keys(g)), -1)
        
        local xState = {
            pos = {[0] = 0},
            width = {}
        }
        do
            local xGroup = {}
            
            for _, x in ipairs(func.concat(xPos, func.rev(xNeg))) do
                local width = 0
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
                    xState.width[x] = width
                    if x > 0 then
                        xState.pos[x] = xState.pos[x - 1] + xState.width[x - 1] * 0.5 + width * 0.5
                    elseif x < 0 then
                        xState.pos[x] = xState.pos[x + 1] - xState.width[x + 1] * 0.5 - width * 0.5
                    end
                end
            end
        end
        
        -- Collect X postion and width information
        -- Process in Y axis
        local processY = function(fn, x, y)
            return function()
                local slotId = grid[z][x][y]
                local m = modules[slotId]
                                
                local data = {
                    modules = modules,
                    grid = grid,
                    xState = xState,
                    xPos = xPos,
                    xNeg = xNeg,
                    parentMap = parentMap,
                }
                
                fn(x, y, z, data)
            end
        end
        
        local cr = {}
        
        for _, current in ipairs(queue) do
            local m = modules[current]
            if (m.metadata.scriptName and game.res.script[m.metadata.scriptName]) then
                local fn = game.res.script[m.metadata.scriptName][m.metadata.gridization or "gridization"]
                if fn then
                    local pos = modules[current].info.pos
                    insert(cr, coroutine.create(processY(fn, pos.x, pos.y)))
                end
            end
        end
        
        for i = 1, 3 do
            for _, fn in ipairs(cr) do
                local result = coroutine.resume(fn)
                if not result then
                    error(debug.traceback(fn))
                end
            end
        end

    end
    return grid
end


return ust
