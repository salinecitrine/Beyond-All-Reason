function widget:GetInfo()
	return {
	name      = "Red Resource Bars",
	desc      = "Requires Red UI Framework",
	author    = "Regret",
	date      = "29 may 2015",
	license   = "GNU GPL, v2 or later",
	layer     = 0,
	enabled   = true, --enabled by default
	handler   = true, --can use widgetHandler:x()
	}
end

local barTexture = LUAUI_DIRNAME.."Images/resbar.dds"
local barGlowCenterTexture = LUAUI_DIRNAME.."Images/barglow-center.dds"
local barGlowEdgeTexture = LUAUI_DIRNAME.."Images/barglow-edge.dds"

local NeededFrameworkVersion = 8
local CanvasX,CanvasY = 1280,734 --resolution in which the widget was made (for 1:1 size)
--1272,734 == 1280,768 windowed

local vsx, vsy = gl.GetViewSizes()
local widgetScale = (1 + (vsx*vsy / 7500000))
  	
local glowSizeMultiplier = 2.5
local Config = {
	metal = {
		n = 'metal',
		px = 370,py = -0.5, --default start position
		sx = 260,sy = 29, --background size
		
		barsy = 4, --thickness of the actual bar
		fontsize = 11,
		
		margin = 5, --distance from background border
		
		padding = 3*widgetScale, -- for border effect
		color2 = {1,1,1,0.025}, -- for border effect
		
		expensefadetime = 0.25, --fade effect time, in seconds
		
		cbackground = {0,0,0,0.66}, --color {r,g,b,alpha}
		cborder = {0,0,0,0.75},
		cbarbackground = {0,0,0,1},
		cbar = {1,1,1,1},
		cindicator = {1,0,0,0.8},
		
		cincome = {0,1,0,1},
		cpull = {1,0,0,1},
		cexpense = {1,0,0,1},
		ccurrent = {1,1,1,1},
		cstorage = {1,1,1,1},
		
		dragbutton = {2,3}, --middle mouse button
		tooltip = {
			background ="In CTRL+F11 mode: Hold \255\255\255\1middle mouse button\255\255\255\255 to drag the resource bar.\n\n"..
			"\255\255\255\1Leftclick\255\255\255\255 on the bar to set team share.",
			income = "Your metal income.",
			pull = "Your metal pull.",
			expense = "Your metal expense, same as pull if not shown.",
			storage = "Your maximum metal storage.",
			current = "Your current metal storage.",
		},
	},
	
	energy = {
		n = 'energy',
		px = 636,py = -0.5,
		sx = 260,sy = 29, --background size
		
		barsy = 4, --width of the actual bar
		fontsize = 11,
		
		margin = 5,
		
		padding = 3*widgetScale, -- for border effect
		color2 = {1,1,1,0.025}, -- for border effect
		
		expensefadetime = 0.25,
		
		cbackground = {0,0,0,0.66},
		cborder = {0,0,0,0.75},
		cbarbackground = {0,0,0,1},
		cbar = {1,1,0,1},
		cindicator = {1,0,0,0.8},
		
		cincome = {0,1,0,1},
		cpull = {1,0,0,1},
		cexpense = {1,0,0,1},
		ccurrent = {1,1,1,1},
		cstorage = {1,1,1,1},
		
		dragbutton = {2,3}, --middle mouse button
		tooltip = {
			background ="In CTRL+F11 mode: Hold \255\255\255\1middle mouse button\255\255\255\255 to drag the resource bar.\n\n"..
			"\255\255\255\1Leftclick\255\255\255\255 on the bar to set team share.",
			income = "Your energy income.",
			pull = "Your energy pull.",
			expense = "Your energy expense, same as pull if not shown.",
			storage = "Your maximum energy storage.",
			current = "Your current energy storage.",
		},
	},
}

local sGetMyTeamID = Spring.GetMyTeamID
local sGetTeamResources = Spring.GetTeamResources
local sSetShareLevel = Spring.SetShareLevel
local sformat = string.format

local function IncludeRedUIFrameworkFunctions()
	New = WG.Red.New(widget)
	Copy = WG.Red.Copytable
	SetTooltip = WG.Red.SetTooltip
	GetSetTooltip = WG.Red.GetSetTooltip
	Screen = WG.Red.Screen
	GetWidgetObjects = WG.Red.GetWidgetObjects
