local unitName = Spring.I18N('units.names.corcan')

return {
	corcan = {
		acceleration = 0.138,
		brakerate = 0.6486,
		buildcostenergy = 9300,
		buildcostmetal = 560,
		buildpic = "CORCAN.DDS",
		buildtime = 11734,
		canmove = true,
		category = "BOT MOBILE WEAPON ALL NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE EMPABLE",
		collisionvolumeoffsets = "0.0 0.0 0.0",
		collisionvolumescales = "28.0 27.0 25.0",
		collisionvolumetype = "box",
		corpse = "DEAD",
		description = Spring.I18N('units.descriptions.corcan'),
		explodeas = "mediumexplosiongeneric",
		footprintx = 2,
		footprintz = 2,
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 4850,
		maxslope = 14,
		maxvelocity = 1.25,
		maxwaterdepth = 21,
		movementclass = "BOT3",
		name = unitName,
		nochasecategory = "VTOL",
		objectname = "Units/CORCAN.s3o",
		script = "Units/CORCAN.cob",
		seismicsignature = 0,
		selfdestructas = "mediumExplosionGenericSelfd",
		sightdistance = 350,
		turninplace = true,
		turninplaceanglelimit = 90,
		turninplacespeedlimit = 0.825,
		turnrate = 1115.5,
		upright = true,
		customparams = {
			model_author = "FireStorm",
			normaltex = "unittextures/cor_normal.dds",
			subfolder = "corbots/t2",
			techlevel = 2,
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "0.220962524414 -3.57609763184 -0.162803649902",
				collisionvolumescales = "39.2589111328 21.1636047363 24.3341522217",
				collisionvolumetype = "Box",
				damage = 3500,
				description = Spring.I18N('units.dead', { name = unitName }),
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 20,
				hitdensity = 100,
				metal = 339,
				object = "Units/corcan_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "35.0 4.0 6.0",
				collisionvolumetype = "cylY",
				damage = 2500,
				description = Spring.I18N('units.heap', { name = unitName }),
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 136,
				object = "Units/cor2X2F.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			pieceexplosiongenerators = {
				[1] = "deathceg2",
				[2] = "deathceg3",
				[3] = "deathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			underattack = "warning1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "kbcormov",
			},
			select = {
				[1] = "kbcorsel",
			},
		},
		weapondefs = {
			cor_canlaser = {
				areaofeffect = 8,
				avoidfeature = false,
				beamtime = 0.16,
				beamttl = 2.4,
				corethickness = 0.21,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				energypershot = 75,
				explosiongenerator = "custom:laserhit-medium-green",
				firestarter = 90,
				impactonly = 1,
				impulseboost = 0,
				impulsefactor = 0,
				laserflaresize = 5.5,
				name = "HighEnergyLaser",
				noselfdamage = true,
				range = 275,
				reloadtime = 0.8,
				rgbcolor = "0.027 0.40 0.027",
				rgbcolor2 = "0.9 1 0.9",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "lasrhvy3",
				soundtrigger = 1,
				targetmoveerror = 0.2,
				thickness = 4.0,
				tolerance = 10000,
				turret = true,
				weapontype = "BeamLaser",
				weaponvelocity = 700,
				damage = {
					bombers = 5,
					default = 275,
					fighters = 5,
					subs = 5,
					vtol = 5,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "COR_CANLASER",
				onlytargetcategory = "NOTSUB",
			},
		},
	},
}
