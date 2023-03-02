function data()
    return {
        numLanes = 1,
        streetWidth = 3.0,
        sidewalkWidth = 0.0,
        sidewalkHeight = .00,
        yearFrom = 1925,
        yearTo = 0,
        aiLock = true,
        country = false,
        speed = 30.0,
        type = "one way new small",
        name = _("Small one-way street"),
        desc = _("One-lane one-way street with a speed limit of %2%."),
        categories = {"one-way"},
        borderGroundTex = "street_border.lua",
        materials = {
            streetPaving = {
                name = "ust/paving/brick_street.mtl",
                size = {12.0, 12.0}
            },
            streetBus = {
                name = "street/new_medium_bus.mtl",
                size = {12, 2.7}
            },
            streetTram = {
                name = "street/old_medium_tram_paving.mtl",
                size = {2.0, 2.0}
            },
            streetTramTrack = {
                name = "street/old_medium_tram_track.mtl",
                size = {2.0, 2.0}
            },
            crossingLane = {
                name = "street/old_small_lane.mtl",
                size = {12.0, 2.5}
            },
            crossingTram = {
                name = "street/old_medium_tram_paving.mtl",
                size = {2.0, 2.0}
            },
            crossingTramTrack = {
                name = "street/old_medium_tram_track.mtl",
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
        signalAssetName = "asset/ampel.mdl",
        cost = 20.0,
    }
end
