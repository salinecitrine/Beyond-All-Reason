local SI_PREFIXES_LOG1K = {
	[10] = "Q",
	[9] = "R",
	[8] = "Y",
	[7] = "Z",
	[6] = "E",
	[5] = "P",
	[4] = "T",
	[3] = "G",
	[2] = "M",
	[1] = "k",
	[0] = "",
	[-1] = "m",
	[-2] = "μ",
	[-3] = "n",
	[-4] = "p",
	[-5] = "f",
	[-6] = "a",
	[-7] = "z",
	[-8] = "y",
	[-9] = "r",
	[-10] = "q",
}

local function toEngineeringNotation(number)
	if number == 0 then
		return "0"
	end

	local sign = 1
	if number < 0 then
		number = number * -1
		sign = -1
	end

	local log1k = math.floor(math.log(number) / math.log(1000))
	local prefix = SI_PREFIXES_LOG1K[log1k]
	if prefix == nil then
		return nil
	end

	number = number / math.pow(1000, log1k)
	local precision = 2 - math.floor(math.log10(number))
	local str = string.format("%." .. precision .. "f", sign * number)

	if string.find(str, "%.") ~= nil then
		local i = string.len(str)
		while i > 0 do
			local c = string.sub(str, i, i)
			if c == "0" then
				i = i - 1
			elseif c == "." then
				i = i - 1
				break
			else
				break
			end
		end
		str = string.sub(str, 1, i)
	end

	return str .. prefix
end

function pack(...)
	return { ... }
end

local function diffTable(t1, t2)
	assert(#t1 == #t2)
	local result = {}
	for i = 1, #t1 do
		result[i] = t2[i] - t1[i]
	end
	return result
end

local fields = {
	-- luaui
	{
		name = "luaHandleAllocedMem",
		render = function(v)
			return toEngineeringNotation(v * 1000) .. "B"
		end
	},
	{
		name = "luaHandleNumAllocs",
		render = function(v)
			return v * 1000
		end
	},
	-- total
	{
		name = "luaGlobalAllocedMem",
		render = function(v)
			return toEngineeringNotation(v * 1000) .. "B"
		end
	},
	{
		name = "luaGlobalNumAllocs",
		render = function(v)
			return v * 1000
		end
	},
	-- unsynced states (luarules+luagaia+luaui)
	{
		name = "luaUnsyncedGlobalAllocedMem",
		render = function(v)
			return toEngineeringNotation(v * 1000) .. "B"
		end
	},
	{
		name = "luaUnsyncedGlobalNumAllocs",
		render = function(v)
			return v * 1000
		end
	},
	-- synced states (luarules+luagaia)
	{
		name = "luaSyncedGlobalAllocedMem",
		render = function(v)
			return toEngineeringNotation(v * 1000) .. "B"
		end
	},
	{
		name = "luaSyncedGlobalNumAllocs",
		render = function(v)
			return v * 1000
		end
	},
}

local function formatFieldChanges(fieldId, ms)
	local result = ""
	if #ms > 0 then
		result = result .. "(" .. fields[fieldId].render(ms[1][fieldId]) .. ")"
	end

	for i = 2, #ms do
		local diff = diffTable(ms[i - 1], ms[i])
		local sign = ""
		if diff[fieldId] > 0 then
			sign = "+"
		end
		result = result .. " => " .. sign .. fields[fieldId].render(diff[fieldId])
	end
	return result
end

local testWidgetNames = {
	"Test GC (no VFS)",
	"Test GC (VFS)",
	"Test GC (no VFS/nil)",
	"Test GC (VFS/nil)",
	"Test GC (no VFS/WG)",
	"Test GC (no VFS/WG/WGnil)",
}

function setup()
	Test.clearMap()

	for _, name in ipairs(testWidgetNames) do
		widgetHandler:DisableWidget(name)
	end

	collectgarbage("collect")
end

function cleanup()
	Test.clearMap()

	for _, name in ipairs(testWidgetNames) do
		widgetHandler:DisableWidget(name)
	end
end

local function runForWidget(widgetName)
	local ms = {}

	collectgarbage("collect")
	ms[#ms + 1] = pack(Spring.GetLuaMemUsage())
	Spring.Echo(WG.make_garbo_an_upvalue and (WG.make_garbo_an_upvalue() and (WG.make_garbo_an_upvalue()[69] or "no entries") or "no table ret") or "no func")

	widgetHandler:EnableWidget(widgetName)
	ms[#ms + 1] = pack(Spring.GetLuaMemUsage())
	Spring.Echo(WG.make_garbo_an_upvalue and (WG.make_garbo_an_upvalue() and (WG.make_garbo_an_upvalue()[69] or "no entries") or "no table ret") or "no func")

	collectgarbage("collect")
	ms[#ms + 1] = pack(Spring.GetLuaMemUsage())
	Spring.Echo(WG.make_garbo_an_upvalue and (WG.make_garbo_an_upvalue() and (WG.make_garbo_an_upvalue()[69] or "no entries") or "no table ret") or "no func")

	widgetHandler:DisableWidget(widgetName)
	ms[#ms + 1] = pack(Spring.GetLuaMemUsage())
	Spring.Echo(WG.make_garbo_an_upvalue and (WG.make_garbo_an_upvalue() and (WG.make_garbo_an_upvalue()[69] or "no entries") or "no table ret") or "no func")

	collectgarbage("collect")
	ms[#ms + 1] = pack(Spring.GetLuaMemUsage())

	Spring.Echo(widgetName .. " : " .. formatFieldChanges(3, ms)) -- luaGlobalAllocedMem

	WG.make_garbo_an_upvalue = nil
	collectgarbage("collect")
end

function test()
	for _, name in ipairs(testWidgetNames) do
		runForWidget(name)
	end
end
