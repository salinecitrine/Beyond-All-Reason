return {
	corsok = {
		activatewhenbuilt = true,
		acceleration = 0.01731,
		brakerate = 0.01731,
		buildcostenergy = 12000,
		buildcostmetal = 950,
		builder = false,
		buildpic = "CORSOK.DDS",
		buildtime = 27000,
		canattack = true,
		canguard = true,
		canmove = true,
		canpatrol = true,
		canstop = 1,
		cantbetransported = true,
		category = "ALL HOVER MOBILE WEAPON NOTSUB NOTSHIP NOTAIR SURFACE EMPABLE",
		collisionvolumeoffsets = "0 3 0",
		collisionvolumescales = "52 40 58",
		collisionvolumetype = "CylY",
		corpse = "dead",
		explodeas = "hugeexplosiongeneric",
		footprintx = 4,
		footprintz = 4,
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 4200,
		maxslope = 16,
		maxvelocity = 1.51,
		maxwaterdepth = 0,
		movementclass = "HHOVER4",
		nochasecategory = "VTOL",
		objectname = "Units/CORSOK.s3o",
		radardistance = 0,
		script = "Units/corsok.cob",
		selfdestructas = "hugeExplosionGenericSelfd",
		sightdistance = 650,
		sonardistance = 700,
		turninplace = true,
		turninplaceanglelimit = 90,
		turninplacespeedlimit = 1.056,
		turnrate = 290,
		waterline = 7,
		customparams = {
			unitgroup = 'weapon',
			normaltex = "unittextures/cor_normal.dds",
			subfolder = "corgantry",
			techlevel = 3,
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				damage = 7000,
				featuredead = "heap",
				featurereclamate = "smudge01",
				footprintx = 4,
				footprintz = 4,
				height = 15,
				hitdensity = 100,
				metal = 588,
				object = "Units/corsok_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "tree1reclamate",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "85.0 14.0 6.0",
				collisionvolumetype = "cylY",
				damage = 3500,
				featurereclamate = "smudge01",
				footprintx = 4,
				footprintz = 4,
				height = 4,
				hitdensity = 100,
				metal = 221,
				object = "Units/cor4x4d.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "tree1reclamate",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:waterwake-small-hover",
				[2] = "custom:bowsplash-small-hover",
				[3] = "custom:hover-wake-large",
			},
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
				[1] = "hovlgok2",
			},
			select = {
				[1] = "hovlgsl2",
			},
		},
		weapondefs = {
			corsok_laser = {
				areaofeffect = 20,
				avoidfeature = false,
				burnblow = true,
				collideenemy = true,
				corethickness = 0.23,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				duration = 10,
				edgeeffectiveness = 0.85,
				energypershot = 1000,
				explosiongenerator = "custom:laserhit-large-green",
				impulseboost = 0,
				impulsefactor = 0,
				largebeamlaser = true,
				name = "Disruptor Phaser",
				noexplode = true,
				range = 725,
				reloadtime = 9,
				rgbcolor  = "0.000 0.4 0.2",
				rgbcolor2 = "0.25 1.000 0.85",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "annigun1",
				soundtrigger = 1,
				thickness = 2.5,
				tolerance = 525,
				tracks = true,
				turnrate = 20000,
				turret = true,
				weapontimer = 3,
				weapontype = "BeamLaser",
				weaponvelocity = 1000,
				damage = {
					default = 2150,
					subs = 1000,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "CORSOK_LASER",
				onlytargetcategory = "NOTSUB",
			},
		},
	},
}
