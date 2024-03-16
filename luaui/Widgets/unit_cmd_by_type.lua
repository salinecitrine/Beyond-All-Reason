function widget:GetInfo()
	return {
		name = "Set Target by Unit Type",
		desc = "Hold down Alt and give an area command centered on a unit of the type to restrict the command to",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true
	}
end

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

local function distributeCommands(sourceIDs, targetIDs, cmdCallback)
	local sourceCmdIndex = {}
	for sourceIndex = 1, #sourceIDs do
		local sourceID = sourceIDs[sourceIndex]
		for targetIndex = 1, #targetIDs do
			local targetID = targetIDs[targetIndex]

			if targetIndex % #targetIDs == sourceIndex % #targetIDs or sourceIndex % #sourceIDs == targetIndex % #sourceIDs then
				sourceCmdIndex[sourceID] = (sourceCmdIndex[sourceID] or 0) + 1
				cmdCallback(sourceID, targetID, sourceCmdIndex[sourceID])
			end
		end
	end
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

	local newCmds = {}
	for i = 1, #areaUnits do
		local unitID = areaUnits[i]
		if SpringGetUnitAllyTeam(unitID) ~= allyTeam and SpringGetUnitDefID(unitID) == filterUnitDefID then
			local newCmdOpts = {}
			if #newCmds ~= 0 or cmdOpts.shift then
				newCmdOpts = { "shift" }
			end
			newCmds[#newCmds + 1] = { CMD_SET_TARGET, { unitID }, newCmdOpts }
		end
	end

	if #newCmds > 0 then
		local selectedUnits = Spring.GetSelectedUnits()
		Spring.GiveOrderArrayToUnitArray(selectedUnits, newCmds)
		return true
	end
end


