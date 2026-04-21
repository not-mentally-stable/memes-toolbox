--!strict
local TypedRemote = {}

export type RemoteType = RemoteEvent | UnreliableRemoteEvent
function TypedRemote:Create(remote: RemoteType, ...: any): RBXScriptConnection
	local initArgs = {...}
	local expectedTypes: {string} = {}
	local callback: (Player, ...any) -> () = nil :: any
	for _, arg in ipairs(initArgs) do
		if type(arg) == "string" then
			table.insert(expectedTypes, arg)
		elseif type(arg) == "function" then
			callback = arg
			break
		end
	end
	assert(callback ~= nil, "TypedRemote:Create requires a callback function.")
	local OnSEvent = remote.OnServerEvent :: RBXScriptSignal
	return OnSEvent:Connect(function(player: Player, ...: any)
		local passedArgs = {...}
		if #passedArgs < #expectedTypes then
			return
		end
		for i, expectedType in ipairs(expectedTypes) do
			if typeof(passedArgs[i]) ~= expectedType then
				return
			end
		end
		callback(player, ...)
	end)
end

return TypedRemote
