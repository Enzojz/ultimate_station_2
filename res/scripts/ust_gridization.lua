local func = require "ust/func"
local pipe = require "ust/pipe"
local coor = require "ust/coor"
local line = require "ust/coorline"

local pi = math.pi
local unpack = table.unpack
local insert = table.insert
local remove = table.remove

local ust = {}

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
        if module.metadata.isTrack or module.metadata.isStreet or module.metadata.isPlatform or module.metadata.isPlaceholder then
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
    local groups = {}
    
    for x, g in pairs(g) do
        insert(groups, {})
        local ySeq = func.sort(func.keys(g))
        local function f(y, yNext, ...)
            local slotId = g[y]
            insert(groups[#groups], slotId)
            if yNext then
                if yNext - y > 1 then
                    insert(groups[#groups], slotId)
                    insert(groups, {})
                end
                f(yNext, ...)
            end
        end
        f(unpack(ySeq))
    end
    
    local parentMap = {}
    local moduleDeps = {}
    
    local function slotDeps(module)
        local pos = module.info.pos
        for _, posocta in ipairs({{"next", 1}, {"right", 3}, {"prev", 5}, {"left", 7}}) do
            local pos, octa = unpack(posocta)
            if module.info.ref[pos] then
                if not moduleDeps[module.info.octa[octa]] then
                    moduleDeps[module.info.octa[octa]] = {}
                end
                insert(moduleDeps[module.info.octa[octa]], module.info.slotId)
            end
        end
    end
    
    for x, g in pairs(g) do
        local ySeq = func.sort(func.keys(g))
        for _, y in ipairs(ySeq) do
            slotDeps(modules[g[y]])
        end
    end
    
    local queue = {}
    local monoYDeps = {g[0][0]}
    local monoXDeps = {}
    local doubleDeps = {}
    local depthMap = {[g[0][0]] = 0}
    
    while #monoXDeps > 0 or #monoYDeps > 0 or #doubleDeps > 0 do
        local slotId = #monoYDeps > 0 and remove(monoYDeps, 1) or (#monoXDeps > 0 and remove(monoXDeps, 1) or remove(doubleDeps, 1))
        local module = modules[slotId]
        insert(queue, slotId)
        if moduleDeps[slotId] then
            for _, depSlotId in ipairs(moduleDeps[slotId]) do
                local mDep = modules[depSlotId]
                if not parentMap[depSlotId] then
                    if mDep.info.ref.left and mDep.info.ref.right then
                        insert(doubleDeps, depSlotId)
                        parentMap[depSlotId] = slotId
                        depthMap[depSlotId] = depthMap[slotId] + 1
                    elseif mDep.info.octa[1] == module.info.slotId or mDep.info.octa[5] == module.info.slotId then
                        insert(monoYDeps, depSlotId)
                        parentMap[depSlotId] = slotId
                        depthMap[depSlotId] = depthMap[slotId] + 1
                    elseif mDep.info.octa[3] == module.info.slotId or mDep.info.octa[7] == module.info.slotId then
                        insert(monoXDeps, depSlotId)
                        parentMap[depSlotId] = slotId
                        depthMap[depSlotId] = depthMap[slotId] + 1
                    end
                end
            end
        end
    end
    for _, slotIds in ipairs(groups) do
        local modules = func.map(slotIds, function(slotId) return modules[slotId] end)
        local validModules = func.filter(modules, function(module) return not (module.info.ref.left and module.info.ref.right) end)
        if #validModules > 0 then
            local shallowest = func.min(validModules, function(lhs, rhs) return depthMap[lhs.info.slotId] < depthMap[rhs.info.slotId] end)
            for _, m in ipairs(modules) do
                m.info.refPos = m.info.pos - shallowest.info.pos
            end
        else
            local shallowest = func.min(modules, function(lhs, rhs) return depthMap[lhs.info.slotId] < depthMap[rhs.info.slotId] end)
            for _, m in ipairs(modules) do
                m.info.refPos = m.info.pos - shallowest.info.pos
            end
        end
    end
    
    return pipe.new * queue, parentMap
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
        m.info.width = m.metadata.width
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
            
            yState.pos = pos + (vec:normalized() .. coor.rotZ(-0.5 * pi)) * (data.xState.pos[x] - data.xState.pos[x + 1])
            yState.vec = vec
        elseif ref == m.info.octa[7] then
            local pos = data.modules[ref].info.pts[1][1]
            local vec = data.modules[ref].info.pts[1][2]
            
            yState.pos = pos + (vec:normalized() .. coor.rotZ(-0.5 * pi)) * (data.xState.pos[x] - data.xState.pos[x - 1])
            yState.vec = vec
        end
    end
    
    if m.info.straight then
        m.info.radius = 10e8
    elseif not m.info.radius then
        if ref == m.info.octa[5] or ref == m.info.octa[1] then
            m.info.radius = data.modules[ref].info.radius
        elseif ref == m.info.octa[3] then
            m.info.radius = data.modules[m.info.octa[3]].info.radius - (data.xState.width[x + 1] + data.xState.width[x]) * 0.5
        elseif ref == m.info.octa[7] then
            m.info.radius = data.modules[m.info.octa[7]].info.radius + (data.xState.width[x - 1] + data.xState.width[x]) * 0.5
        else
            m.info.radius = 10e8
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
        and (data.modules[m.info.octa[3]].metadata.isTrack or data.modules[m.info.octa[3]].metadata.isStreet or data.modules[m.info.octa[3]].metadata.isPlaceholder)
        and not data.modules[m.info.octa[3]].info.ref.left
        )
        or ((m.metadata.isTrack or m.metadata.isStreet) and ref == m.info.octa[3])
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
        and (data.modules[m.info.octa[7]].metadata.isTrack or data.modules[m.info.octa[7]].metadata.isStreet or data.modules[m.info.octa[7]].metadata.isPlaceholder)
        and not data.modules[m.info.octa[7]].info.ref.right
        ) or
        ((m.metadata.isTrack or m.metadata.isStreet) and ref == m.info.octa[7])
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
    m.info.limits = func.map(m.info.pts, function(ptvec) return line.byVecPt(ptvec[2] .. coor.rotZ(0.5 * pi), ptvec[1]) end)
end

---@param modules modules
---@param classedModules classified_modules
---@return table
---@return integer
ust.gridization = function(modules, classedModules)
    local grid = ust.octa(modules, classedModules)
    
    for z, g in pairs(grid) do
        local queue, parentMap = fnQueue(g, modules)
        local queue2 = queue * pipe.filter(function(slotId) return not (modules[slotId].info.ref.left and modules[slotId].info.ref.right) end)
            + queue * pipe.filter(function(slotId) return modules[slotId].info.ref.left and modules[slotId].info.ref.right end)
        
        local globalQueue = queue + queue + queue2
        
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
        
        for _, slotId in ipairs(queue) do
            local m = modules[slotId]
            if (m.metadata.scriptName and game.res.script[m.metadata.scriptName]) then
                local fn = game.res.script[m.metadata.scriptName][m.metadata.gridization or "gridization"]
                if fn then
                    local pos = modules[slotId].info.pos
                    cr[slotId] = coroutine.create(processY(fn, pos.x, pos.y))
                end
            end
        end
        
        for _, slotId in ipairs(globalQueue) do
            local result = coroutine.resume(cr[slotId])
            if not result then
                error(debug.traceback(cr[slotId]))
            end
        end
    end
    return grid
end

return ust
