
function widget:GetInfo()
	return {
		name		= "Specific Unit Loader",
		desc		= "Hold down Alt or Ctrl and give an area load order, centered on a unit of the type to load.",
		author		= "Google Frog, doo edit for load commands",
		date		= "May 12, 2008",
		license	 	= "GNU GPL, v2 or later",
		layer		= 0,
		enabled	 	= true	--	loaded by default?
	}
end

local team = Spring.GetMyTeamID()
local allyTeam = Spring.GetMyAllyTeamID()

-- Speedups

local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spGiveOrderToUnitArray = Spring.GiveOrderToUnitArray
local spGetCommandQueue = Spring.GetCommandQueue
local spGetSelectedUnits = Spring.GetSelectedUnits
local spGetUnitsInCylinder = Spring.GetUnitsInCylinder
local spWorldToScreenCoords = Spring.WorldToScreenCoords
local spTraceScreenRay = Spring.TraceScreenRay
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spGetModKeyState = Spring.GetModKeyState

local reclaimEnemy = Game.reclaimAllowEnemies

local CMD_LOAD_UNITS = CMD.LOAD_UNITS
local CMD_STOP = CMD.STOP

local gameStarted


function maybeRemoveSelf()
    if Spring.GetSpectatingState() and (Spring.GetGameFrame() > 0 or gameStarted) then
        widgetHandler:RemoveWidget()
    end
end

function widget:GameStart()
    gameStarted = true
    maybeRemoveSelf()
end

function widget:PlayerChanged(playerID)
    maybeRemoveSelf()
end

function widget:Initialize()
    if Spring.IsReplay() or Spring.GetGameFrame() > 0 then
        maybeRemoveSelf()
    end
end

--[[
run on:
	alt or ctrl

vars:
	-- centered unitID, unitDefID
	id, unitDef
	-- potential target unit id
	unitID
	-- true if we want to target enemies, false otherwise (todo: probably wrong to check reclaimAllowEnemies)
	targetEnemy = Game.reclaimAllowEnemies and spGetUnitAllyTeam(id) ~= allyTeam
	-- units in range, filtered to allies if not targetEnemy
	preareaUnits
	-- preareaUnits, filtered by condition
	areaUnits

condition (same as reclaimer):
		-- ctrl/alt + want to target enemies + unit is an enemy -> target all enemies
		(targetEnemy and spGetUnitAllyTeam(unitID) ~= allyTeam)
		-- alt + don't want to target enemies + matching unit type -> target all allies with same unitDefID
	 or (options.alt and not targetEnemy and spGetUnitDefID(unitID) == unitDef )
	 	-- ctrl + don't want to target enemies -> target all allies
	 or (options.ctrl and not targetEnemy)

]]--

function widget:CommandNotify(id, params, options)

	if id ~= CMD_LOAD_UNITS or #params ~= 4 then
		return
	end
	if options.alt or options.ctrl then

		local cx, cy, cz = params[1], params[2], params[3]

		local mx,my,mz = spWorldToScreenCoords(cx, cy, cz)
		local cType,id = spTraceScreenRay(mx,my)

		if cType == "unit" then

			local cr = params[4]

			local selUnits = spGetSelectedUnits()

			local targetEnemy = reclaimEnemy and spGetUnitAllyTeam(id) ~= allyTeam
			local unitDef = spGetUnitDefID(id)
			local preareaUnits = spGetUnitsInCylinder(cx ,cz , cr)
			if not targetEnemy then
				preareaUnits = spGetUnitsInCylinder(cx ,cz , cr, team)
			end
			local countarea = 0
			local areaUnits = {}
			for i=1,#preareaUnits do
				local unitID = preareaUnits[i]
				if (targetEnemy and spGetUnitAllyTeam(unitID) ~= allyTeam) or (options.alt and not targetEnemy and spGetUnitDefID(unitID) == unitDef ) or  (options.ctrl and not targetEnemy) then
					countarea = countarea + 1
					areaUnits[countarea] = unitID
				end
			end
			for ct=1,#selUnits do
				local unitID = selUnits[ct]
				for i=1,#areaUnits do
					local areaUnitID = areaUnits[i]
					local cmdOpts = {}
					if options.shift then
						cmdOpts = {"shift"}
					end
					--    targetIndex %   targetCount == selectedIndex %   targetCount
					-- or targetIndex % selectedCount == selectedIndex % selectedCount

					-- distributes commands evenly
					if i%#areaUnits == ct%#areaUnits or ct%#selUnits == i%#selUnits then
						Spring.GiveOrderToUnit(unitID, CMD_LOAD_UNITS, {areaUnitID}, cmdOpts)
					end

				end
			end
			return true

		end
	end


end


