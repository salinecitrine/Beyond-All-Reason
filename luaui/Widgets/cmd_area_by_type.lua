function widget:GetInfo()
	return {
		name = "Issue Area Commands Filtered by Unit Type",
		desc = "Hold down Alt and give an area command centered on a unit to restrict the command to units of that type",
		license = "GNU GPL, v2 or later",
		layer = 999999,
		enabled = true
	}
end

local function cmdIDString(cmdID)
	if cmdID < 0 then
		return "{Build " .. UnitDefs[-cmdID].translatedHumanName .. "} (" .. cmdID .. ")"
	else
		if CMD[cmdID] ~= nil then
			return CMD[cmdID] .. " (" .. cmdID .. ")"
		else
			return "unknown command (" .. cmdID .. ")"
		end
	end
end

local function unitIDString(unitID)
	if not unitID then
		return nil
	end
	local unitDefID = Spring.GetUnitDefID(unitID)
	if UnitDefs[unitDefID] == nil then
		return unitID .. " (" .. (unitDefID or "nil") .. ")"
	end

	local unitName = UnitDefs[unitDefID].translatedHumanName
	if unitName ~= nil then
		return unitID .. " (" .. unitName .. ")"
	end
end

local function unitDefIDString(unitDefID)
	if not unitDefID then
		return nil
	end
	if UnitDefs[unitDefID] == nil then
		return "invalid (" .. (unitDefID or "nil") .. ")"
	end

	local unitName = UnitDefs[unitDefID].translatedHumanName
	if unitName ~= nil then
		return unitName .. " (" .. unitDefID .. ")"
	end
end

local function distributeTargets(callback, sourceIDs, targetIDs)
	local sourceCount = #sourceIDs
	local targetCount = #targetIDs

	for i = 0, math.max(sourceCount, targetCount) do
		callback(
			sourceIDs[(i % sourceCount) + 1],
			targetIDs[(i % targetCount) + 1],
			math.floor(i / sourceCount) + 1,
			math.floor(i / targetCount) + 1
		)
	end
end

local function distanceXZ(a, b)
	return math.diag(a[1] - b[1], 0, a[3] - b[3])
end

local function map(tbl, callback)
	local result = {}
	for i = 1, #tbl do
		result[i] = callback(tbl[i], i, tbl)
	end
	return result
end

local function clamp(min, max, num)
	if (num < min) then
		return min
	elseif (num > max) then
		return max
	end
	return num
end

local CMD_SET_TARGET = 34923

-- combine with smart area reclaim?

--[[
possible options or concerns:
* can target enemies
* can target allies
* can target units
* can target features (and how to only choose "similar" features)
* distribute commands (always/never/space)
* when to send shift
]]--
local commandSpecs = {
	[CMD_SET_TARGET] = {
		validTargetTypes = {
			unit = true,
		},
		canTargetAllies = false,
		canTargetEnemies = true,
		--color = { 1.0, 0.75, 1.0, 0.25 },
		color = { 1, 0.75, 0, 0.3 },
	},
	[CMD.RECLAIM] = {
		-- reclaim for units only
		validTargetTypes = {
			unit = true,
		},
		color = { 0.5, 1.0, 0.4, 0.4 },
	},
	[CMD.LOAD_UNITS] = {
		validTargetTypes = {
			unit = true,
		},
		color = { 0.4, 0.9, 0.9, 0.3 },
	},
	[CMD.REPAIR] = {
		validTargetTypes = {
			unit = true,
		},
		color = { 1.0, 0.9, 0.2, 0.4 },
	},
	[CMD.RESURRECT] = {
		-- check for feature rez name instead of unitdefid
		validTargetTypes = {
			feature = true,
		},
		color = { 0.9, 0.5, 1.0, 0.25 },
	},
	[CMD.CAPTURE] = {
		validTargetTypes = {
			unit = true,
		},
		color = { 1.0, 1.0, 0.3, 0.3 },
	},
	[CMD.ATTACK] = {
		validTargetTypes = {
			unit = true,
		},
		color = { 1.0, 0.2, 0.2, 0.3 },
	},
}

