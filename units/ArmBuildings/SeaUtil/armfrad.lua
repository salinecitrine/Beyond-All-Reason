return {
	armfrad = {
		acceleration = 0,
		activatewhenbuilt = true,
		brakerate = 0,
		buildangle = 16384,
		buildcostenergy = 1000,
		buildcostmetal = 130,
		buildpic = "ARMFRAD.DDS",
		buildtime = 1800,
		canattack = false,
		canrepeat = false,
		category = "ALL NOTLAND NOTSUB NOWEAPON NOTSHIP NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 -15 0",
		collisionvolumescales = "36 59 36",
		collisionvolumetype = "CylY",
		corpse = "DEAD",
		description = "Early Warning System",
		energymake = 4,
		energyuse = 4,
		explodeas = "mediumBuildingexplosiongeneric",
		footprintx = 3,
		footprintz = 3,
		icontype = "building",
		idleautoheal = 5,
		idletime = 1800,
		losemitheight = 52,
		maxdamage = 99,
		maxslope = 10,
		minwaterdepth = 5,
		name = "Floating Radar Tower",
		objectname = "ARMFRAD",
		onoffable = true,
		radardistance = 2100,
		radaremitheight = 52,
		seismicsignature = 0,
		selfdestructas = "mediumBuildingExplosionGenericSelfd",
		sightdistance = 760,
		waterline = 1,
		yardmap = "wwwwwwwww",
		customparams = {
			
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "0.0 -14.8080587891 -0.125",
				collisionvolumescales = "45.9999694824 25.4694824219 42.75",
				collisionvolumetype = "Box",
				damage = 59,
				description = "Floating Radar Tower Wreckage",
				energy = 0,
				footprintx = 3,
				footprintz = 3,
				height = 40,
				hitdensity = 100,
				metal = 83,
				object = "ARMFRAD_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = { 
 			pieceExplosionGenerators = { 
				"deathceg2",
				"deathceg3",
			},
		},
		sounds = {
			activate = "radar1",
			canceldestruct = "cancel2",
			deactivate = "radarde1",
			underattack = "warning1",
			working = "radar1",
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			select = {
				[1] = "radar1",
			},
		},
	},
}
