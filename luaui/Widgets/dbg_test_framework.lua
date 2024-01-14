function widget:GetInfo()
	return {
		name = "Test Framework Widget",
		desc = "Test framework helper widget",
		date = "2023",
		license = "GNU GPL, v2 or later",
		version = 0,
		layer = 0,
		enabled = true,
		handler = true,
	}
end

VFS.Include('luarules/testing/util.lua')

local LOG_LEVEL = LOG.INFO

local RETURN_TIMEOUT = 30
local DEFAULT_WAIT_TIMEOUT = 5 * 30

local SHOW_ALL_RESULTS = false

-- utils
-- =====
local function log(level, str, ...)
	if level < LOG_LEVEL then
		return
	end
	Spring.Log(
		widget:GetInfo().name,
		LOG.NOTICE,
		str
	)
end

-- main code
-- =========

local testRoots = {
	"LuaUI/Widgets/tests",
	"LuaUI/Tests",
	"luarules/tests/",
}

local function findTestFiles(directory, patterns, rootDirectory, result)
	if rootDirectory == nil then
		if directory:sub(-1) ~= '/' then
			directory = directory .. '/'
		end
		rootDirectory = directory
	end

	if result == nil then
		result = {}
	end

	for _, filename in ipairs(VFS.DirList(directory, "*", VFS.RAW_FIRST)) do
		local relativePath = string.sub(filename, string.len(rootDirectory) + 1)
		local withoutExtension = removeFileExtension(filename)
		if patterns == nil or #patterns == 0 or matchesPatterns(withoutExtension, patterns) then
			log(LOG.INFO, "Found test file: " .. relativePath)
			result[#result + 1] = {
				filename = filename,
				label = relativePath,
			}
		end
	end

	for _, subDir in ipairs(VFS.SubDirs(directory, "*", VFS.RAW_FIRST)) do
		findTestFiles(subDir, patterns, rootDirectory, result)
	end

	return result
end

