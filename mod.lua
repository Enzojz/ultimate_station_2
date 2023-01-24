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
            for i, trackName in pairs(tracks) do
                local track = api.res.trackTypeRep.get(api.res.trackTypeRep.find(trackName))
                local trackName = trackName:match("(.+).lua")

                local mod = api.type.ModuleDesc.new()
                mod.fileName = ("station/rail/ust/tracks/%s.module"):format(trackName)
                
                mod.availability.yearFrom = track.yearFrom
                mod.availability.yearTo = track.yearTo
                mod.cost.price = 0
                mod.description.name = track.name
                mod.description.description = track.desc
                mod.description.icon = track.icon
                
                mod.type = "ust_track"
                mod.order.value = i + 1
                mod.metadata = {
                    typeName = "ust_track",
                    isTrack = true,
                    width = track.trackDistance,
                    height = track.railBase + track.railHeight,
                    typeId = 1,
                    scriptName = "construction/station/rail/ust/struct/track",
                    preProcessAdd = "preProcessAdd",
                    preProcessRemove = "preProcessRemove",
                    slotSetup = "slotSetup",
                    preClassify = "preClassify",
                    -- postClassify = "postClassify",
                    gridization = "gridization"
                }
                
                mod.category.categories = {"ust_cat_track"}
                
                mod.updateScript.fileName = "construction/station/rail/ust/struct/track.updateFn"
                mod.updateScript.params = {
                    trackType = trackName .. ".lua",
                    trackWidth = track.trackDistance
                }
                
                mod.getModelsScript.fileName = "construction/station/rail/ust/struct/track.getModelsFn"
                mod.getModelsScript.params = {}
                
                api.res.moduleRep.add(mod.fileName, mod, true)
                table.insert(trackModuleList, mod.fileName)
                table.insert(trackIconList, track.icon)
                table.insert(trackNames, track.name)
            end
            
            local bridges = api.res.bridgeTypeRep.getAll()
            for index, bridgeName in pairs(bridges) do
                local bridge = api.res.bridgeTypeRep.get(index)
                
                local mod = api.type.ModuleDesc.new()
                mod.fileName = ("station/rail/ust/bridges/%s.module"):format(bridgeName:match("(.+).lua"))
                
                mod.availability.yearFrom = bridge.yearFrom
                mod.availability.yearTo = bridge.yearTo
                mod.cost.price = 0
                mod.description.name = bridge.name
                mod.description.description = ""
                mod.description.icon = bridge.icon
                
                mod.type = "ust_bridge"
                mod.order.value = index
                mod.metadata = {
                    typeName = "ust_bridge",
                    typeId = 25,
                    scriptName = "construction/station/rail/ust/struct/bridge",
                    preProcessAdd = "preProcessAdd",
                    preProcessRemove = "preProcessRemove",
                    slotSetup = "slotSetup",
                    addSlot = "addSlot",
                    classify = "classify"
                }
                
                mod.category.categories = {"ust_cat_bridge"}
                
                mod.updateScript.fileName = "construction/station/rail/ust/struct/bridge.updateFn"
                mod.updateScript.params = {
                    index = index,
                    name = bridgeName
                }
                
                mod.getModelsScript.fileName = "construction/station/rail/ust/struct/bridge.getModelsFn"
                mod.getModelsScript.params = {}
                
                api.res.moduleRep.add(mod.fileName, mod, true)
            end
            
            
            local tunnels = api.res.tunnelTypeRep.getAll()
            for index, tunnelName in pairs(tunnels) do
                local tunnel = api.res.tunnelTypeRep.get(index)
                
                local mod = api.type.ModuleDesc.new()
                mod.fileName = ("station/rail/ust/tunnels/%s.module"):format(tunnelName:match("(.+).lua"))
                
                mod.availability.yearFrom = tunnel.yearFrom
                mod.availability.yearTo = tunnel.yearTo
                mod.cost.price = 0
                mod.description.name = tunnel.name
                mod.description.description = ""
                mod.description.icon = tunnel.icon
                
                mod.type = "ust_tunnel"
                mod.order.value = index
                mod.metadata = {
                    typeName = "ust_tunnel",
                    typeId = 25,
                    scriptName = "construction/station/rail/ust/struct/tunnel",
                    preProcessAdd = "preProcessAdd",
                    preProcessRemove = "preProcessRemove",
                    slotSetup = "slotSetup",
                    addSlot = "addSlot",
                    classify = "classify"
                }
                
                mod.category.categories = {"ust_cat_tunnel"}
                
                mod.updateScript.fileName = "construction/station/rail/ust/struct/tunnel.updateFn"
                mod.updateScript.params = {
                    index = index,
                    name = tunnelName
                }
                
                mod.getModelsScript.fileName = "construction/station/rail/ust/struct/tunnel.getModelsFn"
                mod.getModelsScript.params = {}
                
                api.res.moduleRep.add(mod.fileName, mod, true)
            end
            
            for index, name in pairs(api.res.moduleRep.getAll()) do
                if name:match("station/rail/ust/data") then
                    api.res.moduleRep.setVisible(index, false)
                end
            end
            
            local con = api.res.constructionRep.get(api.res.constructionRep.find("station/rail/ust/ust.con"))
            con.createTemplateScript.fileName = "construction/station/rail/ust/ust.createTemplateFn"
            con.createTemplateScript.params = { trackModuleList = trackModuleList }
            
            local data = api.type.DynamicConstructionTemplate.new()
            for i = 1, #con.constructionTemplates[1].data.params do
                local p = con.constructionTemplates[1].data.params[i]
                local param = api.type.ScriptParam.new()
                param.key = p.key
                param.name = p.name
                if (p.key == "trackType") then
                    param.values = trackNames
                else
                    param.values = p.values
                end
                param.defaultIndex = p.defaultIndex or 0
                param.uiType = p.uiType
                data.params[i] = param
            end
            con.constructionTemplates[1].data = data
        end
    }
end
