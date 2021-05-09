function data()
    return {
        info = {
            severityAdd = "NONE",
            severityRemove = "CRITICAL",
            name = _("name"),
            description = _("desc"),
            authors = {
                {
                    name = "Enzojz",
                    role = "CREATOR",
                    text = "Idea, Scripting, Modeling",
                    steamProfile = "enzojz",
                    tfnetId = 27218,
                }
            },
            tags = {"Train Station", "Station"},
        },
        postRunFn = function(settings, params)
            local models = {}
            for id, path in pairs(api.res.modelRep.getAll()) do
                if path:match("ust/platform/[%w_-]+_tl.mdl") then
                    local m = api.res.modelRep.get(id)
                    local bbMax = m.boundingInfo.bbMax
                    local bbMin = m.boundingInfo.bbMin
                    models[path] = {x = bbMax.x, y = bbMax.y, w = bbMax.x - bbMin.x, h = bbMax.y - bbMin.y, d = 2, t = true, l = true}
                elseif path:match("ust/platform/[%w_-]+_br.mdl") then
                    local m = api.res.modelRep.get(id)
                    local bbMax = m.boundingInfo.bbMax
                    local bbMin = m.boundingInfo.bbMin
                    models[path] = {x = bbMin.x, y = bbMin.y, w = bbMax.x - bbMin.x, h = bbMax.y - bbMin.y, d = 2, b = true, r = true}
                end
            end
            
            local con = api.res.constructionRep.get(api.res.constructionRep.find("station/rail/ust/ust.con"))
            -- con.updateScript.fileName = "construction/station/rail/ust/ust.updateFn"
            con.updateScript.params = {
                models = models
            }
        end
    }
end
