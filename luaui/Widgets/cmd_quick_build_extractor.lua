function widget:GetInfo()
	return {
		name = "Quick Build (mex/geo)",
		desc = "Adds ability to quickly place or upgrade mex/geothermal by right clicking.",
		author = "Hobo Joe, based on work by Google Frog, NTG, Chojin, Doo, Floris, and Tarte",
		version = "1.0",
		date = "Jan 2024",
		license = "GNU GPL, v2 or later",
		handler = true,
		layer = 1000,
		enabled = true  --  loaded by default?
	}
end

local CMD_MOVE = CMD.MOVE
local CMD_GUARD = CMD.GUARD
local CMD_RECLAIM = CMD.RECLAIM

local spGetGroundHeight = Spring.GetGroundHeight
local spGetActiveCommand = Spring.GetActiveCommand
local spGetMyTeamID = Spring.GetMyTeamID
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitPosition = Spring.GetUnitPosition

local extractorRadius = Game.extractorRadius

local geoPlacementRadius = 5000	-- (not actual ingame distance)
local mexPlacementRadius = 1600	-- (not actual ingame distance)

local mexConstructors
local geoConstructors
local mexBuildings
local geoBuildings


local drawUnitShape = false
local activeUnitShape

local selectedSpot
local selectedMex
local selectedGeo

local activeCmd
local buildCmd

function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

local isCloakableBuilder = {}
for unitDefID, unitDef in pairs(UnitDefs) do
	if unitDef.buildOptions[1] and unitDef.canCloak then
		isCloakableBuilder[unitDefID] = true
	end
end
local function unitIsCloaked(uDefId)
	return isCloakableBuilder[Spring.GetUnitDefID(uDefId)] and select(5,Spring.GetUnitStates(uDefId,false,true))
end


function widget:Initialize()

	if not WG.DrawUnitShapeGL4 then
		Spring.Echo("Missing draw shape, exiting")
		widget:Shutdown()
	end

	mexConstructors = WG["resource_spot_builder"].GetMexConstructors()
	geoConstructors = WG["resource_spot_builder"].GetGeoConstructors()

	mexBuildings = WG["resource_spot_builder"].GetMexBuildings()
	geoBuildings = WG["resource_spot_builder"].GetGeoBuildings()
end

local function clearGhostBuild()
	if WG.DrawUnitShapeGL4 and activeUnitShape then
		WG.StopDrawUnitShapeGL4(activeUnitShape)
		activeUnitShape = nil
	end
	selectedMex = nil
	selectedGeo = nil
	selectedSpot = nil
end

local selectedUnits = Spring.GetSelectedUnits()
function widget:SelectionChanged(sel)
	selectedUnits = sel
end