local function findAllTestFiles(patterns)
	log(LOG.DEBUG, "[findAllTestFiles] " .. table.toString({
		patterns = patterns,
	}))
	local result = {}
	for _, path in ipairs(testRoots) do
		for _, testFileInfo in ipairs(findTestFiles(path, patterns)) do
			result[#result + 1] = testFileInfo
		end
	end
	return result
end

local function displayTestResults(results)
	log(LOG.INFO, "=====TEST RESULTS=====")
	for _, testResult in ipairs(results) do
		log(LOG.INFO, formatTestResult(testResult))
	end
end

local gameTimer
local runTestsTimer
local testTimer

local testRunState
local activeTestState
local resumeState
local returnState
local callinState
local spyControls

local function resetTestRunState()
	log(LOG.DEBUG, "[resetTestRunState]")
	testRunState = {
		runningTests = false,
		files = {},
		filesIndex = nil,
		results = {},
	}
end

local function resetActiveTestState()
	log(LOG.DEBUG, "[resetActiveTestState]")
	activeTestState = {
		coroutine = nil,
		environment = nil,
		startFrame = nil,
		file = nil,
		label = nil,
	}
end

local function resetResumeState()
	log(LOG.DEBUG, "[resetResumeState]")
	resumeState = {
		predicate = nil,
		timeoutExpireFrame = nil,
	}
end

local function resetReturnState()
	log(LOG.DEBUG, "[resetReturnState]")
	returnState = {
		waitingForReturnId = nil,
		success = nil,
		pendingValueOrError = nil,
		timeoutExpireFrame = nil,
	}
end

local function resetCallinState()
	log(LOG.DEBUG, "[resetCallinState]")
	callinState = {
		buffer = {},
	}
end

local function resetSpyCtrls()
	log(LOG.DEBUG, "[resetSpyCtrls]")
	spyControls = {}
end

local function resetState()
	log(LOG.DEBUG, "[resetState]")
	resetTestRunState()
	resetActiveTestState()
	resetResumeState()
	resetReturnState()
	resetCallinState()
	resetSpyCtrls()
end

resetState()

registerCallins(widget, function(name, args)
	if not testRunState.runningTests then
		return
	end

	if callinState.buffer[name] == nil then
		callinState.buffer[name] = {}
	end
	callinState.buffer[name][#(callinState.buffer[name]) + 1] = args
end)

local function startTests(patterns)
	log(LOG.DEBUG, "[startTests] " .. table.toString({
		patterns = patterns,
	}))

	if testRunState.runningTests then
		log(LOG.WARNING, "Tests are already running!")
		return
	end

	resetState()

	log(LOG.NOTICE, "=====FINDING TESTS=====")

	if type(patterns) == "string" then
		patterns = { patterns }
	end

	testRunState.files = findAllTestFiles(patterns)

	if testRunState.files == nil or #(testRunState.files) == 0 then
		log(LOG.INFO, "no test files found")
		return
	end

	testRunState.runningTests = true
	testRunState.index = 1

	log(LOG.NOTICE, "=====RUNNING TESTS=====")

	runTestsTimer = Spring.GetTimer()
end

local function finishTest(result)
	for _, control in ipairs(spyControls) do
		control.remove()
	end

	result.label = result.label or activeTestState.label
	if activeTestState and activeTestState.startFrame and result.frames == nil then
		result.frames = Spring.GetGameFrame() - activeTestState.startFrame
	end

	result.milliseconds = Spring.DiffTimers(Spring.GetTimer(), testTimer, true)

	log(LOG.NOTICE, formatTestResult(result))

	testRunState.results[#(testRunState.results) + 1] = result

	resetActiveTestState()
	resetResumeState()
	resetReturnState()
	resetCallinState()

	if testRunState.index < #(testRunState.files) then
		testRunState.index = testRunState.index + 1
	else
		-- done
		testRunState.index = nil
		testRunState.runningTests = false
		if SHOW_ALL_RESULTS then
			displayTestResults(testRunState.results)
		end
	end
end

local function createNestedProxy(prefix, path)
	return setmetatable({}, {
		__index = function(_, key)
			local newPath = path and (path .. "." .. key) or key
			return createNestedProxy(prefix, newPath)
		end,
		__call = function(_, ...)
			local args = { ... }
			local serializedFn, returnId = serializeFunctionCall(path, args)

			returnState = {
				waitingForReturnId = returnId,
				success = nil,
				pendingValueOrError = nil,
				timeoutExpireFrame = Spring.GetGameFrame() + RETURN_TIMEOUT,
			}

			log(LOG.DEBUG, "[createNestedProxy." .. prefix .. ".send] " .. table.toString({
				serializedFn = serializedFn,
			}))
			Spring.SendLuaRulesMsg(prefix .. serializedFn)

			local resumeOk, resumeResult = coroutine.yield()

			log(LOG.DEBUG, "[createNestedProxy." .. prefix .. ".return] " .. table.toString({
				resumeOk = resumeOk,
				resumeResult = resumeResult,
			}))

			if not resumeOk then
				error(resumeResult[1], 2)
			end

			return unpack(resumeResult)
		end,
	})
end

SyncedProxy = createNestedProxy(PROXY_PREFIX)
SyncedExtra = createNestedProxy(PROXY_EXTRA_PREFIX)

SyncedRun = function(fn)
	local serializedFn, returnId = serializeFunctionRun(fn, 3)

	returnState = {
		waitingForReturnId = returnId,
		success = nil,
		pendingValueOrError = nil,
		timeoutExpireFrame = Spring.GetGameFrame() + RETURN_TIMEOUT,
	}

	log(LOG.DEBUG, "[SyncedRun.send] " .. table.toString({
		serializedFn = serializedFn,
	}))
	Spring.SendLuaRulesMsg(PROXY_RUN_PREFIX .. serializedFn)

	local resumeOk, resumeResult = coroutine.yield()

	log(LOG.DEBUG, "[SyncedRun.return] " .. table.toString({
		resumeOk = resumeOk,
		resumeResult = resumeResult,
	}))

	if not resumeOk then
		error(resumeResult[1], 3)
	end

	return unpack(resumeResult)
end

Test = {
	waitUntil = function(f, timeout, errorOffset)
		if timeout == nil then
			timeout = DEFAULT_WAIT_TIMEOUT
		end

		resumeState = {
			predicate = f,
			timeoutExpireFrame = Spring.GetGameFrame() + timeout,
		}

		local resumeOk, resumeResult = coroutine.yield()

		log(LOG.DEBUG, "[waitUntil.return] " .. table.toString({
			resumeOk = resumeOk,
			resumeResult = resumeResult,
		}))

		resetResumeState()

		if not resumeOk then
			error(resumeResult, 2 + (errorOffset or 0))
		end
	end,
	waitFrames = function(frames)
		local startFrame = Spring.GetGameFrame()
		Test.waitUntil(
			function()
				return Spring.GetGameFrame() >= (startFrame + frames)
			end,
			frames + 5,
			1
		)
	end,
	waitTime = function(milliseconds, timeout)
		local startTimer = Spring.GetTimer()
		Test.waitUntil(
			function()
				return Spring.DiffTimers(Spring.GetTimer(), startTimer, true) >= milliseconds
			end,
			timeout or (milliseconds * 30 / 1000 + 5),
			1
		)
	end,
	waitUntilCallin = function(name, predicate, timeout)
		Test.waitUntil(
			function()
				for _, args in ipairs(callinState.buffer[name] or {}) do
					if predicate == nil or predicate(unpack(args)) then
						return true
					end
				end
				return false
			end,
			timeout,
			1
		)
	end,
	spy = function(...)
		local spyCtrl = spy(...)
		spyControls[#spyControls + 1] = spyCtrl
		return spyCtrl
	end,
	clearMap = SyncedExtra.clearMap,
}

function widget:RecvLuaMsg(msg)
	if not returnState.waitingForReturnId then
		return
	end

	if msg:sub(1, #PROXY_RETURN_PREFIX) == PROXY_RETURN_PREFIX then
		local serializedReturn = msg:sub(#PROXY_RETURN_PREFIX + 1)
		local returnOk, returnValueOrError, returnId = deserializeFunctionReturn(serializedReturn)

		log(LOG.DEBUG, "[RecvLuaMsg] " .. table.toString({
			serializedReturn = serializedReturn,
			returnOk = returnOk,
			returnValue = returnValueOrError,
			returnId = returnId,
		}))

		if returnId == returnState.waitingForReturnId then
			-- this is the return we were waiting for (otherwise we ignore it)
			returnState = {
				waitingForReturnId = nil,
				success = returnOk,
				pendingValueOrError = returnValueOrError,
				timeoutExpireFrame = nil,
			}
		end
	end
end

local function runTestInternal()
	log(LOG.DEBUG, "[runTestInternal]")

	local setupOk, setupResult
	if setup ~= nil then
		setupOk, setupResult = yieldable_pcall(setup)
	else
		setupOk = true
	end

	local testOk, testResult
	if setupOk then
		testOk, testResult = yieldable_pcall(test)
	end

	-- always try to run cleanup
	local cleanupOk, cleanupResult
	if cleanup ~= nil then
		cleanupOk, cleanupResult = yieldable_pcall(cleanup)
	else
		cleanupOk = true
	end

	if not cleanupOk then
		error(cleanupResult, 2)
	end

	if not setupOk then
		error(setupResult, 2)
	end

	if not testOk then
		error(testResult, 2)
	end
end

local function initializeTestEnvironment()
	local env = {
		-- test framework
		Test = Test,
		SyncedProxy = SyncedProxy,
		SyncedRun = SyncedRun,
		__runTestInternal = runTestInternal,
		yieldable_pcall = yieldable_pcall,

		-- widgets
		widgetHandler = widgetHandler,
		WG = WG,

		-- game
		VFS = VFS,
		Script = Script,
		Spring = Spring,
		Engine = Engine,
		Platform = Platform,
		Game = Game,
		gl = gl,
		GL = GL,
		CMD = CMD,
		CMDTYPE = CMDTYPE,
		LOG = LOG,

		UnitDefs = UnitDefs,
		UnitDefNames = UnitDefNames,
		FeatureDefs = FeatureDefs,
		FeatureDefNames = FeatureDefNames,
		WeaponDefs = WeaponDefs,
		WeaponDefNames = WeaponDefNames,

		pack = pack,
		pcall = pcall,
		io = io,
		os = os,
		math = math,
		debug = debug,
		tracy = tracy,
		table = table,
		string = string,
		package = package,
		--coroutine = coroutine,
		assert = assert,
		error = error,
		print = print,
		next = next,
		pairs = pairs,
		ipairs = ipairs,
		tonumber = tonumber,
		tostring = tostring,
		type = type,
		unpack = unpack,
		select = select,

		Json = Json,
	}

	return env
end

local function loadTestFromFile(filename)
	if not VFS.FileExists(filename) then
		return false, "missing file: " .. filename
	end

	local text = VFS.LoadFile(filename, VFS.RAW_FIRST)

	if text == nil or text == "" then
		return false, "missing file content: " .. filename
	end

	local chunk, err = loadstring(text, filename)
	if chunk == nil then
		return false, err
	end

	local testEnvironment = initializeTestEnvironment()

	setfenv(chunk, testEnvironment)

	local success, err = pcall(chunk)
	if not success then
		return false, err
	end

	if testEnvironment.test == nil then
		return false, "no test() function"
	end

	setfenv(testEnvironment.__runTestInternal, testEnvironment)

	return true, testEnvironment
end

local function handleReturn()
	if returnState.success == nil and returnState.waitingForReturnId == nil then
		-- no return to handle, so just continue
		return {
			status = "continue",
		}
	end

	if returnState.timeoutExpireFrame ~= nil then
		if Spring.GetGameFrame() >= returnState.timeoutExpireFrame then
			-- resume took too long, result is error
			log(LOG.DEBUG, "[handleReturn] timeout -> error")
			return {
				status = "error",
				error = "waiting for synced return timed out"
			}
		end
	end

	if returnState.waitingForReturnId then
		return {
			status = "wait"
		}
	end

	local tempReturnValue = returnState.pendingValueOrError
	returnState.pendingValueOrError = nil

	if returnState.success then
		-- we're ok to resume
		log(LOG.DEBUG, "[handleReturn] success -> continue")
		resetReturnState()
		return {
			status = "continue",
			returnValue = tempReturnValue
		}
	else
		-- remote function errored
		log(LOG.DEBUG, "[handleReturn] remote error -> error")
		return {
			status = "error",
			error = tempReturnValue,
		}
	end
end

local function handleWait()
	if resumeState.predicate == nil then
		return {
			status = "continue",
		}
	end

	if Spring.GetGameFrame() >= resumeState.timeoutExpireFrame then
		-- resume took too long, result is error
		log(LOG.DEBUG, "[handleWait] timeout -> error")
		return {
			status = "error",
			error = "resume predicate timed out",
		}
	end

	local success, returnOrError = pcall(resumeState.predicate)
	if success then
		-- predicate ran successfully
		if returnOrError then
			-- succeeded, we can resume
			log(LOG.DEBUG, "[handleWait] predicate success + true -> continue")
			resetResumeState()
			return {
				status = "continue"
			}
		else
			-- failed, wait and try again next frame
			return {
				status = "wait"
			}
		end
	else
		-- error during predicate
		log(LOG.DEBUG, "[handleWait] predicate error -> error")
		return {
			status = "error",
			error = returnOrError
		}
	end
end

local function getGameTime()
	return Spring.DiffTimers(Spring.GetTimer(), gameTimer, true)
end

local function getRunTestsTime()
	return Spring.DiffTimers(Spring.GetTimer(), runTestsTimer, true)
end

local function getTestTime()
	return Spring.DiffTimers(Spring.GetTimer(), testTimer, true)
end

local function step()
	if not testRunState.runningTests then
		return
	end

	--*result = {
	--	status =
	--		| "continue" (ok to continue to other checks and resuming test)
	--		| "error" (an error occurred, skip directly to resuming test and pass the error for it to be handled)
	--		| "wait" (waiting on something, return immediately)
	--	error = (status="error" only)
	--	returnValue = (status="continue" only, optional)
	--}
	local returnResult = handleReturn()

	if returnResult.status == "wait" then
		return
	end

	local waitResult = handleWait()

	if waitResult.status == "wait" then
		return
	end

	-- is there a test set up? if not, create one
	if activeTestState.coroutine == nil then
		activeTestState.label = testRunState.files[testRunState.index].label
		activeTestState.file = testRunState.files[testRunState.index]

		local success, envOrError = loadTestFromFile(activeTestState.file.filename)

		if success then
			log(LOG.DEBUG, "Initializing test: " .. activeTestState.label)
			activeTestState.environment = envOrError
			activeTestState.coroutine = coroutine.create(activeTestState.environment.__runTestInternal)
			activeTestState.startFrame = Spring.GetGameFrame()

			testTimer = Spring.GetTimer()
		else
			finishTest({
				result = TEST_RESULT.ERROR,
				error = envOrError
			})
			return
		end
	end

	-- resume the test
	if coroutine.status(activeTestState.coroutine) == "suspended" then
		local coroutineOk, coroutineArgs
		if returnResult.returnValue ~= nil then
			coroutineOk = true
			coroutineArgs = returnResult.returnValue
		elseif returnResult.status == "error" then
			coroutineOk = false
			coroutineArgs = returnResult.error
		elseif waitResult.status == "error" then
			coroutineOk = false
			coroutineArgs = waitResult.error
		else
			coroutineOk = true
			coroutineArgs = nil
		end

		log(
			LOG.DEBUG,
			"Resuming test: " .. activeTestState.label .. " with value: " .. table.toString({
				coroutineOk = coroutineOk,
				coroutineArgs = coroutineArgs,
			})
		)

		local result, error = coroutine.resume(activeTestState.coroutine, coroutineOk, coroutineArgs)
		if not result then
			-- test fail
			finishTest({
				result = TEST_RESULT.FAIL,
				error = error,
			})
			return
		end
	end

	if coroutine.status(activeTestState.coroutine) == "dead" then
		-- test pass
		finishTest({
			result = TEST_RESULT.PASS,
		})
	end
end

function widget:GameFrame(frame)
	step()
end

function widget:Update(dt)
	step()
end

function widget:Initialize()
	widgetHandler.actionHandler:AddAction(
		self,
		"runtests",
		function(cmd, optLine, optWords, data, isRepeat, release, actions)
			startTests(splitPhrases(optLine))
		end,
		nil,
		"t"
	)

	gameTimer = Spring.GetTimer()
end

function widget:Shutdown()
	widgetHandler.actionHandler:RemoveAction("runtests", "t")
end
