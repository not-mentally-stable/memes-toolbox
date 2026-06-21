--!strict
const LogService = game:GetService("LogService")
const ObjectInfo = require("@self/ObjectInfo")

const DEFAULT_LABEL: string = "default"
const counts: { [string]: number } = {}
const timers: { [string]: number } = {}

local groupIndentLevel: number = 0

local function getIndent(): string
	return string.rep("  ", groupIndentLevel)
end

local function processVarargs(...: any): (string, { [string]: any }?)
	local args = {...}
	local messageParts = {}
	local context = {}
	local hasContext = false
	
	for i, arg in ipairs(args) do
		local argType = type(arg)
		
		if argType == "table" then
			table.insert(messageParts, "[table]")
			context["arg" .. i] = arg
			hasContext = true
		elseif argType == "Instance" then
			table.insert(messageParts, `[Instance: {(arg :: Instance).Name}]`)
			context["arg" .. i] = arg
			hasContext = true
		else
			table.insert(messageParts, tostring(arg))
		end
	end
	
	local finalMessage = table.concat(messageParts, " ")
	return finalMessage, if hasContext then context else nil
end

local function internalTable(data: any, outputType: "log" | "info" | "warn" | "error", context: { [string]: any }?)
	const logContext: { [string]: any } = { preview = data }
	if context then
		for k, v in context do
			logContext[k] = v
		end
	end
	const indent = getIndent()
	if outputType == "log" then
		LogService:Output(indent .. "table:", logContext)
	elseif outputType == "info" then
		LogService:Info(indent .. "table:", logContext)
	elseif outputType == "warn" then
		LogService:Warn(indent .. "table:", logContext)
	elseif outputType == "error" then
		LogService:Error(indent .. "table:", logContext)
	end
end

export type Console = {
	log: (...any) -> (),
	info: (...any) -> (),
	warn: (...any) -> (),
	error: (...any) -> (),
	exception: (...any) -> (),
	debug: (...any) -> (),
	trace: (...any) -> (),
	
	assert: (condition: any, msg: string?) -> (),
	clear: () -> (),
	
	count: (label: string?) -> (),
	countReset: (label: string?) -> (),
	
	time: (label: string?) -> (),
	timeLog: (label: string?, ...any) -> (),
	timeEnd: (label: string?) -> (),
	
	group: (...any) -> (),
	groupCollapsed: (...any) -> (),
	groupEnd: () -> (),
	
	profile: typeof(debug.profilebegin),
	profileEnd: typeof(debug.profileend),
	
	table: (data: any) -> (),
	dir: (item: any) -> (),
}

const console = {}

console.log = function(...: any)
	local args = {...}
	if #args == 1 and type(args[1]) == "table" then
		internalTable(args[1], "log")
	else
		local message, context = processVarargs(...)
		LogService:Output(`{getIndent()}{message}`, context)
	end
end

console.info = function(...: any)
	local args = {...}
	if #args == 1 and type(args[1]) == "table" then
		internalTable(args[1], "info")
	else
		local message, context = processVarargs(...)
		LogService:Info(`{getIndent()}{message}`, context)
	end
end

console.warn = function(...: any)
	local args = {...}
	if #args == 1 and type(args[1]) == "table" then
		internalTable(args[1], "warn")
	else
		local message, context = processVarargs(...)
		LogService:Warn(`{getIndent()}{message}`, context)
	end
end

--[[
	the real JS console.error doesn't stop execution so im creating a new thread since luau errors stop execution
	it's still recommended to use alternative ways
]]--
console.error = function(...: any)
	local args = {...}
	task.spawn(function()
		if #args == 1 and type(args[1]) == "table" then
			internalTable(args[1], "error")
		else
			local message, context = processVarargs(table.unpack(args))
			LogService:Error(`{getIndent()}{message}`, context) 
		end
	end)
end

@[deprecated {
    use = "console.error()",
    reason = "this is just an alias for console.error()",
}]
function console.exception(...: any)
	return console.error(...)
end

console.debug = function(...: any)
	local args = {...}
	if #args == 1 and type(args[1]) == "table" then
		internalTable(args[1], "info")
	else
		local message, context = processVarargs(...)
		LogService:Info(`{getIndent()}[DEBUG] {message}`, context)
	end
end

console.trace = function(...: any)
	local message, context = processVarargs(...)
	local trace = debug.traceback("", 2)
	if message == "" then
		LogService:Output(`{getIndent()}Trace\n{trace}`, context)
	else
		LogService:Output(`{getIndent()}{message}\n{trace}`, context)
	end
end

console.assert = function(condition: any, msg: string?)
	if not condition then
		console.error(msg or "Assertion failed")		
	end
end

--// sadly only works in studio console
console.clear = function()
	LogService:ClearOutput()
end

console.count = function(label: string?)
	const actualLabel = label or DEFAULT_LABEL
	counts[actualLabel] = (counts[actualLabel] or 0) + 1
	console.log(`{actualLabel}: {counts[actualLabel]}`)
end

console.countReset = function(label: string?)
	const actualLabel = label or DEFAULT_LABEL
	counts[actualLabel] = 0
	console.log(`{actualLabel}: 0`)
end

console.time = function(label: string?)
	const actualLabel = label or DEFAULT_LABEL
	timers[actualLabel] = os.clock()
end

console.timeLog = function(label: string?, ...: any)
	const actualLabel = label or DEFAULT_LABEL
	const start = timers[actualLabel]
	if start then
		const ms = (os.clock() - start) * 1000
		local args = {...}
		if #args > 0 then
			local message, context = processVarargs(...)
			LogService:Output(`{getIndent()}{actualLabel}: {ms}ms {message}`, context)
		else
			console.log(`{actualLabel}: {ms}ms`)
		end
	end
end

console.timeEnd = function(label: string?)
	const actualLabel = label or DEFAULT_LABEL
	console.timeLog(actualLabel)
	timers[actualLabel] = nil
end

console.group = function(...: any)
	local args = {...}
	if #args > 0 then
		console.log(...)
	else
		console.log("group")
	end
	groupIndentLevel += 1
end

console.groupCollapsed = function(...: any)
	console.group(...)
end

console.groupEnd = function()
	groupIndentLevel = math.max(0, groupIndentLevel - 1)
end

console.profile = debug.profilebegin

console.profileEnd = debug.profileend

console.table = function(data: any)
	internalTable(data, "log")
end

console.dir = function(item: any)
	if typeof(item) == "Instance" then
		const report = ObjectInfo.getReport(item)
		if report then
			LogService:Output(`{getIndent()}Object Info: {report.Info.Name}`, { Info = report.Info })
			LogService:Output(`{getIndent()}Properties:`, { Properties = report.Properties })
			LogService:Output(`{getIndent()}Methods:`, { Methods = report.Methods })
			LogService:Output(`{getIndent()}Signals:`, { Signals = report.Signals })
		end
	else
		LogService:Output(`{getIndent()}Object Directory:`, { data = item })
	end
end

return table.freeze(console) :: Console
