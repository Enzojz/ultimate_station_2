function data()
    return {
        numLanes = 1,
        streetWidth = 3.0,
        sidewalkWidth = 0.0,
        sidewalkHeight = .00,
        yearFrom = 1800,
        yearTo = 1800,
        aiLock = true,
        country = false,
        speed = 100.0,
        type = "one way new small",
        name = _("MENU_STREET_ASPHALT"),
        desc = _("MENU_STREET_ASPHALT_DEC"),
        categories = {"one-way"},
        borderGroundTex = "street_border.lua",
        transportModesSidewalk = { },
        materials = {
            streetPaving = {
                name = "ust/paving/asphalt_street.mtl",
                size = { 8.0, 8.0 }
            },		
            streetBus = {
                name = "street/new_medium_bus.mtl",
                size = {12, 2.7}
            },
            streetTram = {
                name = "street/new_medium_tram_paving.mtl",
                size = {2.0, 2.0}
            },
            streetTramTrack = {
                name = "street/new_medium_tram_track.mtl",
                size = {2.0, 2.0}
            },
            crossingLane = {
                name = "street/new_medium_lane.mtl",
                size = {4.0, 4.0}
            },
            crossingTram = {
                name = "street/new_medium_tram_paving.mtl",
                size = {2.0, 2.0}
            },
            crossingTramTrack = {
                name = "street/new_medium_tram_track.mtl",
                size = {2.0, 2.0}
            },
            catenary = {
                name = "street/tram_cable.mtl"
            }
        },
        assets = {
        },
        catenary = {
            pole = {
                name = "asset/tram_pole.mdl",
                assets = {"asset/tram_pole_light.mdl"}
            },
            poleCrossbar = {
                name = "asset/tram_pole_crossbar.mdl",
                assets = {"asset/tram_pole_light.mdl"}
            },
            poleDoubleCrossbar = {
                name = "asset/tram_pole_double_crossbar.mdl",
                assets = {"asset/tram_pole_light.mdl"}
            },
            isolatorStraight = "asset/cable_isolator.mdl",
            isolatorCurve = "asset/cable_isolator.mdl",
            junction = "asset/cable_junction.mdl"
        },
        cost = 20.0,
    }
end
