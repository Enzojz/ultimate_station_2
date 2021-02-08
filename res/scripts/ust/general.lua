local func = require "ust/func"
local coor = require "ust/coor"
local pipe = require "ust/pipe"
local quat = require "ust/quaternion"

local general = {}

general.basePt = pipe.new * {
    coor.xyz(-0.5, -0.5, 0),
    coor.xyz(0.5, -0.5, 0),
    coor.xyz(0.5, 0.5, 0),
    coor.xyz(-0.5, 0.5, 0)
}

general.surfaceOf = function(size, center, ...)
    local tr = {...}
    return general.basePt
        * pipe.map(function(f) return (f .. coor.scale(size) * coor.trans(center)) end)
        * pipe.map(function(f) return func.fold(tr, f, function(v, m) return v .. m end) end)
end

general.withTag = function(tag)
    return pipe.map(function(m)
        return func.with(m, {
            tag = tag
        })
    end)
end

general.newModel = function(m, ...)
    return {
        id = m,
        transf = coor.mul(...)
    }
end

general.mRot = function(vec)
    return coor.scaleX(vec:length()) * quat.byVec(coor.xyz(1, 0, 0), (vec)):mRot()
end

general.linkingLane = function(f, t) return ((t - f):length2() > 1e-2 and (t - f):length2() < 562500) and general.newModel("ust/linking_lane.mdl", general.mRot(t - f), coor.trans(f)) or nil end
general.unitLane = function(f, t) return ((t - f):length2() > 1e-2 and (t - f):length2() < 562500) and general.newModel("ust/person_lane.mdl", general.mRot(t - f), coor.trans(f)) or nil end


general.preparedEdges = function(edges) return edges * coor.make end


return general