end

local function RedUIchecks()
	local color = "\255\255\255\1"
	local passed = true
	if (type(WG.Red)~="table") then
		Spring.Echo(color..widget:GetInfo().name.." requires Red UI Framework.")
		passed = false
	elseif (type(WG.Red.Screen)~="table") then
		Spring.Echo(color..widget:GetInfo().name..">> strange error.")
		passed = false
	elseif (WG.Red.Version < NeededFrameworkVersion) then
		Spring.Echo(color..widget:GetInfo().name..">> update your Red UI Framework.")
		passed = false
	end
	if (not passed) then
		widgetHandler:ToggleWidget(widget:GetInfo().name)
		return false
	end
	IncludeRedUIFrameworkFunctions()
	return true
end

local function AutoResizeObjects() --autoresize v2
	if (LastAutoResizeX==nil) then
		LastAutoResizeX = CanvasX
		LastAutoResizeY = CanvasY
	end
	local lx,ly = LastAutoResizeX,LastAutoResizeY
	local vsx,vsy = Screen.vsx,Screen.vsy
	if ((lx ~= vsx) or (ly ~= vsy)) then
		local objects = GetWidgetObjects(widget)
		local scale = vsy/ly
		local skippedobjects = {}
		for i=1,#objects do
			local o = objects[i]
			local adjust = 0
			if ((o.movableslaves) and (#o.movableslaves > 0)) then
				adjust = (o.px*scale+o.sx*scale)-vsx
				if (((o.px+o.sx)-lx) == 0) then
					o._moveduetoresize = true
				end
			end
			if (o.px) then o.px = o.px * scale end
			if (o.py) then o.py = o.py * scale end
			if (o.sx) then o.sx = o.sx * scale end
			if (o.sy) then o.sy = o.sy * scale end
			if (o.fontsize) then o.fontsize = o.fontsize * scale end
			if (adjust > 0) then
				o._moveduetoresize = true
				o.px = o.px - adjust
				for j=1,#o.movableslaves do
					local s = o.movableslaves[j]
					s.px = s.px - adjust/scale
				end
			elseif ((adjust < 0) and o._moveduetoresize) then
				o._moveduetoresize = nil
				o.px = o.px - adjust
				for j=1,#o.movableslaves do
					local s = o.movableslaves[j]
					s.px = s.px - adjust/scale
				end
			end
		end
		LastAutoResizeX,LastAutoResizeY = vsx,vsy
	end
end

local function short(n,f)
	if (f == nil) then
		f = 0
	end
	if (n > 9999999) then
		return sformat("%."..f.."fm",n/1000000)
	elseif (n > 9999) then
		return sformat("%."..f.."fk",n/1000)
	else
		return sformat("%."..f.."f",n)
	end
end

local function createbar(r)
	local background2 = {"rectanglerounded",
		px=r.px+r.padding,py=r.py+r.padding,
		sx=r.sx-r.padding-r.padding,sy=r.sy-r.padding-r.padding,
		color=r.color2,
	}
	
	local imagesize = r.sy / 1.33
	local image = {"rectangle",
		px=r.px+r.padding,py=r.py+r.padding,
		sx=imagesize, sy=imagesize,
		color={0,0,0,0},
		border={0,0,0,0},
		texture = LUAUI_DIRNAME.."Images/energy.png",
	}
	if r.n == 'metal' then
		image.texture = LUAUI_DIRNAME.."Images/metal.png"
	end
	local background = {"rectanglerounded",
		px=r.px,py=r.py,
		sx=r.sx,sy=r.sy,
		color=r.cbackground,
		border=r.cborder,
		movable=r.dragbutton,
		obeyscreenedge = true,
		
		padding=r.padding,
		
		--overridecursor = true,
		overrideclick = {1},
		onupdate=function(self)
			background2.px = self.px + self.padding
			background2.py = self.py + self.padding
			background2.sx = self.sx - self.padding - self.padding
			background2.sy = self.sy - self.padding - self.padding
			local imagesize = self.sy / 1.33
			image.px = self.px+self.padding+((self.sy-self.padding-self.padding-imagesize)/2)
			image.py = self.py+self.padding+((self.sy-self.padding-self.padding-imagesize)/2)
		end,
	}
	
	New(background)
	New(background2)
	New(image)
	
	local number = {"text",
		px=0,py=background.py+r.margin,fontsize=r.fontsize,
		caption="+99999.9m",
		options="n", --disable colorcodes
	}
	
	local income = New(number)
	income.color = r.cincome
	
	local barbackground = {"rectangle",
		px=background.px+(income.getwidth()*1.22)-r.margin,py=income.py,
		sx=background.sx-income.getwidth()*1.25,sy=r.barsy,
		color=r.cbarbackground,
		texture = barTexture,
		texturecolor = {0.15,0.15,0.15,1},
	}

	local barborder = Copy(barbackground)
	barborder.color = nil
	barborder.border = r.cborder
	barborder.texture = nil
	barborder.texturecolor = nil
	
	local bar = Copy(barbackground)
	bar.color = r.cbar
	bar.texture = barTexture
	bar.texturecolor = r.cbar
	--bar.texture = nil
	--bar.texturecolor = nil
	--bar[1] = "rectanglerounded"
	--bar.roundedsize = barbackground.sy / 0.8
	
	local glowSize = bar.sy * glowSizeMultiplier
	local barGlowCenter = Copy(bar)
	barGlowCenter.py = bar.py - glowSize
	barGlowCenter.sy = bar.sy + glowSize + glowSize
	if r.n == 'energy' then
		barGlowCenter.color = {1,1,0,0}
		barGlowCenter.texturecolor = {1,1,0,0.06}
	else
		barGlowCenter.color = {1,1,1,0}
		barGlowCenter.texturecolor = {1,1,1,0.055}
	end
	barGlowCenter.texture = barGlowCenterTexture
	barGlowCenter[1] = "rectangle"
	
	local barGlowLeft = Copy(barGlowCenter)
	barGlowLeft.texture = barGlowEdgeTexture
	barGlowLeft.px = bar.px - (glowSize + glowSize)
	barGlowLeft.sx = glowSize + glowSize
	barGlowLeft.texture = barGlowEdgeTexture
	
	local barGlowRight = Copy(barGlowLeft)
	barGlowRight.px = bar.px + bar.sx + glowSize + glowSize
	barGlowRight.sx = -(glowSize + glowSize)
	
	local shareindicator = Copy(barbackground)
	shareindicator.color = r.cindicator
	shareindicator.py = shareindicator.py -2
	shareindicator.sx = barbackground.sy
	shareindicator.sy = shareindicator.sy +4
	shareindicator.border = r.cborder
	shareindicator.texture = barTexture
	shareindicator.texturecolor = r.cindicator
	
	New(barbackground)
	New(barGlowLeft)
	New(barGlowRight)
	New(barGlowCenter)
	New(bar)
	New(barborder)
	New(shareindicator)
	
	bar.overridecursor = true
	
	local pull = New(number)
	pull.color = r.cpull
	--pull.py = pull.py+pull.fontsize
	pull.py = barbackground.py+barbackground.sy+r.margin
	if ((barbackground.sy+r.margin)<r.fontsize) then
		pull.py = barbackground.py+r.fontsize
	end
	
	local expense = New(pull)
	expense.color = r.cexpense
	expense.px = barbackground.px
	
	local current = New(pull)
	current.color = r.ccurrent
	
	local storage = New(pull)
	storage.color = r.cstorage
	
	expense.effects = {
		fadein_at_activation = r.expensefadetime,
		fadeout_at_deactivation = r.expensefadetime,
	}
	
	background.movableslaves = {
		barbackground,barborder,bar,shareindicator,
		income,pull,expense,current,storage,
		barGlowCenter, barGlowLeft, barGlowRight
	}
	
	-- smaller fontsize for fontsize of income and pull
	income.fontsize = r.fontsize*0.93
	pull.fontsize = r.fontsize*0.93
	storage.fontsize = r.fontsize*0.88
	
	--tooltip
	background.mouseover = function(mx,my,self) SetTooltip(r.tooltip.background) end
	income.mouseover = function(mx,my,self) SetTooltip(r.tooltip.income) end
	pull.mouseover = function(mx,my,self) SetTooltip(r.tooltip.pull) end
	expense.mouseover = function(mx,my,self) SetTooltip(r.tooltip.expense) end
	storage.mouseover = function(mx,my,self) SetTooltip(r.tooltip.storage) end
	current.mouseover = function(mx,my,self) SetTooltip(r.tooltip.current) end
	
	return {
		["background"] = background,
		["background2"] = background2,
		["barbackground"] = barbackground,
		["bar"] = bar,
		["barGlowCenter"] = barGlowCenter,
		["barGlowLeft"] = barGlowLeft,
		["barGlowRight"] = barGlowRight,
		["barborder"] = barborder,
		["shareindicator"] = shareindicator,
		["income"] = income,
		["pull"] = pull,
		["expense"] = expense,
		["current"] = current,
		["storage"] = storage,
		
		margin = r.margin
	}
end

local function updatebar(b,res)
	local r = {sGetTeamResources(sGetMyTeamID(),res)} -- 1 = cur 2 = cap 3 = pull 4 = income 5 = expense 6 = share
	local barbackpx = b.barbackground.px
	local barbacksx = b.barbackground.sx
	
	b.bar.sx = r[1]/r[2]*barbacksx
	if (b.bar.sx > barbacksx) then --happens on gamestart and storage destruction
		b.bar.sx = barbacksx
	end
	local glowSize = b.bar.sy * glowSizeMultiplier
	b.barGlowCenter.sx = b.bar.sx
	b.barGlowRight.px = b.bar.px + b.bar.sx + glowSize + glowSize
	b.barGlowRight.sx = -(glowSize + glowSize)
	
	b.income.caption = "+ "..short(r[4],(r[4] < 10 and 1 or 0))
	b.pull.caption = "- "..short(r[3],(r[3] < 10 and 1 or 0))
	b.current.caption = short(r[1])
	b.storage.caption = short(r[2])
	
	--align numbers
	b.income.px = barbackpx - b.income.getwidth() -b.margin*2.2
	b.pull.px = barbackpx - b.pull.getwidth() -b.margin*2.2
	b.current.px = barbackpx + barbacksx/2 - b.current.getwidth()/2
	b.storage.px = barbackpx + barbacksx - b.storage.getwidth()
	
	if (r[3]~=r[5]) then
		b.expense.active = nil --activate
		b.expense.caption = "  - "..short(r[5],(r[5] < 10 and 1 or 0))
	else
		b.expense.active = false
	end
	
	b.shareindicator.px = barbackpx+r[6]*barbacksx-b.shareindicator.sx/2
end

function widget:Initialize()
	PassedStartupCheck = RedUIchecks()
	if (not PassedStartupCheck) then return end
	
	metal = createbar(Config.metal)
	energy = createbar(Config.energy)
	
	metal.barbackground.mouseheld = {
		{1,function(mx,my,self)
			sSetShareLevel("metal",(mx-self.px)/self.sx)
			updatebar(metal,"metal")
		end},
	}
	energy.barbackground.mouseheld = {
		{1,function(mx,my,self)
			sSetShareLevel("energy",(mx-self.px)/self.sx)
			updatebar(energy,"energy")
		end},
	}
	
	Spring.SendCommands("resbar 0")
	AutoResizeObjects()
end

function widget:Shutdown()
	Spring.SendCommands("resbar 1")
end

local gameFrame = 0
local lastFrame = -1
function widget:GameFrame(n)
	gameFrame = n
end

function widget:Update()
	AutoResizeObjects()
	if (gameFrame ~= lastFrame) then
		updatebar(energy,"energy")
		updatebar(metal,"metal")
		lastFrame = gameFrame
	end
end

--save/load stuff
--currently only position
function widget:GetConfigData() --save config
	if (PassedStartupCheck) then
		local vsy = Screen.vsy
		local unscale = CanvasY/vsy --needed due to autoresize, stores unresized variables
		Config.metal.px = metal.background.px * unscale
		Config.metal.py = metal.background.py * unscale
		Config.energy.px = energy.background.px * unscale
		Config.energy.py = energy.background.py * unscale
		return {Config=Config}
	end
end
function widget:SetConfigData(data) --load config
	if (data.Config ~= nil) then
		Config.metal.px = data.Config.metal.px
		Config.metal.py = data.Config.metal.py
		Config.energy.px = data.Config.energy.px
		Config.energy.py = data.Config.energy.py
	end
end
