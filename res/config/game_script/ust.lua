local dump = require "luadump"
local script = {
    
    guiHandleEvent = function(id, name, param)
        -- dump()({
        --     id = id,
        --     name = name,
        -- })
    end
}

function data()
    return script
end
