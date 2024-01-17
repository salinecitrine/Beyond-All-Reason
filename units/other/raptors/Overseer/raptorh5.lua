return {
	raptorh5 = {
		maxacc = 0.92,
		autoheal = 8,
		maxdec = 0.92,
		energycost = 5201,
		metalcost = 251,
		builddistance = 425,
		builder = true,
		buildpic = "raptors/raptorh5.DDS",
		buildtime = 18000,
		canattack = true,
		canguard = true,
		canmove = true,
		canpatrol = true,
		canrepair = false,
		canreclaim = false,
		canrestore = false,
		canstop = "1",
		capturable = false,
		category = "BOT MOBILE WEAPON ALL NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE RAPTOR EMPABLE",
		collisionvolumeoffsets = "0 -10 2",
		collisionvolumescales = "37 75 90",
		collisionvolumetype = "box",
		defaultmissiontype = "Standby",
		explodeas = "ROOST_DEATH",
		floater = false,
		footprintx = 3,
		footprintz = 3,
		hidedamage = 1,
		leavetracks = true,
		maneuverleashlength = 640,
		mass = 3000,
		health = 8900,
		maxslope = 18,
		speed = 111.0,
		maxwaterdepth = 0,
		movementclass = "RAPTORSMALLHOVER",
		nanocolor = "0.7 0.15 0.15",
		noautofire = false,
		nochasecategory = "VTOL SPACE",
		objectname = "Raptors/brain_bug.s3o",
		script = "Raptors/raptorh5.cob",
		selfdestructas = "ROOST_DEATH",
		side = "THUNDERBIRDS",
		sightdistance = 1500,
		smoothanim = true,
		trackoffset = 10,
		trackstrength = 3,
		trackstretch = 1,
		tracktype = "RaptorTrack",
		trackwidth = 35,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 1840,
		unitname = "raptorh5",
		upright = false,
		waterline = 45,
		workertime = 450,
		customparams = {
			subfolder = "other/raptors",
			model_author = "KDR_11k, Beherith",
			normalmaps = "yes",
			normaltex = "unittextures/chicken_l_normals.png",
			--treeshader = "no",
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:blood_spray",
				[2] = "custom:blood_explode",
				[3] = "custom:dirt",
				[4] = "custom:blank",
			},
			pieceexplosiongenerators = {
				[1] = "blood_spray",
				[2] = "blood_spray",
				[3] = "blood_spray",
			},
		},
		weapondefs = {
			controlblob = {
				areaofeffect = 120,
				collidefriendly = 0,
				collidefeature = 0,
				avoidfeature = 0,
				avoidfriendly = 0,
				camerashake = 0,
				--cegtag = "blood_trail_xl",
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.55,
				--explosiongenerator = "custom:blood_explode_xl",
				impulseboost = 0,
				impulsefactor = 0,
				intensity = 0.85,
				interceptedbyshieldtype = 0,
				name = "ControlBlob",
				noselfdamage = true,
				predictboost = 1,
				proximitypriority = -2,
				range = 1000,
				reloadtime = 0.5,
				rgbcolor = "0.42 0.07 0.07",
				size = 0,
				sizeDecay = 0,
				stages = 0,
				--soundhit = "bloodsplash3",
				--soundstart = "bugattack",
				tolerance = 5000,
				turret = true,
				weapontype = "Cannon",
				--weapontimer = 3,
				weaponvelocity = 10000,
				damage = {
					default = 1,
				},
			},
			weapon = {
				areaofeffect = 72,
				avoidfeature = 0,
				avoidfriendly = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.3,
				explosiongenerator = "custom:raptorspike-large-sparks-burn",
				impulseboost = 2.2,
				impulsefactor = 1,
				interceptedbyshieldtype = 0,
				model = "Raptors/spike.s3o",
				name = "Claws",
				noselfdamage = true,
				range = 200,
				reloadtime = 3,
				soundstart = "smallraptorattack",
				targetborder = 1,
				tolerance = 5000,
				turret = true,
				waterweapon = true,
				weapontimer = 0.1,
				weapontype = "Cannon",
				weaponvelocity = 500,
				damage = {
					raptor = 1,
					default = 1,
				},
			},
		},
		weapons = {
			[1] = {
				def = "WEAPON",
				maindir = "0 0 1",
				maxangledif = 180,
				--onlytargetcategory = "NOTAIR",
			},
			[2] = {
				def = "CONTROLBLOB",
				maindir = "0 0 1",
				maxangledif = 180,
				--onlytargetcategory = "NOTAIR",
			},
		},
	},
}
