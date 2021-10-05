local unitName = Spring.I18N('units.names.armfboy')

return {
	armfboy = {
		acceleration = 0.138,
		brakerate = 0.43125,
		buildcostenergy = 12000,
		buildcostmetal = 1500,
		buildpic = "ARMFBOY.DDS",
		buildtime = 22397,
		canmove = true,
		category = "BOT WEAPON ALL NOTSUB NOTAIR NOTHOVER SURFACE EMPABLE",
		collisionvolumeoffsets = "0 0 0",
		collisionvolumescales = "34 40 42",
		collisionvolumetype = "Box",
		corpse = "DEAD",
		description = Spring.I18N('units.descriptions.armfboy'),
		explodeas = "largeExplosionGeneric",
		footprintx = 3,
		footprintz = 3,
		idleautoheal = 5,
		idletime = 1800,
		mass = 5001,
		maxdamage = 7000,
		maxslope = 20,
		maxvelocity = 1,
		maxwaterdepth = 25,
		movementclass = "HBOT3",
		name = unitName,
		nochasecategory = "VTOL",
		objectname = "Units/ARMFBOY.s3o",
		power = 5950, --compensation for XP rank with high AoE weapons
		pushresistant = true,
		script = "Units/ARMFBOY.cob",
		seismicsignature = 0,
		selfdestructas = "largeExplosionGenericSelfd",
		sightdistance = 510,
		turninplace = true,
		turninplaceanglelimit = 90,
		turninplacespeedlimit = 0.66,
		turnrate = 368,
		customparams = {
			model_author = "Kaiser, PtaQ",
			normaltex = "unittextures/Arm_normal.dds",
			subfolder = "armbots/t2",
			techlevel = 2,
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "1.35855102539 -5.79698309326 2.2872467041",
				collisionvolumescales = "33.431427002 25.3690338135 53.5839233398",
				collisionvolumetype = "Box",
				damage = 5000,
				description = Spring.I18N('units.dead', { name = unitName }),
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 9,
				hitdensity = 100,
				metal = 1008,
				object = "Units/armfboy_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "all",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "35.0 4.0 6.0",
				collisionvolumetype = "cylY",
				damage = 3500,
				description = Spring.I18N('units.heap', { name = unitName }),
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				hitdensity = 100,
				metal = 403,
				object = "Units/arm2X2A.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "all",
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:barrelshot-large",
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
				[1] = "mavbot1",
			},
			select = {
				[1] = "capture2",
			},
		},
		weapondefs = {
			arm_fatboy_notalaser = {
				areaofeffect = 240,
				avoidfeature = false,
				craterareaofeffect = 240,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.85,
				energypershot = 0,
				explosiongenerator = "custom:genericshellexplosion-large-aoe",
				gravityaffected = "true",
				impulseboost = 0.4,
				impulsefactor = 0.4,
				name = "Heavy AoE g2g plasma cannon",
				noselfdamage = true,
				range = 700,
				reloadtime = 6.73333,
				soundhit = "bertha6",
				soundhitwet = "splslrg",
				soundstart = "BERTHA1",
				turret = true,
				weapontype = "Cannon",
				weaponvelocity = 307.40851,
				damage = {
					bombers = 111,
					default = 800,
					fighters = 111,
					subs = 100,
					vtol = 111,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "ARM_FATBOY_NOTALASER",
				onlytargetcategory = "SURFACE",
			},
		},
	},
}
