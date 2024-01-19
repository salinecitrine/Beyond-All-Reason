local DEBUGCOMMANDS = {
	{ 1, "cheat" },
	{ 2, "godmode" },
	--{ 25, "luaui enablewidget UnitCallinsWidget" },
	--{ 30, "runtestsheadless selfd battle" },
}

local SCRIPT_TEMPLATE_PATH = "game_script_template.txt"
local SCRIPT_OUTPUT_PATH = "__game_script_temp.txt"
local SHELL_SCRIPT_PATH = "run_script.cmd"

local function map(list, func)
	local result = {}
	for i, v in ipairs(list) do
		result[i] = func(v, i)
	end
	return result
end

local templateFields = {
	debugcommands = table.concat(
		map(DEBUGCOMMANDS, function(cmd)
			return cmd[1] .. ":" .. cmd[2]
		end),
		"|"
	),
}

local templateFile = io.open(SCRIPT_TEMPLATE_PATH, "r")
local template = templateFile:read("*a")
templateFile:close()

local templateResult = template:gsub("%%%%(.-)%%%%", templateFields)

local outputFile = io.open(SCRIPT_OUTPUT_PATH, "w")
outputFile:write(templateResult)
outputFile:close()

os.execute(SHELL_SCRIPT_PATH .. " " .. SCRIPT_OUTPUT_PATH)
