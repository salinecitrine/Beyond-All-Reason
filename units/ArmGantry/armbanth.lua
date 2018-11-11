return {
	armbanth = {
		acceleration = 0.103,
		airsightdistance = 1100,
		brakerate = 0.654,
		buildcostenergy = 300000,
		buildcostmetal = 14000,
		buildpic = "ARMBANTH.DDS",
		buildtime = 276000,
		canmove = true,
		category = "KBOT WEAPON ALL NOTSUB NOTAIR NOTHOVER SURFACE CANBEUW",
		collisionvolumeoffsets = "0 -10 0",
		collisionvolumescales = "51 79 51",
		collisionvolumetype = "CylY",
		corpse = "DEAD",
		description = "Assault Mech",
		energymake = 12,
		energystorage = 120,
		explodeas = "bantha",
		footprintx = 3,
		footprintz = 3,
		idleautoheal = 25,
		idletime = 900,
		mass = 999999995904,
		maxdamage = 62000,
		maxslope = 17,
		maxvelocity = 1.52,
		maxwaterdepth = 12,
		movementclass = "VKBOT3",
		name = "Bantha",
		nochasecategory = "VTOL",
		objectname = "ARMBANTH",
		pushresistant = true,
		seismicsignature = 0,
		selfdestructas = "banthaSelfd",
		selfdestructcountdown = 10,
		sightdistance = 617,
		turninplaceanglelimit = 140,
		turninplacespeedlimit = 1.089,
		turnrate = 1056,
		upright = true,
		customparams = {
			techlevel = 3,
			paralyzemultiplier = 0.9,
			customrange = 460,
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "4.58798065186 -1.75430091553 -5.00808410645",
				collisionvolumescales = "66.5059539795 21.8749981689 69.125361816406",
				collisionvolumetype = "Box",
				damage = 21000,
				description = "Bantha Wreckage",
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 20,
				hitdensity = 100,
				metal = 8249,
				object = "ARMBANTH_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 10500,
				description = "Bantha Heap",
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 4,
				hitdensity = 100,
				metal = 3300,
				object = "3X3A",
                collisionvolumescales = "55.0 4.0 6.0",
                collisionvolumetype = "cylY",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = { 
 			 pieceExplosionGenerators = { 
 				"deathceg3",
 				"deathceg4",
 			}, 
			explosiongenerators = {
				[1] = "custom:barrelshot-medium",
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
				[1] = "krogok1",
			},
			select = {
				[1] = "krogsel1",
			},
		},
		weapondefs = {
			armbantha_fire = {
				accuracy = 100,
				areaofeffect = 64,
				avoidfeature = false,
				burnblow = true,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				explosiongenerator = "custom:genericshellexplosion-medium",
				impulseboost = 0,
				impulsefactor = 0,
				intensity = 4,
				name = "Close-quarters impulsion blaster",
				noselfdamage = true,
				proximitypriority = 1,
				range = 465,
				reloadtime = 0.7,
				rgbcolor = "0.05 0.05 1",
				size = 1,
				thickness = 2.4,
				coreThickness = 0.75,
				soundhit = "xplosml3",
				soundhitwet = "sizzle",
				soundhitwetvolume = 0.5,
				soundstart = "Lasrhvy2",
				tolerance = 10000,
				turret = true,
				weapontype = "LaserCannon",
				weaponvelocity = 400,
				damage = {
					default = 365,
					subs = 5,
				},
			},
			bantha_rocket = {
				areaofeffect = 96,
				avoidfeature = false,
				canattackground = false,
				craterareaofeffect = 96,
				craterboost = 0,
				cratermult = 0,
				cegTag = "missiletrailsmall-starburst",
                explosiongenerator = "custom:genericshellexplosion-large",
				firestarter = 70,
				impulseboost = 0.123,
				impulsefactor = 0.123,
				model = "exphvyrock",
				name = "Heavy g2g/g2a guided starburst missile launcher",
				noselfdamage = true,
				proximitypriority = -1,
				range = 860,
				reloadtime = 2.75,
				smoketrail = false,
				soundhit = "xplosml2",
				soundhitwet = "splsmed",
				soundhitwetvolume = 0.5,
				soundstart = "rapidrocket3",
				startvelocity = 250,
				targetable = 0,
				texture1 = "trans",
				texture2 = "armsmoketrail",
                texture3 = "null",
				tolerance = 9000,
				tracks = true,
				turnrate = 50000,
				weaponacceleration = 200,
				weapontimer = 0.35,
				weapontype = "StarburstLauncher",
				weaponvelocity = 1500,
				damage = {
					default = 360,
					subs = 5,
				},
				customparams = {
					bar_model = "corkbmissl1.s3o",
					light_mult = 3.5,
					light_radius_mult = 1.05,
					light_color = "1 0.6 0.17",
					expl_light_mult = 1.15,
					expl_light_radius_mult = 1.15,
					expl_light_life_mult = 1.15,
					expl_light_color = "1 0.5 0.05",
					expl_light_heat_radius_mult = 1.5,
				},
			},
			tehlazerofdewm = {
				areaofeffect = 14,
				avoidfeature = false,
				beamtime = 1.05,
				corethickness = 0.3,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				energypershot = 100,
				explosiongenerator = "custom:genericshellexplosion-medium-beam",
				impulseboost = 0,
				impulsefactor = 0,
				laserflaresize = 11,
				name = "High-energy long-range g2g/g2a lazor of DEEEEEEWWWWWWMMMMMM",
				noselfdamage = true,
				range = 800,
				reloadtime = 5,
				rgbcolor = "0.2 0.2 1",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundhitwetvolume = 0.5,
				soundstart = "annigun1",
				soundtrigger = 1,
				targetmoveerror = 0.2,
				thickness = 4,
				tolerance = 10000,
				turret = true,
				weapontype = "BeamLaser",
				weaponvelocity = 1500,
				damage = {
					commanders = 1200,
					default = 4000,
					subs = 5,
				},
				customparams = {
					light_radius_mult = "1.5",		-- used by light_effects widget
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "ARMBANTHA_FIRE",
				onlytargetcategory = "NOTSUB",
			},
			[2] = {
				badtargetcategory = "VTOL GROUNDSCOUT",
				def = "TEHLAZEROFDEWM",
				onlytargetcategory = "NOTSUB",
			},
			[3] = {
				badtargetcategory = "VTOL GROUNDSCOUT",
				def = "BANTHA_ROCKET",
				onlytargetcategory = "NOTSUB",
			},
		},
	},
}
