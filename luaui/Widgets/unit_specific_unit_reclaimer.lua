
function widget:GetInfo()
	return {
		name			= "Specific Unit Reclaimer",
		desc			= "Hold down Alt or Ctrl and give an area reclaim order, centered on a unit of the type to reclaim.",
		author		= "Google Frog",
		date			= "May 12, 2008",
		license	 = "GNU GPL, v2 or later",
		layer		 = 0,
		enabled	 = true	--	loaded by default?
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

local CMD_RECLAIM = CMD.RECLAIM
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
	-- true if we want to target enemies, false otherwise
	targetEnemy = Game.reclaimAllowEnemies and spGetUnitAllyTeam(id) ~= allyTeam
	-- units in range, filtered to allies if not targetEnemy
	areaUnits

condition:
		-- ctrl/alt + want to target enemies + unit is an enemy -> target all enemies
		(targetEnemy and spGetUnitAllyTeam(unitID) ~= allyTeam)
		-- alt + don't want to target enemies + matching unit type -> target all allies with same unitDefID
	 or (options.alt and not targetEnemy and spGetUnitDefID(unitID) == unitDef )
	 	-- ctrl + don't want to target enemies -> target all allies
	 or (options.ctrl and not targetEnemy)

]]--

function widget:CommandNotify(id, params, options)

	if id ~= CMD_RECLAIM or #params ~= 4 then
		return
	end
	if options.alt or options.ctrl then

		local cx, cy, cz = params[1], params[2], params[3]

		local mx,my,mz = spWorldToScreenCoords(cx, cy, cz)
		local cType,id = spTraceScreenRay(mx,my)

		if cType == "unit" then

			local cr = params[4]


			local targetEnemy = reclaimEnemy and spGetUnitAllyTeam(id) ~= allyTeam
			local unitDef = spGetUnitDefID(id)
			local areaUnits = spGetUnitsInCylinder(cx ,cz , cr)

			if not targetEnemy then
				areaUnits = spGetUnitsInCylinder(cx ,cz , cr, team)
			end

			local selUnits = false
			local count = 0
			for i=1,#areaUnits do
				local unitID    = areaUnits[i]
				if (targetEnemy and spGetUnitAllyTeam(unitID) ~= allyTeam) or (options.alt and not targetEnemy and spGetUnitDefID(unitID) == unitDef ) or  (options.ctrl and not targetEnemy) then
					local cmdOpts = {}
					if count ~= 0 or options.shift then
						cmdOpts = {"shift"}
					end
					if not selUnits then selUnits = spGetSelectedUnits() end
					spGiveOrderToUnitArray( selUnits, CMD_RECLAIM, {unitID}, cmdOpts)
					count = count + 1
				end
			end
			return true

		end
	end


end


