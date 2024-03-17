function widget:GetInfo()
	return {
		name = "Set Target by Unit Type",
		desc = "Hold down Alt and give an area command centered on a unit of the type to restrict the command to",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true
	}
end

local function _distributeTargets_iter(state, i)
	local sourceCount = #(state.sourceIDs)
	local targetCount = #(state.targetIDs)

	if i >= math.max(sourceCount, targetCount) then
		return nil
	end

	local sourceIndex = (i % sourceCount) + 1
	local sourceSelectCount = math.floor(i / sourceCount) + 1

	if not state.canSourceMultiple and sourceSelectCount > 1 then
		return nil
	end

	local targetIndex = (i % targetCount) + 1
	local targetSelectCount = math.floor(i / targetCount) + 1

	if not state.canTargetMultiple and targetSelectCount > 1 then
		return nil
	end

	i = i + 1

	return i, state.sourceIDs[sourceIndex], state.targetIDs[targetIndex], sourceSelectCount, targetSelectCount
end

local function distributeTargets(sourceIDs, targetIDs, canSourceMultiple, canTargetMultiple)
	return _distributeTargets_iter, {
		sourceIDs = sourceIDs,
		targetIDs = targetIDs,
		canSourceMultiple = canSourceMultiple,
		canTargetMultiple = canTargetMultiple,
	}, 0
end

--todo: highlight units as circle is drawn? check unit_smart_select.lua

local CMD_SET_TARGET = 34923

-- combine with smart area reclaim?

--[[
possible options or concerns:
* can target enemies
* can target allies
* distribute commands (always/never/space)
* when to send shift
]]--
local commandSpecs = {
	[CMD_SET_TARGET] = {},
	[CMD.RECLAIM] = {}, -- reclaim for units only
	[CMD.LOAD] = {},
	[CMD.REPAIR] = {},
	[CMD.RESURRECT] = {}, -- check for feature rez name instead of unitdefid
	[CMD.CAPTURE] = {},
	[CMD.AREA_ATTACK] = {}, -- attack?
}

--[[
existing widget summary
* mod keys
	* alt -> enemy: restrict team
	          ally: restrict type
	* ctrl -> restrict team
* load distributes commands
]]--

local SpringGetUnitDefID = Spring.GetUnitDefID
local SpringGetUnitAllyTeam = Spring.GetUnitAllyTeam

local allyTeam = Spring.GetMyAllyTeamID()
local gameStarted

local function createCommand(cmdID, cmdOpts, targetID, cmdIndex)
	local newCmdOpts = {}
	if #cmdIndex >= 1 or cmdOpts.shift then
		newCmdOpts = { "shift" }
	end
	return { cmdID, { targetID }, newCmdOpts }
end

local function maybeRemoveSelf()
	if Spring.GetSpectatingState() or Spring.IsReplay() then
		widgetHandler:RemoveWidget()
	end
end

function widget:PlayerChanged(playerID)
	maybeRemoveSelf()
end

function widget:Initialize()
	maybeRemoveSelf()
end

function widget:CommandNotify(cmdID, cmdParams, cmdOpts)
	if not commandSpecs[cmdID] or #cmdParams ~= 4 or not cmdOpts.alt then
		return
	end

	local cmdX, cmdY, cmdZ = cmdParams[1], cmdParams[2], cmdParams[3]

	local mouseX, mouseY = Spring.WorldToScreenCoords(cmdX, cmdY, cmdZ)
	local targetType, targetId = Spring.TraceScreenRay(mouseX, mouseY)

	if targetType ~= "unit" then
		return
	end

	local cmdRadius = cmdParams[4]

	local filterUnitDefID = SpringGetUnitDefID(targetId)
	local areaUnits = Spring.GetUnitsInCylinder(cmdX, cmdZ, cmdRadius)

	local targetIDs = {}
	for i = 1, #areaUnits do
		local unitID = areaUnits[i]
		if SpringGetUnitAllyTeam(unitID) ~= allyTeam and SpringGetUnitDefID(unitID) == filterUnitDefID then
			targetIDs[#targetIDs + 1] = unitID
		end
	end

	if #targetIDs > 0 then
		local selectedUnits = Spring.GetSelectedUnits()
		Spring.GiveOrderArrayToUnitArray(selectedUnits, targetIDs)
		return true
	end
end