for cmdID, spec in pairs(commandSpecs) do
	if spec.color then
		spec.color = {
			spec.color[1],
			spec.color[2],
			spec.color[3],
			spec.color[4] * 100,
		}
		spec.color = map(spec.color, function(v)
			return clamp(0, 1, v)
		end)
	end
end

--[[
existing widget summary
* mod keys
	* alt -> enemy: restrict team
	          ally: restrict type
	* ctrl -> restrict team
* load distributes commands too
]]--

local SpringGetUnitDefID = Spring.GetUnitDefID
local SpringGetUnitAllyTeam = Spring.GetUnitAllyTeam

local myAllyTeam = Spring.GetMyAllyTeamID()

local function findTargets(spec, targetType, targetID, cmdX, cmdZ, cmdRadius)
	if not spec.validTargetTypes[targetType] then
		return
	end

	local targetAllyTeamID = targetType == "unit" and SpringGetUnitAllyTeam(targetID) or nil
	local targetUnitDefID = SpringGetUnitDefID(targetID)

	local areaUnits = Spring.GetUnitsInCylinder(cmdX, cmdZ, cmdRadius)

	local targetIDs = {}
	for i = 1, #areaUnits do
		local unitID = areaUnits[i]
		if SpringGetUnitAllyTeam(unitID) == targetAllyTeamID and SpringGetUnitDefID(unitID) == targetUnitDefID then
			targetIDs[#targetIDs + 1] = unitID
		end
	end

	return targetIDs
end

local function maybeRemoveSelf()
	if Spring.GetSpectatingState() or Spring.IsReplay() then
		widgetHandler:RemoveWidget()
	end
end

function widget:PlayerChanged(playerID)
	maybeRemoveSelf()
	myAllyTeam = Spring.GetMyAllyTeamID()
end

function widget:Initialize()
	maybeRemoveSelf()
end

local function getTargetFilterType(targetType, targetID)
	if targetType == "unit" then
		return Spring.GetUnitDefID(targetID)
	elseif targetType == "feature" then
		local resName = Spring.GetFeatureResurrect(targetID)
		if string.len(resName) > 0 then
			return resName
		end
	end
end

local function getTargetPosition(targetType, targetID)
	if targetType == "unit" then
		return Spring.GetUnitPosition(targetID)
	elseif targetType == "feature" then
		return Spring.GetFeaturePosition(targetID)
	end
end

local function getTargetRadius(targetType, targetID)
	if targetType == "unit" then
		return UnitDefs[Spring.GetUnitDefID(targetID)].radius
	elseif targetType == "feature" then
		return UnitDefs[Spring.GetUnitDefID(targetID)].radius
	end
end

local activeCmdState = nil
function widget:MousePress(x, y, button)
	if button ~= 1 then
		activeCmdState = nil
		return
	end

	local cmdIndex, cmdID, cmdType, cmdName = Spring.GetActiveCommand()

	Spring.Echo("[MousePress] " .. table.toString({
		pos = { x, y },
		button = button,
		cmd = {
			cmdIndex = cmdIndex,
			cmdID = cmdID,
			cmdType = cmdType,
			cmdName = cmdName,
		},
	}))

	-- check for alt when drawing because it can change between mouse press and release
	if commandSpecs[cmdID] then
		local targetType, targetID = Spring.TraceScreenRay(x, y)

		if targetType ~= "unit" and targetType ~= "feature" then
			activeCmdState = nil
			return
		end

		Spring.Echo("Spring.GetFeatureResurrect", Spring.GetFeatureResurrect(targetID))

		local _, worldPosition = Spring.TraceScreenRay(x, y, true, true)
		activeCmdState = {
			spec = commandSpecs[cmdID],
			cmdID = cmdID,
			position = { x, y },
			targetType = targetType,
			targetId = targetID,
			targetFilterType = getTargetFilterType(targetType, targetID),
			targetAllyTeamID = targetType == "unit" and SpringGetUnitAllyTeam(targetID) or nil,
			position = worldPosition,
		}
	else
		activeCmdState = nil
	end
end

function widget:Update()
	if activeCmdState == nil then
		return
	end

	local cmdIndex, cmdID, cmdType, cmdName = Spring.GetActiveCommand()

	if not commandSpecs[cmdID] then
		activeCmdState = nil
	end
end

function widget:DrawWorld()
	if activeCmdState == nil then
		return
	end

	local alt, ctrl, meta, shift = Spring.GetModKeyState()

	if not alt then
		return
	end

	local mx, my = Spring.GetMouseState()
	local _, worldPosition = Spring.TraceScreenRay(mx, my, true, true)

	if not worldPosition then
		return
	end

	local cmdRadius = distanceXZ(activeCmdState.position, worldPosition)

	local targetIDs = findTargets(
		activeCmdState.spec,
		activeCmdState.targetType,
		activeCmdState.targetId,
		activeCmdState.position[1],
		activeCmdState.position[3],
		cmdRadius
	)

	if not targetIDs then
		return
	end

	if activeCmdState.spec and activeCmdState.spec.color then
		gl.Color(unpack(activeCmdState.spec.color))
	else
		gl.Color(1.0, 1.0, 1.0, 1.0)
	end
	for _, targetID in ipairs(targetIDs) do
		local ux, uy, uz = getTargetPosition(activeCmdState.targetType, targetID)
		local ur = getTargetRadius(activeCmdState.targetType, targetID)
		gl.DrawGroundCircle(ux, 0, uz, UnitDefs[Spring.GetUnitDefID(targetID)].radius * 0.9, 32)
		gl.DrawGroundCircle(ux, 0, uz, UnitDefs[Spring.GetUnitDefID(targetID)].radius * 1.0, 32)
	end
end

function widget:DrawScreenEffects()
	if activeCmdState == nil then
		return
	end

	local mx, my = Spring.GetMouseState()

	gl.Color(1.0, 1.0, 1.0, 1.0)
	gl.Text(string.format(
		"%s | %s | %s | %s | %s",
		activeCmdState.targetType or "<none>",
		type(activeCmdState.targetId) == "number" and unitIDString(activeCmdState.targetId) or "<none>",
		unitDefIDString(activeCmdState.targetFilterType) or "<none>",
		activeCmdState.targetAllyTeamID or "<none>",
		Spring.GetFeatureResurrect(activeCmdState.targetId) or "<none>"
	), mx + 15, my - 12, 40, "ao")
end

local function createCommand(cmdID, cmdOpts, targetID, cmdIndex)
	local newCmdOpts = {}
	if #cmdIndex >= 1 or cmdOpts.shift then
		newCmdOpts = { "shift" }
	end
	return { cmdID, { targetID }, newCmdOpts }
end

function widget:CommandNotify(cmdID, cmdParams, cmdOpts)
	activeCmdState = nil
	if not commandSpecs[cmdID] or #cmdParams ~= 4 or not cmdOpts.alt then
		return
	end

	Spring.Echo("[CommandNotify] " .. table.toString({
		cmdID = cmdIDString(cmdID),
		cmdParams = cmdParams,
		cmdOpts = cmdOpts,
	}))

	local spec = commandSpecs[cmdID]

	local cmdX, cmdY, cmdZ = cmdParams[1], cmdParams[2], cmdParams[3]

	local mouseX, mouseY = Spring.WorldToScreenCoords(cmdX, cmdY, cmdZ)
	local targetType, targetId = Spring.TraceScreenRay(mouseX, mouseY)

	if not spec.validTargetTypes[targetType] then
		return
	end

	local cmdRadius = cmdParams[4]

	local targetIDs = findTargets(
		spec, targetType, targetId, cmdX, cmdZ, cmdRadius
	)

	local cmdArray = map(targetIDs, function(targetID, index)
		local newCmdOpts = {}
		if index > 1 or cmdOpts.shift then
			newCmdOpts = { "shift" }
		end
		return { cmdID, { targetID }, newCmdOpts }
	end)

	if #cmdArray > 0 then
		local selectedUnits = Spring.GetSelectedUnits()
		Spring.GiveOrderArrayToUnitArray(selectedUnits, cmdArray)
		return true
	end
end


