function data()
	local t = { }

	t.name = _("Mock tracks")
	t.desc = _("Mock tracks for underground station")

	t.yearFrom = 1800
	t.yearTo = 1800

	t.shapeWidth = 4.0
	t.shapeStep = 4.0
	t.shapeSleeperStep = 8.0 / 13.0

	t.ballastHeight = .3
	t.ballastCutOff = .1

	t.sleeperBase = t.ballastHeight
	t.sleeperLength = .24
	t.sleeperWidth = 2.6
	t.sleeperHeight = .08
	t.sleeperCutOff = .04

	t.railTrackWidth = 1.435
	t.railBase = t.sleeperBase + t.sleeperHeight
	t.railHeight = .15
	t.railWidth = .07
	t.railCutOff = .02
    
    t.embankmentSlopeLow = 0.75
    t.embankmentSlopeHigh = 2.5

	t.catenaryBase = 5.917 + t.railBase + t.railHeight
	t.catenaryHeight = 1.35
	t.catenaryPoleDistance = 25.0

	t.trackDistance = 5.0

	t.speedLimit = 5.0 / 3.6
	t.speedCoeffs = { .9, 15.0, .63 }

	t.ballastMaterial = "track/ballast.mtl"
	t.sleeperMaterial = "track/transparent.mtl"
	t.railMaterial = "track/transparent.mtl"
	t.catenaryMaterial = "track/catenary.mtl"
	t.tunnelWallMaterial = "track/transparent.mtl"
	t.tunnelHullMaterial = "track/transparent.mtl"

	t.catenaryPoleModel = "mus/void.mdl"
	t.catenaryMultiPoleModel = "mus/void.mdl"
	t.catenaryMultiGirderModel = "mus/void.mdl"
	t.catenaryMultiInnerPoleModel = "mus/void.mdl"

	t.bumperModel = "mus/void.mdl"
	t.switchSignalModel = "railroad/switch_box.mdl"

	t.fillGroundTex = "ballast_fill_stone.lua"
	t.borderGroundTex = "ballast.lua"

	t.railModel ="mus/void.mdl"
	t.sleeperModel = "mus/void.mdl"
	t.trackStraightModel = {
		"mus/void.mdl",
		"mus/void.mdl",
		"mus/void.mdl",
		"mus/void.mdl",
	}
	
	t.cost = 0.0

	return t
end
