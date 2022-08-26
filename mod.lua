local dump = require "luadump"
function data()
    return {
        info = {
            severityAdd = "NONE",
            severityRemove = "CRITICAL",
            name = _("MOD_NAME"),
            description = _("MOD_DESC"),
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
            local tracks = api.res.trackTypeRep.getAll()
            local trackModuleList = {}
            local trackIconList = {}
            local trackNames = {}
            for __, trackName in pairs(tracks) do
                local track = api.res.trackTypeRep.get(api.res.trackTypeRep.find(trackName))
                local trackName = trackName:match("(.+).lua")
                local baseFileName = ("station/rail/ust/tracks/%s"):format(trackName)
                for __, catenary in pairs({false, true}) do
                    local mod = api.type.ModuleDesc.new()
                    mod.fileName = ("%s%s.module"):format(baseFileName, catenary and "_catenary" or "")
                    
                    mod.availability.yearFrom = track.yearFrom
                    mod.availability.yearTo = track.yearTo
                    mod.cost.price = 0
                    -- mod.buildMode = "SINGLE"
                    mod.description.name = track.name .. (catenary and _("MENU_WITH_CAT") or "")
                    mod.description.description = track.desc .. (catenary and _("MENU_WITH_CAT") or "")
                    mod.description.icon = track.icon
                    
                    mod.type = "ust_track"
                    mod.order.value = 0
                    mod.metadata = {
                        typeName = "ust_track",
                        isTrack = true,
                        width = track.trackDistance,
                        height = track.railBase + track.railHeight,
                        typeId = 1,
                        scriptName = "construction/station/rail/ust/track",
                        preProcessAdd = "preProcessAdd",
                        preProcessRemove = "preProcessRemove",
                        slotSetup = "slotSetup",
                        preClassify = "preClassify",
                    }
                    
                    mod.category.categories = catenary and { "ust_cat_track_cat" } or { "ust_cat_track" }
                    
                    mod.updateScript.fileName = "construction/station/rail/ust/track.updateFn"
                    mod.updateScript.params = {
                        trackType = trackName .. ".lua",
                        catenary = catenary,
                        trackWidth = track.trackDistance
                    }
                    
                    mod.getModelsScript.fileName = "construction/station/rail/ust/track.getModelsFn"
                    mod.getModelsScript.params = {}
                    
                    api.res.moduleRep.add(mod.fileName, mod, true)
                end
                table.insert(trackModuleList, baseFileName)
                table.insert(trackIconList, track.icon)
                table.insert(trackNames, track.name)
            end

            for index, name in pairs(api.res.moduleRep.getAll()) do
                if name:match("station/rail/ust/data") then
                    print(name)
                    api.res.moduleRep.setVisible(index, false)
                end
            end

            local con = api.res.constructionRep.get(api.res.constructionRep.find("station/rail/ust/ust.con"))
            -- con.updateScript.fileName = "construction/station/rail/ust/ust.updateFn"
            con.updateScript.params = {
            }
        end
    }
end