function widget:Update(dt)
	-- TODO: limit by time

	buildCmd = { }

	if not selectedUnits or #selectedUnits == 0 then
		Spring.Echo("No selected units")
		clearGhostBuild()
		return
	end

	local mx, my, mb, mmb, mb2 = Spring.GetMouseState()

	-- TODO: mouseover unit and upgrade behavior

	_, activeCmd = spGetActiveCommand()
	Spring.Echo("activeCmd", activeCmd)
	if activeCmd and (activeCmd < 0 or activeCmd == CMD_RECLAIM) then
		clearGhostBuild()
		return
	end


	local extractor
	local bestMex = WG['resource_spot_builder'].GetBestExtractorFromBuilders(selectedUnits, mexConstructors, mexBuildings)
	local bestGeo = WG['resource_spot_builder'].GetBestExtractorFromBuilders(selectedUnits, geoConstructors, geoBuildings)
	if not bestMex and not bestGeo then
		Spring.Echo("no best mex or best geo", bestMex, bestGeo)
		clearGhostBuild()
		return
	end

	-- check unit under cursor
	local type, rayParams = Spring.TraceScreenRay(mx, my)
	local unitUuid = type == 'unit' and rayParams or nil
	local unitDefID = type == 'unit' and spGetUnitDefID(rayParams) or nil

	if(unitUuid and unitDefID) then
		local unitIsMex = mexBuildings[unitDefID]
		local unitIsGeo = geoBuildings[unitDefID]
		Spring.Echo("unitIsMex, unitIsGeo", unitIsMex, unitIsGeo)
		if (unitIsMex or unitIsGeo) then
			local x, _, z = spGetUnitPosition(unitUuid)

			extractor = unitIsMex and bestMex or bestGeo
			Spring.Echo("extractor is", extractor)
			local canUpgrade = WG['resource_spot_builder'].ExtractorCanBeUpgraded(unitUuid, extractor)
			if not canUpgrade then
				clearGhostBuild()
				return
			end

			if unitIsMex then
				selectedSpot = WG["resource_spot_finder"].GetClosestMexSpot(x, z)
				selectedMex = bestMex
			else
				selectedSpot = WG["resource_spot_finder"].GetClosestGeoSpot(x, z)
				selectedGeo = bestGeo
			end
		else
			clearGhostBuild()
			return
		end
	else
		-- If no valid units, check cursor position against known spots
		local _, groundPos = Spring.TraceScreenRay(mx, my, true)
		if not groundPos or not groundPos[1] then
			clearGhostBuild()
			return
		end
		local pos = { x = groundPos[1], y = groundPos.y, z = groundPos[3] }
		local nearestMex = WG["resource_spot_finder"].GetClosestMexSpot(pos.x, pos.z)
		local nearestGeo = WG["resource_spot_finder"].GetClosestGeoSpot(pos.x, pos.z)

		local mexDist = math.huge
		local geoDist = math.huge
		if nearestMex then
			mexDist = math.distance2dSquared(nearestMex.x, nearestMex.z, pos.x, pos.z)
		end
		if nearestGeo then
			geoDist = math.distance2dSquared(nearestGeo.x, nearestGeo.z, pos.x, pos.z)
		end

		-- Figure out if mex or geo is in range
		if mexDist < math.huge and mexDist < geoDist and mexDist < mexPlacementRadius then
			selectedMex = bestMex
			extractor = bestMex
			selectedSpot = nearestMex

		elseif geoDist < math.huge and geoDist < mexDist and geoDist < geoPlacementRadius then
			selectedGeo = bestGeo
			extractor = bestGeo
			selectedSpot = nearestGeo
		else
			clearGhostBuild()
			return
		end
	end



	local canBuild = WG['resource_spot_builder'].ExtractorCanBeBuiltOnSpot(selectedSpot, extractor)
	Spring.Echo("canBuild", canBuild)
	if not canBuild then
		clearGhostBuild()
		return
	end

	-- Set up ghost
	if extractor and selectedSpot then
		Spring.Echo("selectedSpot", selectedSpot.x, selectedSpot.y, selectedSpot.z)
		Spring.SetMouseCursor('upgmex')
		local cmdPos = {selectedSpot.x, selectedSpot.y, selectedSpot.z} -- we only want to build on the center, so we pass the spot in for the position, instead of the groundPos
		local cmd = WG["resource_spot_builder"].PreviewExtractorCommand(cmdPos, extractor, selectedSpot)
		buildCmd[1] = cmd
		drawUnitShape = {
			math.abs(extractor),
			cmd[2],
			cmd[3], --spGetGroundHeight(selectedSpot.x, selectedSpot.z),
			cmd[4],
			cmd[5],
			cmd[6]
		}
	else
		drawUnitShape = false
	end

	-- Draw ghost
	if WG.DrawUnitShapeGL4 then
		if drawUnitShape then
			if not activeUnitShape then
				activeUnitShape = WG.DrawUnitShapeGL4(drawUnitShape[1], drawUnitShape[2], drawUnitShape[3], drawUnitShape[4], drawUnitShape[5], 0.66, drawUnitShape[6], 0.15, 0.3)
			end
		elseif activeUnitShape then
			clearGhostBuild()
		end
	end
end


function widget:CommandNotify(id, params, options)
	Spring.Echo("cmd notify")
	if not buildCmd then
		Spring.Echo("no build cmd")
		return
	end
	local isMove = (id == CMD_MOVE)
	local isGuard = (id == CMD_GUARD)
	local isReclaim = (id == CMD_RECLAIM)
	if not (isMove or isGuard or isReclaim) or (isReclaim and params[2]) then
		Spring.Echo("not a move or guard or reclaim cmd")
		return
	end

	if #selectedUnits == 1 and unitIsCloaked(selectedUnits[1]) then
		Spring.Echo("cloaked unit, exit")
		return
	end

	if selectedMex then
		local cmd = WG['resource_spot_builder'].ApplyPreviewCmds(buildCmd, mexConstructors, options.shift)
		--local cmd = WG['resource_spot_builder'].BuildMex(params, options, isGuard, false, true, -selectedMex)
		Spring.Echo("mex build cmd is", dump(cmd))
		return cmd
	end
	if selectedGeo then
		local cmd = WG['resource_spot_builder'].ApplyPreviewCmds(buildCmd, geoConstructors, options.shift)
		--local cmd = WG['resource_spot_builder'].BuildGeo(params, options, isGuard, false, true, -selectedGeo)
		Spring.Echo("geo build cmd is", dump(cmd))
		return cmd
	end
end

function widget:Shutdown()
	Spring.Echo("shutting down quick build")
	clearGhostBuild()
end
