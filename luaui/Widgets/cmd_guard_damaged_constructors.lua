function widget:GetInfo()
  return {
    name = "Guard damaged constructors",
    desc = "Replace repair command with guard command when right click targeting damaged constructors and factories",
    license = "GNU GPL, v2 or later",
    layer = 0,
    enabled = true
  }
end

local guardConstructors = true
local guardFactories = true

local isConstructor = {}
local isFactory = {}
local canAssist = {}

for unitDefID, unitDef in pairs(UnitDefs) do
  if unitDef.isMobileBuilder then
    isConstructor[unitDefID] = true
  end

  if unitDef.isFactory then
    isFactory[unitDefID] = true
  end

  if unitDef.canAssist then
    canAssist[unitDefID] = true
  end
end

function widget:DefaultCommand(targetType, targetID, engineCmd)
  if targetType ~= "unit" then
    return
  end

  if engineCmd == CMD.REPAIR then
    if select(5, Spring.GetUnitHealth(targetID)) < 1 then
      return
    end

    -- todo: rewrite logic to use more early returns
    local selectedUnits = Spring.GetSelectedUnits()
    for i = 1, #selectedUnits do
      local sourceUnitDefID = Spring.GetUnitDefID(selectedUnits[i])

      if not canAssist(sourceUnitDefID) then
        return
      end
    end

    local targetUnitDefID = Spring.GetUnitDefID(targetID)
    if (isConstructor[targetUnitDefID] and guardConstructors) or (isFactory[targetUnitDefID] and guardFactories) then
      return CMD.GUARD
    end
  end
end
